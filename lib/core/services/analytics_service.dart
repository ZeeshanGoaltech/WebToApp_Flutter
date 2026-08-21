import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_to_app/app/routes/app_routes.dart';

/// Central Firebase Analytics + Crashlytics helper.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  String? _lastScreen;

  NavigatorObserver get navigatorObserver => _AnalyticsNavigatorObserver(this);

  Future<void> init() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('AnalyticsService.init failed: $e');
    }
  }

  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    final name = _normalize(screenName);
    if (name.isEmpty || name == _lastScreen) return;
    _lastScreen = name;
    try {
      await _analytics.logScreenView(
        screenName: name,
        screenClass: screenClass ?? name,
      );
      await FirebaseCrashlytics.instance.setCustomKey('last_screen', name);
      await _analytics.logEvent(
        name: 'screen_open',
        parameters: {'screen_name': name},
      );
    } catch (e) {
      debugPrint('logScreenView($name) failed: $e');
    }
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('logEvent($name) failed: $e');
    }
  }

  Future<void> logBottomNav(String tab) async {
    await logEvent('bottom_nav_tap', parameters: {'tab': tab});
    await logScreenView('tab_$tab');
  }

  Future<void> logLanguageChange(String languageId) async {
    await logEvent(
      'language_change',
      parameters: {'language': languageId},
    );
  }

  Future<void> logIapScreen({
    required bool fromLaunch,
    required bool fromSettings,
  }) async {
    await logEvent(
      'iap_screen_open',
      parameters: {
        'from_launch': fromLaunch ? '1' : '0',
        'from_settings': fromSettings ? '1' : '0',
      },
    );
    await logScreenView('iap_premium');
  }

  Future<void> logLifetimePremiumOpen() async {
    await logEvent('lifetime_premium_open');
    await logScreenView('lifetime_premium');
  }

  Future<void> logCreditsPackOpen() async {
    await logEvent('credits_pack_open');
    await logScreenView('credits_pack');
  }

  Future<void> recordNonFatal(
    Object error,
    StackTrace stack, {
    String? reason,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: false,
      );
    } catch (_) {}
  }

  static String screenNameForPath(String path) {
    if (path.isEmpty || path == '/') return 'home';
    if (path == AppRoutes.splash) return 'splash';
    if (path == AppRoutes.language) return 'language';
    if (path == AppRoutes.intro) return 'intro';
    if (path == AppRoutes.auth) return 'auth';
    if (path == AppRoutes.home) return 'home';
    if (path == AppRoutes.createApp) return 'create_app';
    if (path == AppRoutes.buildApp) return 'build_app';
    if (path == AppRoutes.iap) return 'iap_premium';
    if (path == AppRoutes.lifetimePremium) return 'lifetime_premium';
    if (path == AppRoutes.creditsPack) return 'credits_pack';
    return path.replaceAll('/', '_').replaceFirst(RegExp(r'^_'), '');
  }

  static const _tabNames = ['home', 'my_apps', 'help', 'settings'];

  static String tabNameForIndex(int index) {
    if (index < 0 || index >= _tabNames.length) return 'unknown';
    return _tabNames[index];
  }

  String _normalize(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}

class _AnalyticsNavigatorObserver extends NavigatorObserver {
  _AnalyticsNavigatorObserver(this._service);

  final AnalyticsService _service;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _log(previousRoute);
  }

  void _log(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty || name == '/') return;
    unawaited(
      _service.logScreenView(
        AnalyticsService.screenNameForPath(
          name.startsWith('/') ? name : '/$name',
        ),
      ),
    );
  }
}
