import 'package:shared_preferences/shared_preferences.dart';

/// Persists click counters for frequency-gated interstitial placements.
class InterstitialCounterService {
  InterstitialCounterService._();

  static final InterstitialCounterService instance =
      InterstitialCounterService._();

  static String _keyFor(String placementId) => 'inter_counter_$placementId';

  Future<int> increment(String placementId) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_keyFor(placementId)) ?? 0) + 1;
    await prefs.setInt(_keyFor(placementId), next);
    return next;
  }

  Future<int> get(String placementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFor(placementId)) ?? 0;
  }

  Future<void> reset(String placementId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(placementId));
  }
}
