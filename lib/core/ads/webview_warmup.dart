import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Preloads Android System WebView **before** [MobileAds.initialize].
///
/// AdMob's JS engine creates a WebView on the main thread; the first
/// `WebViewLibraryLoader.nativeLoadWithRelroFile` can ANR low-end devices
/// ("Input dispatching timed out (No focused window)"). Warming once during
/// splash moves that cost off the ad-init / first-tap path. No-op on iOS.
abstract final class WebViewWarmup {
  static const _channel = MethodChannel('com.webtoapp.converter/webview_warmup');

  static Future<void>? _inFlight;

  /// Idempotent. Safe to call from ads init; never throws to callers.
  static Future<void> ensureReady() {
    if (!Platform.isAndroid) return Future<void>.value();
    return _inFlight ??= _run();
  }

  static Future<void> _run() async {
    try {
      // Brief yield so the splash activity can take window focus first.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await _channel
          .invokeMethod<bool>('warmUp')
          .timeout(const Duration(seconds: 4));
      developer.log('[WebViewWarmup] provider ready');
    } catch (e) {
      // Never block ads / GDPR if warmup fails or times out.
      developer.log('[WebViewWarmup] skipped: $e');
    }
  }
}
