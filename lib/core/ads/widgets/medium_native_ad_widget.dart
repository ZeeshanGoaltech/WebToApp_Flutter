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
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Medium native ad — Android uses custom [factoryId] `mediumAd` (Ummah layout).
/// iOS falls back to [TemplateType.medium].
class MediumNativeAdWidget extends StatefulWidget {
  const MediumNativeAdWidget({
    super.key,
    required this.placementId,
    this.height,
    this.reserveSpaceWhileLoading = true,
    this.includeOuterPadding = true,
    this.onVisibilityChanged,
  });

  final String placementId;
  final double? height;

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
  static const String _factoryId = 'mediumAd';
  static const double _androidHeight = 176;

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

  double _slotHeight(BuildContext context) {
    if (widget.height != null) return widget.height!;
    final width = MediaQuery.sizeOf(context).width;
    if (Platform.isAndroid) {
      if (width > 600) return 196;
      if (width >= 360) return 176;
      return 172;
    }
    if (width < 360) return 160;
    if (width > 600) return 196;
    return 176;
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

    developer.log(
      '[MediumNative] loading ${widget.placementId} → $adUnitId '
      '(factory=${Platform.isAndroid ? _factoryId : 'TemplateType.medium'})',
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
        factoryId: _factoryId,
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
          mainBackgroundColor: const Color(0xFFF1F3F4),
          cornerRadius: 10,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF1A73E8),
            style: NativeTemplateFontStyle.bold,
            size: 15,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF202124),
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.bold,
            size: 16,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF3C4043),
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
    final horizontal =
        widget.includeOuterPadding ? Responsive.w(context, 16) : 0.0;
    final vertical =
        widget.includeOuterPadding ? Responsive.h(context, 8) : 0.0;
    final bg = const Color(0xFFF1F3F4);

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Responsive.r(context, 10)),
          border: Border.all(
            color: const Color(0xFFE0E3E7),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _isLoading || _nativeAd == null
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              )
            : AdWidget(
                key: ValueKey('native_${widget.placementId}_$_instanceId'),
                ad: _nativeAd!,
              ),
      ),
    );
  }
}
