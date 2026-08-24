import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_to_app/core/services/credit_service.dart';
import 'package:web_to_app/core/services/download_token_service.dart';
import 'package:web_to_app/core/services/iap_product_id_resolver.dart';

Future<bool>? _earlyRestoreFuture;

/// Diginotes-style pack paywall price row (sale + optional compare-at).
class CreditsPackListedPrice {
  const CreditsPackListedPrice({
    required this.salePrice,
    required this.regularPrice,
    required this.discountPercent,
    this.offerToken,
  });

  final String salePrice;
  final String regularPrice;
  final int discountPercent;
  final String? offerToken;

  bool get hasDiscount =>
      discountPercent > 0 && regularPrice.trim() != salePrice.trim();
}

class _NativeOneTimeOffer {
  const _NativeOneTimeOffer({
    required this.formattedPrice,
    required this.priceAmountMicros,
    this.offerToken,
  });

  final String formattedPrice;
  final int priceAmountMicros;
  final String? offerToken;

  bool get hasToken => offerToken != null && offerToken!.isNotEmpty;
}

class PremiumService {
  static PremiumService? _instance;
  SharedPreferences? _prefs;

  Future<bool>? _activeRestoreFuture;

  /// Fired after premium is persisted (restore/purchase) so UI can refresh.
  static void Function()? onPremiumChanged;

  final IapProductIdResolver _productIdResolver = IapProductIdResolver.instance;

  static const String _premiumKey = 'premium_active';
  static const String _proKey = 'pro_user';
  static const String _purchaseTokenKey = 'purchase_token';
  static const String _purchaseIdKey = 'purchase_id';
  static const String _productIdKey = 'premium_product_id';
  static const String _premiumExpiryKey = 'premium_expires_at_ms';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  Future<void>? _initializationFuture;
  Future<void>? _loadingProductsFuture;

  bool lastPurchaseCancelledByUser = false;

  /// Play Billing 8 one-time offers for the credits pack (incl. offer tokens).
  List<_NativeOneTimeOffer> _nativePackOffers = [];
  Future<void>? _nativePackOffersInflight;

  static const MethodChannel _packOffersChannel =
      MethodChannel('pack_iap_debug');

  PremiumService._();

  static Future<PremiumService> getInstance() async {
    _instance ??= PremiumService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    await _instance!._ensureInitialized();
    return _instance!;
  }

  static Future<bool> beginRestoreEarly({
    Duration timeout = const Duration(seconds: 12),
  }) {
    _earlyRestoreFuture ??= getInstance().then(
      (service) => service.restorePurchasesAndWait(timeout: timeout),
    );
    return _earlyRestoreFuture!;
  }

  static bool get isPremiumCached => _instance?.isPremiumUser() ?? false;

  Future<void> _ensureInitialized() {
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (_) {},
    );

