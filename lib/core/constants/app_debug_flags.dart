class AppDebugFlags {
  AppDebugFlags._();

  /// Set to true to open the onboarding screens directly after splash.
  /// This flag is ignored in profile and release builds.
  static const bool forceOnboardingOnLaunch = false;

  // Enable this for QA/testing to force language + onboarding on every launch.
  static const bool forceLanguageAndOnboardingOnLaunch = true;

  /// Deprecated for launch gating — use Firebase RC `splash_sub` instead.
  /// Kept for reference; LaunchFlow reads Remote Config.
  static const bool iapEnabled = true;
}
