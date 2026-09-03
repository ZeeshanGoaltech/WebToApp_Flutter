import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/constants/app_info.dart';
import 'package:web_to_app/core/services/analytics_service.dart';
import 'package:web_to_app/core/services/credit_service.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/modules/iap/widgets/iap_close_button.dart';

/// Diginotes `module_paywall_screen` port — consumable credits pack paywall.
class CreditsPackBinding extends Bindings {
  @override
  void dependencies() {}
}

class CreditsPackView extends StatefulWidget {
  const CreditsPackView({super.key});

  @override
  State<CreditsPackView> createState() => _CreditsPackViewState();
}

class _CreditsPackViewState extends State<CreditsPackView> {
  // Figma Screen3 palette on Diginotes layout.
  static const Color _accent = Color(0xFF6A69D3);
  static const Color _accentSoft = Color(0xFF7B7AD8);
  static const Color _page = Color(0xFFFFFFFF);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFE8E4F0);
  static const Color _text = Color(0xFF101828);
  static const Color _subText = Color(0xFF6A7282);
  static const Color _muted = Color(0xFF99A1AF);
  static const Color _accentLight = Color(0xFFEEEEFC);
  static const LinearGradient _iconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA49CF3), Color(0xFF7878ED)],
  );

  String _salePrice = '--';
  String _regularPrice = '--';
  int _discountPercent = 0;
  bool _discountEligible = false;
  String? _offerToken;
  bool _purchasing = false;
  bool _finishing = false;
  late int _creditsWhenOpened;
  PremiumService? _premium;

  int get packCredits => CreditService.instance.packCredits;

  @override
  void initState() {
    super.initState();
    AdPresentationGate.markIapOpened();
    AppOpenAdManager.instance.blockAppOpenAds = true;
    unawaited(AnalyticsService.instance.logCreditsPackOpen());
    _creditsWhenOpened = CreditService.instance.paidCredits.value;
    CreditService.instance.paidCredits.addListener(_onCreditsChanged);
    unawaited(_loadPrice());
  }

  @override
  void dispose() {
    CreditService.instance.paidCredits.removeListener(_onCreditsChanged);
    AdPresentationGate.markIapClosed();
    AdPresentationGate.reconcileIapVisibility();
    AppOpenAdManager.instance.blockNextResume();
    AppOpenAdManager.instance.blockAppOpenAds =
        AdPresentationGate.isOnIapRoute;
    super.dispose();
  }

  void _onCreditsChanged() {
    final now = CreditService.instance.paidCredits.value;
    if (now <= _creditsWhenOpened) return;
    unawaited(_showSuccessAndFinish());
  }

  Future<void> _loadPrice() async {
    debugPrint('[PackIAP] credits paywall opened');
    _premium = await PremiumService.getInstance();
    await CreditService.instance.initialize();
    await _premium!.ensureProductsLoaded();
    _refreshPrices();
    await _premium!.reloadProducts();
    _refreshPrices();
    // Credits-only native multi-offer pass (does not touch subscription catalog).
    await _premium!.refreshCreditsPackOffers(force: true);
    _refreshPrices();
    debugPrint(
      '[PackIAP] listed sale=$_salePrice regular=$_regularPrice '
      'percent=$_discountPercent eligible=$_discountEligible '
      'token=${_offerToken != null && _offerToken!.isNotEmpty}',
    );
  }

  void _refreshPrices() {
    if (!mounted || _premium == null) return;
    final listed = _premium!.getCreditsPackListedPrice();
    setState(() {
      _salePrice = listed.salePrice;
      _regularPrice = listed.regularPrice;
      _discountPercent = listed.discountPercent;
      _discountEligible = listed.hasDiscount;
      _offerToken = listed.offerToken;
    });
  }

  Future<void> _purchase() async {
    if (_purchasing || _finishing) return;
    if (_salePrice == '--') {
      _showPurchaseError();
      return;
    }
    setState(() => _purchasing = true);
    try {
      _premium ??= await PremiumService.getInstance();
      await _premium!.ensureProductsLoaded();
      await _premium!.reloadProducts();
      _refreshPrices();

      final started = await _premium!.purchaseCreditsPack(
        offerToken: _offerToken,
      );
      if (!mounted) return;
      if (!started) {
        if (_premium!.lastPurchaseCancelledByUser) return;
        _showPurchaseError();
        return;
      }
      // Delivery also arrives via paidCredits listener.
    } catch (_) {
      if (mounted) _showPurchaseError();
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _showSuccessAndFinish() async {
    if (_finishing || !mounted) return;
    _finishing = true;
    await _showSuccessDialog();
    if (mounted) Get.back(result: true);
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF48BB78).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF48BB78),
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'common_success'.tr,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'credits_pack_purchase_success'.tr,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _subText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'common_ok'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPurchaseError() {
    AppToast.error('credits_pack_purchase_failed'.tr);
  }

  Future<void> _showCancelInfo() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('iap_cancel_anytime'.tr),
          content: Text('premium_cancel_info_body'.tr),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('common_ok'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    AppOpenAdManager.instance.blockNextResume();
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    AppOpenAdManager.instance.blockNextResume();
    if (!ok && mounted) {
      AppToast.info('request_failed'.tr, description: url);
    }
  }

  String get _ctaLabel => 'credits_pack_unlock_cta'.trParams({
        'count': '$packCredits',
        'unit': 'credits_pack_unit'.tr,
      });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1,
      maxScaleFactor: 1,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: _page,
        ),
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: _page,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final contentHeight = constraints.maxHeight - bottomInset;
                final heroHeight = contentHeight * 0.35;
                final closeScale = IapCloseButton.scaleOf(context);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              _buildHero(height: heroHeight),
                              Expanded(
                                child: CustomScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  slivers: [
                                    SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildTitle(),
                                            _buildPackCard(),
                                            _buildPurchaseCard(),
                                            _buildFooter(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                              top: topInset +
                                  IapCloseButton.designTop * closeScale -
                                  2,
                              left: (constraints.maxWidth -
                                          IapCloseButton.designW *
                                              closeScale) /
                                      2 +
                                  IapCloseButton.designLeft * closeScale,
                              child: IapCloseButton(
                                onTap: () => Get.back(result: false),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ColoredBox(
                      color: _page,
                      child: SizedBox(height: bottomInset),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero({required double height}) {
    // Match subscription IAP hero framing: slight scale-up + shift up.
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(0, -height * 0.0521),
          child: SizedBox(
            height: height * 1.0521,
            width: double.infinity,
            child: Image.asset(
              AppAssets.iapThreePacks,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) => Container(
                color: _accentLight,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.phone_android_rounded,
                  size: 64,
                  color: _accent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              color: _text,
              fontSize: 32,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(text: '${'credits_paywall_get'.tr} '),
              TextSpan(
                text: 'credits_paywall_premium'.tr,
                style: GoogleFonts.inter(
                  color: _accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: ' ${'credits_paywall_access'.tr}'),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          'credits_pack_subtitle'.tr,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: _subText,
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: _border, width: 1.1),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: _iconGradient,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppAssets.creditsPackCrown,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (_) => const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'credits_pack_card_title'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'credits_pack_card_desc'.tr,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _subText,
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildCreditsBadge(),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: _border, height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accent, width: 1.1),
                ),
                child: Text(
                  'i',
                  style: GoogleFonts.inter(
                    color: _accentSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${'credits_pack_info_start'.tr} '),
                      TextSpan(
                        text: 'credits_pack_info_bold'.trParams({
                          'count': '$packCredits',
                        }),
                        style: GoogleFonts.inter(
                          color: _accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      TextSpan(text: ' ${'credits_pack_info_end'.tr}'),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _subText,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsBadge() {
    return Container(
      width: 82,
      decoration: BoxDecoration(
        color: _accentLight,
        border: Border.all(color: _border, width: 1.1),
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
                child: Column(
                  children: [
                    Text(
                      '$packCredits',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _accent,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'credits_pack_badge_unit'.tr,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _text,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: _accent,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'credits_pack_one_time'.tr,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            left: 6,
            child: SvgPicture.asset(
              AppAssets.creditsPackCrown,
              width: 14,
              height: 14,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFF8A3D),
                BlendMode.srcIn,
              ),
              placeholderBuilder: (_) => const Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFFFF8A3D),
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard() {
    return GestureDetector(
      onTap: (_purchasing || _salePrice == '--') ? null : _purchase,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: _card,
          border: Border.all(color: _border, width: 1.1),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _salePrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: _accent,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_discountEligible) ...[
                    const SizedBox(width: 11),
                    Text(
                      _regularPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _muted,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_discountEligible) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: _accentLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'credits_pack_discount'.trParams({
                    'percent': '$_discountPercent',
                  }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (_purchasing || _salePrice == '--')
                      ? null
                      : _purchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _purchasing
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _ctaLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final style = GoogleFonts.inter(
      color: _subText,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    final pipeStyle = GoogleFonts.inter(
      color: const Color(0xFF737373),
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => _openUrl(AppInfo.termsAndConditionsUrl),
            child: Text(
              'iap_terms_of_use'.tr,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Text('   |   ', style: pipeStyle),
        Flexible(
          child: GestureDetector(
            onTap: _showCancelInfo,
            child: Text(
              'iap_cancel_anytime'.tr,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Text('   |   ', style: pipeStyle),
        Flexible(
          child: GestureDetector(
            onTap: () => _openUrl(AppInfo.privacyPolicyUrl),
            child: Text(
              'privacy_policy'.tr,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