    unawaited(_loadProducts());
  }

  Future<void> _revokePremium() async {
    await _prefs?.remove(_premiumKey);
    await _prefs?.remove(_proKey);
    await _prefs?.remove(_purchaseTokenKey);
    await _prefs?.remove(_purchaseIdKey);
    await _prefs?.remove(_productIdKey);
    await _prefs?.remove(_premiumExpiryKey);
  }

  int? _readExpiryMillis(PurchaseDetails purchase) {
    if (Platform.isAndroid && purchase is GooglePlayPurchaseDetails) {
      try {
        final json = jsonDecode(purchase.billingClientPurchase.originalJson)
            as Map<String, dynamic>;
        final expiryMs = json['expiryTimeMillis'];
        if (expiryMs == null) return null;
        return int.tryParse(expiryMs.toString());
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool _isPurchaseCurrentlyActive(PurchaseDetails purchase) {
    final isSubscription = _productIdResolver.isValidSubscriptionProductId(
      purchase.productID,
    );
    final isLifetime = _productIdResolver.isLifetimeProductId(
      purchase.productID,
    );
    if (!isSubscription && !isLifetime) return false;

    if (purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      return false;
    }

    if (Platform.isAndroid && purchase is GooglePlayPurchaseDetails) {
      final billing = purchase.billingClientPurchase;
      if (billing.purchaseState != PurchaseStateWrapper.purchased) {
        return false;
      }
      if (isLifetime) return true;
      final expiryMs = _readExpiryMillis(purchase);
      if (expiryMs != null &&
          DateTime.now().millisecondsSinceEpoch >= expiryMs) {
        return false;
      }
      return true;
    }

    if (Platform.isIOS) {
      return purchase is AppStorePurchaseDetails ||
          purchase is SK2PurchaseDetails;
    }

    return true;
  }

  Future<List<PurchaseDetails>> _queryActivePurchasesFromStore() async {
    if (!Platform.isAndroid) return const [];

    try {
      final addition =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await addition.queryPastPurchases();
      if (response.error != null) return const [];
      return response.pastPurchases;
    } catch (e) {
      developer.log('queryPastPurchases failed: $e', name: 'PremiumService');
      return const [];
    }
  }

  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    try {
      final productIds = _productIdResolver.getAllProductIds();
      final response = await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        developer.log(
          'queryProductDetails error: ${response.error}',
          name: 'PremiumService',
        );
        return;
      }

      _products = response.productDetails;

      if (response.notFoundIDs.isNotEmpty) {
        developer.log(
          'Product IDs not returned by store: ${response.notFoundIDs}',
          name: 'PremiumService',
        );
      }
    } catch (e) {
      developer.log('Product load failed: $e', name: 'PremiumService');
    }
  }

  Future<void> reloadProducts() => _loadProducts();

  /// Credits-pack only: fetch Play multi-offers (does not block subscription IAP).
  Future<void> refreshCreditsPackOffers({bool force = false}) async {
    await _refreshNativePackOffers(force: force);
  }

  Future<void> _refreshNativePackOffers({bool force = false}) {
    if (!Platform.isAndroid) return Future.value();
    if (!force && _nativePackOffers.isNotEmpty) return Future.value();
    return _nativePackOffersInflight ??= () async {
      try {
        await _fetchNativePackOffers().timeout(const Duration(seconds: 8));
      } catch (e) {
        developer.log('native pack offers timed out/failed: $e', name: 'PackIAP');
        _nativePackOffers = [];
      } finally {
        _nativePackOffersInflight = null;
      }
    }();
  }

  Future<void> _fetchNativePackOffers() async {
    try {
      final productId = _productIdResolver.getCreditsPackProductId();
      final raw = await _packOffersChannel.invokeMethod<dynamic>(
        'dumpPackOffers',
        {'productId': productId},
      );
      final dump = _asStringKeyedMap(raw);
      _nativePackOffers = _parseNativePackOffers(dump);
      developer.log(
        'native pack offers=${_nativePackOffers.length} '
        'tokens=${_nativePackOffers.where((o) => o.hasToken).length}',
        name: 'PackIAP',
      );
    } catch (e) {
      developer.log('native pack offers failed: $e', name: 'PackIAP');
      _nativePackOffers = [];
    }
  }

  List<_NativeOneTimeOffer> _parseNativePackOffers(Map<String, Object?>? dump) {
    if (dump == null) return [];
    final collected = <_NativeOneTimeOffer>[];

    void addFrom(dynamic raw) {
      final map = _asStringKeyedMap(raw);
      if (map == null) return;
      final micros = _asInt(map['priceAmountMicros']);
      final formatted = (map['formattedPrice'] as String?)?.trim() ?? '';
      if (micros <= 0 || formatted.isEmpty) return;
      final token = (map['offerToken'] as String?)?.trim();
      collected.add(
        _NativeOneTimeOffer(
          formattedPrice: formatted,
          priceAmountMicros: micros,
          offerToken: (token == null || token.isEmpty) ? null : token,
        ),
      );
    }

    final flattened = dump['flattenedOffers'];
    if (flattened is List) {
      for (final item in flattened) {
        addFrom(item);
      }
    }
    if (collected.isEmpty) {
      addFrom(dump['cheapestOffer']);
      addFrom(dump['highestOffer']);
    }
    if (collected.isEmpty) {
      final products = dump['products'];
      if (products is List) {
        for (final product in products) {
          final map = _asStringKeyedMap(product);
          if (map == null) continue;
          final list = map['oneTimePurchaseOfferDetailsList'];
          if (list is List) {
            for (final item in list) {
              addFrom(item);
            }
          }
          addFrom(map['oneTimePurchaseOfferDetails']);
        }
      }
    }
    return collected;
  }

  Map<String, Object?>? _asStringKeyedMap(dynamic raw) {
    if (raw is! Map) return null;
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  Future<void> ensureProductsLoaded() {
    if (!_isAvailable) return Future.value();
    return _loadingProductsFuture ??= _loadProducts().whenComplete(() {
      _loadingProductsFuture = null;
    });
  }

  final List<void Function(PurchaseStatus, PurchaseDetails?)>
      _purchaseStatusCallbacks = [];

  void addPurchaseStatusCallback(
    void Function(PurchaseStatus, PurchaseDetails?) callback,
  ) {
    _purchaseStatusCallbacks.add(callback);
  }

  void removePurchaseStatusCallback(
    void Function(PurchaseStatus, PurchaseDetails?) callback,
  ) {
    _purchaseStatusCallbacks.remove(callback);
  }

  void _notifyPurchaseStatus(
    PurchaseStatus status, [
    PurchaseDetails? purchase,
  ]) {
    for (final callback in _purchaseStatusCallbacks) {
      try {
        callback(status, purchase);
      } catch (e) {
        developer.log(
          'Purchase status callback failed: $e',
          name: 'PremiumService',
        );
      }
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      _notifyPurchaseStatus(purchase.status, purchase);

      if (purchase.status == PurchaseStatus.error) {
        _handlePurchaseError(purchase);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _handlePurchaseSuccess(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  String? _getPurchaseErrorMessage(PurchaseDetails purchase) {
    final error = purchase.error;
    if (error == null) return null;

    final errorCode = error.code;
    final errorMessage = error.message.toLowerCase();

    if (errorMessage.contains('not configured for billing') ||
        errorMessage.contains('billing is not available') ||
        errorCode == 'BILLING_UNAVAILABLE' ||
        errorCode == 'DEVELOPER_ERROR') {
      return 'Billing not configured. Upload the app to Play Console and '
          'configure the in-app products.';
    }

    if (errorMessage.contains('product not found') ||
        errorCode == 'ITEM_UNAVAILABLE') {
      return 'Product not found in the store.';
    }

    if (errorMessage.contains('network') || errorCode == 'NETWORK_ERROR') {
      return 'Network error. Please check your connection and try again.';
    }

    if (errorCode == 'USER_CANCELED' ||
        errorCode == '2' ||
        errorCode == '15') {
      return 'Purchase cancelled.';
    }

    return error.message;
  }

  void _handlePurchaseError(PurchaseDetails purchase) {}

  Future<void> _handlePurchaseSuccess(PurchaseDetails purchase) async {
    if (_productIdResolver.isCreditsPackProductId(purchase.productID)) {
      final key = purchase.purchaseID?.trim().isNotEmpty == true
          ? purchase.purchaseID!.trim()
          : purchase.verificationData.serverVerificationData;
      await CreditService.instance.addPurchasedPack(key);
      return;
    }

    if (_productIdResolver.isDownloadInappProductId(purchase.productID)) {
      final key = purchase.purchaseID?.trim().isNotEmpty == true
          ? purchase.purchaseID!.trim()
          : purchase.verificationData.serverVerificationData;
      final appId = DownloadTokenService.instance.pendingPurchaseAppId?.trim();
      if (appId != null && appId.isNotEmpty) {
        await DownloadTokenService.instance.unlockProjectFromPurchase(
          appId: appId,
          purchaseKey: key,
        );
      } else {
        developer.log(
          'Download in-app purchase without pending appId '
          '(product=${purchase.productID})',
          name: 'PremiumService',
        );
      }
      return;
    }

    if (!_isPurchaseCurrentlyActive(purchase)) {
      developer.log(
        'Ignoring inactive/expired purchase: ${purchase.productID}',
        name: 'PremiumService',
      );
      return;
    }

    await _persistPremiumFromPurchase(purchase);
  }

  Future<void> _persistPremiumFromPurchase(PurchaseDetails purchase) async {
    await _prefs?.setBool(_premiumKey, true);
    await _prefs?.setBool(_proKey, true);
    await _prefs?.setString(
      _purchaseTokenKey,
      purchase.verificationData.source,
    );
    await _prefs?.setString(_purchaseIdKey, purchase.purchaseID ?? '');
    await _prefs?.setString(_productIdKey, purchase.productID);

    final expiryMs = _readExpiryMillis(purchase);
    if (expiryMs != null) {
      await _prefs?.setInt(_premiumExpiryKey, expiryMs);
    } else {
      await _prefs?.remove(_premiumExpiryKey);
    }

    // Instantly refresh UI (e.g. hide splash ads disclaimer).
    _notifySessionPremiumChanged();
  }

  void _notifySessionPremiumChanged() {
    try {
      onPremiumChanged?.call();
    } catch (_) {}
  }

  String? getLastPurchaseError(PurchaseDetails? purchase) {
    if (purchase == null || purchase.error == null) return null;
    return _getPurchaseErrorMessage(purchase);
  }

  bool isPremiumUser() {
    final isPremium = _prefs?.getBool(_premiumKey) ?? false;
    final isPro = _prefs?.getBool(_proKey) ?? false;
    if (!isPremium && !isPro) return false;

    final expiryMs = _prefs?.getInt(_premiumExpiryKey);
    if (expiryMs != null && DateTime.now().millisecondsSinceEpoch >= expiryMs) {
      return false;
    }

    return true;
  }

  bool hasLifetimeAccess() {
    if (!isPremiumUser()) return false;
    final productId = _prefs?.getString(_productIdKey);
    return productId != null && _productIdResolver.isLifetimeProductId(productId);
  }

  /// Android expands each subscription offer into its own [ProductDetails].
  /// Prefer the free-trial offer when [preferFreeTrial] is true.
  ProductDetails? getProductById(
    String productId, {
    bool preferFreeTrial = true,
  }) {
    ProductDetails? fallback;
    for (final p in _products) {
      if (p.id != productId) continue;
      fallback ??= p;
      if (preferFreeTrial &&
          p is GooglePlayProductDetails &&
          _offerHasFreeTrial(p)) {
        return p;
      }
    }
    return fallback;
  }

  ProductDetails? getWeeklySubscription({bool preferFreeTrial = false}) {
    return getProductById(
      _productIdResolver.getWeeklySubscriptionId(),
      preferFreeTrial: preferFreeTrial,
    );
  }

  ProductDetails? getMonthlySubscription({bool preferFreeTrial = false}) {
    return getProductById(
      _productIdResolver.getMonthlySubscriptionId(),
      preferFreeTrial: preferFreeTrial,
    );
  }

  ProductDetails? getYearlySubscription({bool preferFreeTrial = true}) {
    return getProductById(
      _productIdResolver.getYearlySubscriptionId(),
      preferFreeTrial: preferFreeTrial,
    );
  }

  ProductDetails? getLifetimeProduct() {
    return getProductById(
      _productIdResolver.getLifetimeProductId(),
      preferFreeTrial: false,
    );
  }

  ProductDetails? getCreditsPackProduct() {
    return getProductById(
      _productIdResolver.getCreditsPackProductId(),
      preferFreeTrial: false,
    );
  }

  String? getCreditsPackPrice() =>
      localizedPriceFor(_productIdResolver.getCreditsPackProductId());

  /// Diginotes-style listed pack price (sale + optional strikethrough / %).
  ///
  /// First pack purchase: cheapest eligible offer + strikethrough/% badge,
  /// and that offer token is sent to Play on buy.
  /// After a successful buy, [CreditService.hasPurchasedPackBefore] gates the
  /// discount off even if Play still returns a cheaper option.
  CreditsPackListedPrice getCreditsPackListedPrice() {
    final productId = _productIdResolver.getCreditsPackProductId();
    final payable = localizedPriceFor(productId)?.trim();
    final hasStorePrice = payable != null &&
        payable.isNotEmpty &&
        !_isFreePriceText(payable);

    if (!hasStorePrice) {
      return const CreditsPackListedPrice(
        salePrice: '--',
        regularPrice: '--',
        discountPercent: 0,
      );
    }

    final sale = payable;

    if (CreditService.instance.hasPurchasedPackBefore) {
      return CreditsPackListedPrice(
        salePrice: sale,
        regularPrice: sale,
        discountPercent: 0,
      );
    }

    return _creditsPackCompareAt(productId) ??
        CreditsPackListedPrice(
          salePrice: sale,
          regularPrice: sale,
          discountPercent: 0,
        );
  }

  CreditsPackListedPrice? _creditsPackCompareAt(String productId) {
    _NativeOneTimeOffer? cheapest;
    _NativeOneTimeOffer? highest;

    for (final offer in _nativePackOffers) {
      if (offer.priceAmountMicros <= 0) continue;
      highest ??= offer;
      if (offer.priceAmountMicros > highest.priceAmountMicros) highest = offer;
      if (cheapest == null ||
          offer.priceAmountMicros < cheapest.priceAmountMicros ||
          (offer.priceAmountMicros == cheapest.priceAmountMicros &&
              offer.hasToken &&
              !cheapest.hasToken)) {
        cheapest = offer;
      }
    }

    // Plugin fallback (0.5.x exposes offer list; tokens still come from native).
    if (cheapest == null || highest == null) {
      final product = getProductById(productId, preferFreeTrial: false);
      if (product is! GooglePlayProductDetails) return null;
      final defaultOffer = product.productDetails.oneTimePurchaseOfferDetails;
      final wrappers = <OneTimePurchaseOfferDetailsWrapper>[
        ...?product.productDetails.oneTimePurchaseOfferDetailsList,
        ?defaultOffer,
      ];
      OneTimePurchaseOfferDetailsWrapper? cheapWrap;
      OneTimePurchaseOfferDetailsWrapper? highWrap;
      for (final offer in wrappers) {
        if (offer.priceAmountMicros <= 0) continue;
        cheapWrap ??= offer;
        highWrap ??= offer;
        if (offer.priceAmountMicros < cheapWrap.priceAmountMicros) {
          cheapWrap = offer;
        }
        if (offer.priceAmountMicros > highWrap.priceAmountMicros) {
          highWrap = offer;
        }
      }
      if (cheapWrap == null || highWrap == null) return null;
      cheapest = _NativeOneTimeOffer(
        formattedPrice: cheapWrap.formattedPrice,
        priceAmountMicros: cheapWrap.priceAmountMicros,
      );
      highest = _NativeOneTimeOffer(
        formattedPrice: highWrap.formattedPrice,
        priceAmountMicros: highWrap.priceAmountMicros,
      );
    }

    if (highest.priceAmountMicros <= cheapest.priceAmountMicros) {
      return null;
    }

    // Don't advertise a cheaper price unless we can send its offer token.
    if (!cheapest.hasToken) return null;

    final percent = (((highest.priceAmountMicros - cheapest.priceAmountMicros) /
                highest.priceAmountMicros) *
            100)
        .round()
        .clamp(1, 90);
    final sale = cheapest.formattedPrice.trim();
    final regular = highest.formattedPrice.trim();
    if (sale.isEmpty || regular.isEmpty || sale == regular) return null;
    return CreditsPackListedPrice(
      salePrice: sale,
      regularPrice: regular,
      discountPercent: percent,
      offerToken: cheapest.offerToken,
    );
  }

  /// Consumable credit pack — does not grant premium / subscription.
  Future<bool> purchaseCreditsPack({String? offerToken}) async {
    if (!_isAvailable) return false;
    if (_products.isEmpty) await _loadProducts();
    await _refreshNativePackOffers(
      force: _nativePackOffers.isEmpty ||
          !_nativePackOffers.any((offer) => offer.hasToken),
    );

    final product = getCreditsPackProduct();
    if (product == null) return false;

    final listed = getCreditsPackListedPrice();
    final buyToken = (offerToken ?? listed.offerToken)?.trim();

    return _purchaseConsumableProduct(
      product: product,
      offerToken: buyToken,
      logName: 'purchaseCreditsPack',
      logDetail:
          'hasDiscount=${listed.hasDiscount} sale=${listed.salePrice} '
          'regular=${listed.regularPrice} '
          'tokenPresent=${buyToken != null && buyToken.isNotEmpty}',
    );
  }

  ProductDetails? getDownloadInappProduct({required bool isAab}) {
    return getProductById(
      _productIdResolver.getDownloadInappProductId(isAab: isAab),
      preferFreeTrial: false,
    );
  }

  String? getDownloadInappPrice({required bool isAab}) => localizedPriceFor(
        _productIdResolver.getDownloadInappProductId(isAab: isAab),
      );

  /// Consumable Download APK / AAB pack — grants credits, not premium.
  Future<bool> purchaseDownloadInapp({required bool isAab}) async {
    if (!_isAvailable) return false;
    if (_products.isEmpty) await _loadProducts();

    final product = getDownloadInappProduct(isAab: isAab);
    if (product == null) return false;

    final productId =
        _productIdResolver.getDownloadInappProductId(isAab: isAab);
    return _purchaseConsumableProduct(
      product: product,
      offerToken: null,
      logName: 'purchaseDownloadInapp',
      logDetail: 'productId=$productId',
    );
  }

  Future<bool> _purchaseConsumableProduct({
    required ProductDetails product,
    required String? offerToken,
    required String logName,
    required String logDetail,
  }) async {
    lastPurchaseCancelledByUser = false;
    try {
      if (Platform.isIOS) {
        try {
          final result = await SK2Product.purchase(product.id);
          switch (result) {
            case SK2ProductPurchaseResult.userCancelled:
              lastPurchaseCancelledByUser = true;
              return false;
            case SK2ProductPurchaseResult.unverified:
              return false;
            case SK2ProductPurchaseResult.pending:
            case SK2ProductPurchaseResult.success:
              return true;
          }
        } catch (e) {
          developer.log(
            'SK2 $logName failed, falling back to buyConsumable: $e',
            name: 'PremiumService',
          );
        }
      }

      PurchaseParam purchaseParam;
      if (Platform.isAndroid && product is GooglePlayProductDetails) {
        final token = (offerToken != null && offerToken.isNotEmpty)
            ? offerToken
            : product.offerToken?.trim();
        purchaseParam = (token != null && token.isNotEmpty)
            ? GooglePlayPurchaseParam(
                productDetails: product,
                offerToken: token,
              )
            : PurchaseParam(productDetails: product);
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      developer.log('$logName $logDetail', name: 'PackIAP');

      return _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    } catch (_) {
      return false;
    }
  }

  /// Store-localized recurring price (skips free-trial $0 intro phase).
  String? localizedPriceFor(String productId) {
    final paidProduct = getProductById(productId, preferFreeTrial: false);
    final fromPaid = _priceFromProduct(paidProduct);
    if (fromPaid != null) return fromPaid;

    final trialProduct = getProductById(productId, preferFreeTrial: true);
    return _priceFromProduct(trialProduct);
  }

  String? getWeeklyPrice() =>
      localizedPriceFor(_productIdResolver.getWeeklySubscriptionId());

  String? getMonthlyPrice() =>
      localizedPriceFor(_productIdResolver.getMonthlySubscriptionId());

  String? getYearlyPrice() =>
      localizedPriceFor(_productIdResolver.getYearlySubscriptionId());

  String? getLifetimePrice() => _priceFromProduct(getLifetimeProduct());

  bool hasFreeTrial(String productId) {
    final product = getProductById(productId);
    if (product == null) return false;

    if (product is GooglePlayProductDetails) {
      return _androidFreeTrialPhase(product) != null;
    }
    if (product is AppStoreProductDetails) {
      final intro = product.skProduct.introductoryPrice;
      return intro != null &&
          intro.paymentMode == SKProductDiscountPaymentMode.freeTrail;
    }
    if (product is AppStoreProduct2Details) {
      final offers = product.sk2Product.subscription?.promotionalOffers;
      if (offers == null) return false;
      return offers.any(
        (o) =>
            o.type == SK2SubscriptionOfferType.introductory &&
            o.paymentMode == SK2SubscriptionOfferPaymentMode.freeTrial,
      );
    }
    return false;
  }

  bool hasYearlyFreeTrial() =>
      hasFreeTrial(_productIdResolver.getYearlySubscriptionId());

  bool hasWeeklyFreeTrial() =>
      hasFreeTrial(_productIdResolver.getWeeklySubscriptionId());

  String? _priceFromProduct(ProductDetails? product) {
    if (product == null) return null;

    if (product is GooglePlayProductDetails) {
      final phase = _recurringPhaseForProduct(product);
      if (phase != null) {
        final formatted = phase.formattedPrice.trim();
        if (formatted.isNotEmpty && !_isFreePriceText(formatted)) {
          return formatted;
        }
      }
    }

    final price = product.price.trim();
    if (price.isNotEmpty &&
        !_isFreePriceText(price, rawPrice: product.rawPrice)) {
      return price;
    }
    return null;
  }

  PricingPhaseWrapper? _recurringPhaseForProduct(
    GooglePlayProductDetails product,
  ) {
    final offers = product.productDetails.subscriptionOfferDetails;
    if (offers == null || offers.isEmpty) return null;

    final index = product.subscriptionIndex;
    if (index != null && index >= 0 && index < offers.length) {
      for (final phase in offers[index].pricingPhases) {
        if (phase.priceAmountMicros > 0) return phase;
      }
    }

    for (final offer in offers) {
      for (final phase in offer.pricingPhases) {
        if (phase.priceAmountMicros > 0) return phase;
      }
    }
    return null;
  }

  bool _offerHasFreeTrial(GooglePlayProductDetails product) {
    final index = product.subscriptionIndex;
    final offers = product.productDetails.subscriptionOfferDetails;
    if (index == null || offers == null || index >= offers.length) {
      return false;
    }
    return offers[index].pricingPhases.any((p) => p.priceAmountMicros <= 0);
  }

  PricingPhaseWrapper? _androidFreeTrialPhase(
    GooglePlayProductDetails product,
  ) {
    final offers = product.productDetails.subscriptionOfferDetails;
    if (offers == null) return null;
    for (final offer in offers) {
      for (final phase in offer.pricingPhases) {
        if (phase.priceAmountMicros <= 0) return phase;
      }
    }
    return null;
  }

  bool _isFreePriceText(String text, {double rawPrice = -1}) {
    if (rawPrice >= 0 && rawPrice <= 0) return true;
    final lower = text.toLowerCase().trim();
    if (lower.isEmpty || lower == 'null') return true;
    if (lower.contains('free')) return true;
    if (RegExp(r'^[\$€£₹]?\s*0([.,]0+)?$').hasMatch(lower)) return true;
    return false;
  }

  Future<bool> _startStorePurchase(ProductDetails product) async {
    lastPurchaseCancelledByUser = false;

    try {
      if (Platform.isIOS) {
        try {
          final result = await SK2Product.purchase(product.id);
          switch (result) {
            case SK2ProductPurchaseResult.userCancelled:
              lastPurchaseCancelledByUser = true;
              return false;
            case SK2ProductPurchaseResult.unverified:
              return false;
            case SK2ProductPurchaseResult.pending:
            case SK2ProductPurchaseResult.success:
              return true;
          }
        } catch (e) {
          developer.log(
            'SK2 purchase failed, falling back to buyNonConsumable: $e',
            name: 'PremiumService',
          );
        }
      }

      PurchaseParam purchaseParam;
      if (Platform.isAndroid && product is GooglePlayProductDetails) {
        final token = product.offerToken?.trim();
        purchaseParam = (token != null && token.isNotEmpty)
            ? GooglePlayPurchaseParam(
                productDetails: product,
                offerToken: token,
              )
            : PurchaseParam(productDetails: product);
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {
      return false;
    }
  }

  Future<bool> purchaseWeeklySubscription() async {
    if (!_isAvailable) return false;
    if (_products.isEmpty) await _loadProducts();

    // Weekly has no trial CTA — buy the paid base offer.
    final product = getWeeklySubscription(preferFreeTrial: false);
    if (product == null) return false;

    return _startStorePurchase(product);
  }

  Future<bool> purchaseMonthlySubscription() async {
    if (!_isAvailable) return false;
    if (_products.isEmpty) await _loadProducts();

    final product = getMonthlySubscription(preferFreeTrial: false);
    if (product == null) return false;

    return _startStorePurchase(product);
  }

  Future<bool> purchaseYearlySubscription() async {
    if (!_isAvailable) return false;
    if (_products.isEmpty) await _loadProducts();

    // Prefer trial offer when Play returns one for yearly.
    final product = getYearlySubscription(preferFreeTrial: true);
    if (product == null) return false;

    return _startStorePurchase(product);
  }

  Future<bool> purchaseLifetime() async {
    if (!_isAvailable) return false;
    if (_products.isEmpty) await _loadProducts();

    final product = getLifetimeProduct();
    if (product == null) return false;

    return _startStorePurchase(product);
  }

  Future<bool> restorePurchasesAndWait({
    Duration timeout = const Duration(seconds: 15),
  }) {
    return _activeRestoreFuture ??= _restorePurchasesAndWaitImpl(timeout);
  }

  Future<bool> _restorePurchasesAndWaitImpl(Duration timeout) async {
    await _ensureInitialized();

    if (!_isAvailable) return isPremiumUser();

    final cachedExpiryMs = _prefs?.getInt(_premiumExpiryKey);
    if (cachedExpiryMs != null &&
        DateTime.now().millisecondsSinceEpoch >= cachedExpiryMs) {
      await _revokePremium();
      return false;
    }

    var foundActiveSubscription = false;

    void onPurchaseUpdate(PurchaseStatus status, PurchaseDetails? purchase) {
      if (purchase == null) return;
      if (status != PurchaseStatus.purchased &&
          status != PurchaseStatus.restored) {
        return;
      }
      if (_isPurchaseCurrentlyActive(purchase)) {
        foundActiveSubscription = true;
      }
    }

    addPurchaseStatusCallback(onPurchaseUpdate);

    try {
      await _iap.restorePurchases().timeout(timeout);

      if (Platform.isIOS) {
        final deadline = DateTime.now().add(const Duration(milliseconds: 800));
        while (!foundActiveSubscription && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }

      if (Platform.isAndroid) {
        final storePurchases = await _queryActivePurchasesFromStore().timeout(
          const Duration(seconds: 5),
        );
        foundActiveSubscription =
            storePurchases.any(_isPurchaseCurrentlyActive);
        if (foundActiveSubscription) {
          final active = storePurchases.firstWhere(_isPurchaseCurrentlyActive);
          await _persistPremiumFromPurchase(active);
        }
      }

      if (foundActiveSubscription) {
        // iOS may set the flag from the stream before prefs are written.
        if (!isPremiumUser()) {
          final deadline = DateTime.now().add(const Duration(milliseconds: 600));
          while (!isPremiumUser() && DateTime.now().isBefore(deadline)) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
        }
        _notifySessionPremiumChanged();
        return true;
      }

      await _revokePremium();
      return false;
    } on TimeoutException {
      return isPremiumUser();
    } catch (_) {
      return isPremiumUser();
    } finally {
      removePurchaseStatusCallback(onPurchaseUpdate);
    }
  }

  Future<bool> restorePurchases() => restorePurchasesAndWait();

  bool get isReady => _isAvailable && _products.isNotEmpty;

  bool get isLoading => _isAvailable && _products.isEmpty;

  bool get isAvailable => _isAvailable;

  List<ProductDetails> get products => _products;

  void dispose() {
    _purchaseSubscription?.cancel();
  }
}
