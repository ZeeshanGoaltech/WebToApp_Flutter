class AppDebugFlags {
  AppDebugFlags._();

  /// Set to true to open the onboarding screens directly after splash.
  /// This flag is ignored in profile and release builds.
  static const bool forceOnboardingOnLaunch = false;

  // Enable this for QA/testing to force language + onboarding on every launch.
  static const bool forceLanguageAndOnboardingOnLaunch = false;

  /// Local IAP splash gate mirror — see [AppFeatureConfig.splashSub].
  static const bool iapEnabled = true;
}
