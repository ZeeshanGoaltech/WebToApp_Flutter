import 'dart:io';

/// Master switches for monetization and exit-intent offers.
abstract final class AppFeatureFlags {
  static const bool monetizationEnabled = true;

  /// Exit sheet offers lifetime upgrade (Android only).
  static bool get exitLifetimeOfferEnabled =>
      monetizationEnabled && Platform.isAndroid;

  /// Show monthly plan on the main subscription screen (Android only).
  /// When enabled: Yearly (trial CTA) → Monthly → Weekly.
  static bool get monthlyPlanEnabled =>
      monetizationEnabled && Platform.isAndroid;
}
