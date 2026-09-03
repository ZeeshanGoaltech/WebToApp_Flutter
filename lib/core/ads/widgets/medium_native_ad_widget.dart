import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/ad_service.dart';
import 'package:web_to_app/core/ads/ads_consent_gate.dart';
import 'package:web_to_app/core/ads/native_ad_load_gate.dart';
import 'package:web_to_app/core/ads/native_ad_sizes.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Medium native ad.
///
/// Language / onboarding use Nail Art layouts (`mediumfullCTA` /
/// `select_currency_medium`). Other placements keep the legacy `mediumAd` factory.
class MediumNativeAdWidget extends StatefulWidget {
  const MediumNativeAdWidget({
    super.key,
    required this.placementId,
    this.height,
    this.factoryId,
    this.reserveSpaceWhileLoading = true,
    this.includeOuterPadding = true,
    this.onVisibilityChanged,
  });

  final String placementId;
  final double? height;

  /// Override Android [NativeAd.factoryId]. When null, resolved from [placementId].
  final String? factoryId;

  /// When false, the slot collapses until the ad successfully loads.
  final bool reserveSpaceWhileLoading;

  /// When false, skips outer horizontal/vertical padding (for in-list placement).
  final bool includeOuterPadding;

  /// Called with `true` when a loaded ad is shown, `false` when hidden.
  final ValueChanged<bool>? onVisibilityChanged;

  @override
  State<MediumNativeAdWidget> createState() => _MediumNativeAdWidgetState();
}

