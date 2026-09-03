/// Local feature / quota flags (formerly Remote Config defaults).
abstract final class AppFeatureConfig {
  /// Show IAP paywall before auth (new users) or before home (logged-in).
  static const bool splashSub = true;

  /// Free build quota: `null` = unlimited.
  static const int? buildAppSubLimit = null;

  /// Generate Bundle & APK quota: `null` = unlimited.
  static const int? generateBundleApkSubLimit = null;

  /// Build Again free quota (`null` = unlimited).
  static const int? buildAgainSubLimit = 3;
}
