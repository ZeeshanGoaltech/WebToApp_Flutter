import 'dart:async';

/// Serializes native-ad loads so multiple [NativeAd] WebViews are not created
/// at once (home can mount 2 medium slots together). Concurrent first-load
/// WebView work on the main thread is a common AdMob ANR source on low-end
/// Android. Ads still load/show — only ordering changes.
abstract final class NativeAdLoadGate {
  static Future<void> _tail = Future<void>.value();

  /// Runs [load] after any in-flight native load finishes.
  static Future<T> run<T>(Future<T> Function() load) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        final result = await load();
        if (!completer.isCompleted) completer.complete(result);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });
    // Keep the chain alive even if a caller never awaits.
    _tail = _tail.catchError((_) {});
    return completer.future;
  }
}
