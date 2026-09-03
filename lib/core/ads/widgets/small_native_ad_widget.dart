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

/// Small native ad — Android uses custom [factoryId] `smallAd` (Ummah layout).
/// iOS falls back to [TemplateType.small].
class SmallNativeAdWidget extends StatefulWidget {
  const SmallNativeAdWidget({
    super.key,
    required this.placementId,
    this.height,
    this.includeOuterPadding = true,
  });

  final String placementId;
  final double? height;

  /// When false, skips the default outer margin (use inside already-padded lists).
  final bool includeOuterPadding;

  @override
  State<SmallNativeAdWidget> createState() => _SmallNativeAdWidgetState();
}

class _SmallNativeAdWidgetState extends State<SmallNativeAdWidget> {
  static const String _factoryId = 'smallAd';
  static const double _androidHeight = 76;

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
    if (Platform.isAndroid) return _androidHeight;
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 75;
    if (width > 600) return 90;
    return 82;
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
      }
      return;
    }

    if (!AdService.instance.isInitialized) {
      await AdService.instance.initialize();
    }

    if (!mounted) return;

    if (!AdsConsentGate.mayRequestAds) {
      developer.log('[SmallNative] UMP blocked ads');
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (!AdConfig.isEnabled(widget.placementId)) {
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
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
      }
      return;
    }

    developer.log(
      '[SmallNative] loading ${widget.placementId} → $adUnitId '
      '(factory=${Platform.isAndroid ? _factoryId : 'TemplateType.small'})',
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
          templateType: TemplateType.small,
          mainBackgroundColor: const Color(0xFFE8F5E9),
          cornerRadius: 0,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF2E8B57),
            style: NativeTemplateFontStyle.bold,
            size: 12,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF374151),
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.bold,
            size: 13,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF4B5563),
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.normal,
            size: 11,
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
        developer.log('[SmallNative] timeout ${widget.placementId}');
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
  }

  NativeAdListener _listener(Completer<NativeAd?> completer) {
    return NativeAdListener(
      onAdLoaded: (ad) {
        developer.log('[SmallNative] loaded ${widget.placementId}');
        if (!completer.isCompleted) completer.complete(ad as NativeAd);
      },
      onAdFailedToLoad: (ad, error) {
        developer.log(
          '[SmallNative] failed ${widget.placementId}: '
          '${error.code} ${error.message}',
        );
        ad.dispose();
        if (!completer.isCompleted) completer.complete(null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPremium || (!_shouldShow && !_isLoading)) {
      return const SizedBox.shrink();
    }

    final height = _slotHeight(context);
    final horizontal =
        widget.includeOuterPadding ? Responsive.w(context, 16) : 0.0;
    final vertical =
        widget.includeOuterPadding ? Responsive.h(context, 8) : 0.0;
    final bg = const Color(0xFFE8F5E9);

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Responsive.r(context, 4)),
          border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: _isLoading || _nativeAd == null
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              )
            : AdWidget(
                key: ValueKey(
                  'small_native_${widget.placementId}_$_instanceId',
                ),
                ad: _nativeAd!,
              ),
      ),
    );
  }
}