class _MediumNativeAdWidgetState extends State<MediumNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoading = true;
  bool _shouldShow = true;
  int _instanceId = 0;

  bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  bool get _isNailArtLayout =>
      widget.placementId == AdPlacements.languageNative ||
      widget.placementId == AdPlacements.onboardingNative;

  String get _resolvedFactoryId {
    if (widget.factoryId != null) return widget.factoryId!;
    return switch (widget.placementId) {
      AdPlacements.languageNative => NativeAdSizes.mediumFullCtaFactory,
      AdPlacements.onboardingNative => NativeAdSizes.selectCurrencyMediumFactory,
      _ => NativeAdSizes.mediumFactory,
    };
  }

  double _slotHeight(BuildContext context) {
    if (widget.height != null) return widget.height!;
    return switch (widget.placementId) {
      AdPlacements.languageNative => NativeAdSizes.mediumFullCta,
      AdPlacements.onboardingNative => NativeAdSizes.selectCurrencyMedium,
      _ => () {
          final width = MediaQuery.sizeOf(context).width;
          if (Platform.isAndroid) {
            if (width > 600) return 196.0;
            if (width >= 360) return 176.0;
            return 172.0;
          }
          if (width < 360) return 160.0;
          if (width > 600) return 196.0;
          return 176.0;
        }(),
    };
  }

  @override
  void initState() {
    super.initState();
    if (_isPremium) {
      _shouldShow = false;
      _isLoading = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Brief idle so first taps after navigation are not competing with
      // AdMob WebView loadUrl on the main thread (Input dispatching ANR).
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 350), () {
          if (mounted) unawaited(_loadAd());
        }),
      );
    });
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (_nativeAd != null) return;

    if (_isPremium) {
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
        widget.onVisibilityChanged?.call(false);
      }
      return;
    }

    await NativeAdLoadGate.run(_loadAdBody);
  }

  Future<void> _loadAdBody() async {
    if (!mounted || _nativeAd != null) return;

    if (_isPremium) {
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
        widget.onVisibilityChanged?.call(false);
      }
      return;
    }

    if (!AdService.instance.isInitialized) {
      await AdService.instance.initialize();
    }

    if (!mounted) return;

    if (!AdsConsentGate.mayRequestAds) {
      developer.log('[MediumNative] UMP blocked ads');
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
        widget.onVisibilityChanged?.call(false);
      }
      return;
    }

    if (!AdConfig.isEnabled(widget.placementId)) {
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
        widget.onVisibilityChanged?.call(false);
      }
      return;
    }

    final adUnitId = AdConfig.unitIdFor(widget.placementId);
    if (adUnitId == null || adUnitId.isEmpty) {
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
        widget.onVisibilityChanged?.call(false);
      }
      return;
    }

    final factoryId = _resolvedFactoryId;
    developer.log(
      '[MediumNative] loading ${widget.placementId} → $adUnitId '
      '(factory=${Platform.isAndroid ? factoryId : 'TemplateType.medium'})',
    );

    if (mounted) {
      setState(() {
        _isLoading = true;
        _shouldShow = true;
      });
    }

    final completer = Completer<NativeAd?>();
    final timeout = kReleaseMode ? 20 : 15;

    final NativeAd nativeAd;
    if (Platform.isAndroid) {
      nativeAd = NativeAd(
        adUnitId: adUnitId,
        factoryId: factoryId,
        request: const AdRequest(),
        nativeAdOptions: NativeAdOptions(
          videoOptions: VideoOptions(
            startMuted: true,
            clickToExpandRequested: false,
          ),
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
          mediaAspectRatio: MediaAspectRatio.any,
        ),
        listener: _listener(completer),
      );
    } else {
      nativeAd = NativeAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          mainBackgroundColor: const Color(0xFFF4EEE8),
          cornerRadius: 16,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF00C853),
            style: NativeTemplateFontStyle.bold,
            size: 14,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black,
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.bold,
            size: 16,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF666666),
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.normal,
            size: 13,
          ),
        ),
        nativeAdOptions: NativeAdOptions(
          videoOptions: VideoOptions(
            startMuted: true,
            clickToExpandRequested: false,
          ),
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
          mediaAspectRatio: MediaAspectRatio.any,
        ),
        listener: _listener(completer),
      );
    }

    nativeAd.load();

    final loaded = await completer.future.timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        developer.log('[MediumNative] timeout ${widget.placementId}');
        nativeAd.dispose();
        return null;
      },
    );

    if (!mounted) {
      loaded?.dispose();
      return;
    }

    setState(() {
      if (loaded != null) {
        _nativeAd?.dispose();
        _nativeAd = loaded;
        _instanceId++;
        _isLoading = false;
        _shouldShow = true;
      } else {
        _isLoading = false;
        _shouldShow = false;
      }
    });
    widget.onVisibilityChanged?.call(loaded != null);
  }

  NativeAdListener _listener(Completer<NativeAd?> completer) {
    return NativeAdListener(
      onAdLoaded: (ad) {
        developer.log('[MediumNative] loaded ${widget.placementId}');
        if (!completer.isCompleted) completer.complete(ad as NativeAd);
      },
      onAdFailedToLoad: (ad, error) {
        developer.log(
          '[MediumNative] failed ${widget.placementId}: '
          '${error.code} ${error.message}',
        );
        ad.dispose();
        if (!completer.isCompleted) completer.complete(null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPremium) {
      return const SizedBox.shrink();
    }

    final showSlot = _shouldShow &&
        (_nativeAd != null || (widget.reserveSpaceWhileLoading && _isLoading));

    if (!showSlot) {
      return const SizedBox.shrink();
    }

    final height = _slotHeight(context);
    // Nail Art: light horizontal inset; layout owns cream card chrome.
    final horizontal = !widget.includeOuterPadding
        ? 0.0
        : (_isNailArtLayout ? 3.0 : Responsive.w(context, 16));
    final vertical = !widget.includeOuterPadding
        ? 0.0
        : (_isNailArtLayout ? 8.0 : Responsive.h(context, 8));

    final child = _isLoading || _nativeAd == null
        ? Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isNailArtLayout
                      ? const Color(0xFF00C853)
                      : AppColors.primary,
                ),
              ),
            ),
          )
        : AdWidget(
            key: ValueKey('native_${widget.placementId}_$_instanceId'),
            ad: _nativeAd!,
          );

    if (_isNailArtLayout) {
      return Padding(
        padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: ClipRect(child: child),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(Responsive.r(context, 10)),
          border: Border.all(
            color: const Color(0xFFE0E3E7),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
