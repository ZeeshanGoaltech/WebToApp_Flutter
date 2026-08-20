import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/ad_remote_config_service.dart';
import 'package:web_to_app/core/ads/ad_service.dart';
import 'package:web_to_app/core/ads/ads_consent_gate.dart';
import 'package:web_to_app/core/ads/interstitial_ad_trigger.dart';
import 'package:web_to_app/core/constants/app_debug_flags.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';

class SplashController extends GetxController {
  static const double targetProgress = 0.2634;
  static const Duration splashDuration = Duration(seconds: 3);

  final RxDouble progress = 0.0.obs;

  /// Pro users never see the splash ads disclaimer.
  final RxBool isPremium = false.obs;

  Timer? _timer;
  bool _navigating = false;

  /// Completes when the splash progress animation finishes.
  Completer<void>? _animationDone;

  @override
  void onInit() {
    super.onInit();
    _syncPremiumFlag();
    unawaited(_runLaunchFlow());
  }

  void _syncPremiumFlag() {
    final session = Get.isRegistered<SessionService>()
        ? Get.find<SessionService>()
        : null;
    final premium =
        (session?.hasPremiumAccess ?? false) || PremiumService.isPremiumCached;
    if (premium) {
      isPremium.value = true;
    }
  }

  /// Called as soon as IAP restore/purchase persists premium.
  void markPremiumRestored() {
    isPremium.value = true;
  }

  /// 1) GDPR + Mobile Ads (must finish first)
  /// 2) Splash animation (parallel with session restore)
  /// 3) Splash interstitial
  /// 4) Navigate next
  Future<void> _runLaunchFlow() async {
    _animationDone = Completer<void>();
    _startSplashAnimation();

    // Session restore in parallel — does not block GDPR.
    final sessionReady = _restoreSession();

    // 1) Wait for GDPR consent form (and Mobile Ads init) before any ad.
    developer.log('[Splash] waiting for GDPR / Mobile Ads…');
    await AdService.instance.initialize();
    developer.log(
      '[Splash] GDPR done; mayRequestAds=${AdsConsentGate.mayRequestAds}',
    );

    await sessionReady;

    // 2) Wait for splash animation to finish (if GDPR was fast).
    if (_animationDone != null && !_animationDone!.isCompleted) {
      await _animationDone!.future;
    }

    // 3) Then splash ads, then navigate.
    await _showSplashAdsThenRoute();
  }

  Future<void> _restoreSession() async {
    final storage = Get.find<TokenStorage>();
    final session = Get.find<SessionService>();

    if (storage.isGuestMode) {
      session.restoreGuestSession();
    } else {
      await session.restoreSession();
    }
    _syncPremiumFlag();

    final restored = await PremiumService.beginRestoreEarly();
    if (restored || PremiumService.isPremiumCached) {
      isPremium.value = true;
      session.notifyIapPremiumChanged();
    } else {
      _syncPremiumFlag();
    }
  }

  void _startSplashAnimation() {
    const tick = Duration(milliseconds: 16);
    final totalTicks = splashDuration.inMilliseconds / tick.inMilliseconds;
    var currentTick = 0.0;

    _timer = Timer.periodic(tick, (timer) {
      currentTick++;
      final t = (currentTick / totalTicks).clamp(0.0, 1.0);
      progress.value = targetProgress * _easeOutCubic(t);

      if (t >= 1.0) {
        timer.cancel();
        if (_animationDone != null && !_animationDone!.isCompleted) {
          _animationDone!.complete();
        }
      }
    });
  }

  double _easeOutCubic(double t) => 1 - (1 - t) * (1 - t) * (1 - t);

  Future<void> _showSplashAdsThenRoute() async {
    if (_navigating) return;
    _navigating = true;

    // Hard gate — never request ads before consent flow finished.
    if (!AdsConsentGate.splashConsentCompleted) {
      developer.log('[Splash] consent not completed — re-running gate');
      await AdsConsentGate.runSplashConsentAndMobileAdsSetup();
    }

    final storage = Get.find<TokenStorage>();
    final session = Get.find<SessionService>();

    final isFirstTimeUser = !storage.hasCompletedOnboarding;
    final isPremium = session.hasPremiumAccess;

    // Splash Interstitial — 1st time only (RC: splash_inter_1st)
    final shouldShowSplashInter1st = isFirstTimeUser &&
        !storage.hasShownSplashInter1st &&
        !isPremium;

    if (shouldShowSplashInter1st) {
      developer.log('[Splash] showing splash_inter_1st after GDPR');
      await InterstitialAdTrigger.showPlacement(
        placementId: AdPlacements.splashInter1st,
        forceFetchRc: true,
        onAdClosed: () async {
          await storage.markSplashInter1stShown();
        },
      );
    } else if (isFirstTimeUser && !storage.hasShownSplashInter1st) {
      await storage.markSplashInter1stShown();
    }

    // Splash Interstitial — 2nd & onwards (RC: splash_inter_2nd)
    final shouldShowSplashInter2nd = !isFirstTimeUser && !isPremium;

    if (shouldShowSplashInter2nd) {
      developer.log('[Splash] showing splash_inter_2nd after GDPR');
      await InterstitialAdTrigger.showPlacement(
        placementId: AdPlacements.splashInter2nd,
        forceFetchRc: true,
      );
    } else if (!isFirstTimeUser) {
      await AdRemoteConfigService.instance.fetchNow();
    }

    _routeAfterSplash(storage, session);
  }

  void _routeAfterSplash(TokenStorage storage, SessionService session) {
    if (kDebugMode && AppDebugFlags.forceOnboardingOnLaunch) {
      Get.offAllNamed(AppRoutes.intro);
      return;
    }

    if (kDebugMode &&
        AppDebugFlags.forceLanguageAndOnboardingOnLaunch) {
      Get.offAllNamed(AppRoutes.language);
      return;
    }

    if (!storage.hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.language);
      return;
    }

    if (!session.hasActiveSession) {
      LaunchFlow.goAuthOrIap();
      return;
    }

    LaunchFlow.goHomeOrIap();
  }

  @override
  void onClose() {
    _timer?.cancel();
    if (_animationDone != null && !_animationDone!.isCompleted) {
      _animationDone!.complete();
    }
    super.onClose();
  }
}
