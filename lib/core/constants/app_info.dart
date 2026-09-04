/// App-wide metadata used for branding, store links, and legal pages.
class AppInfo {
  AppInfo._();

  static const String name = 'Website to App Builder';

  static const String androidPackage = 'com.webtoapp.converter.appmaker';

  static const String feedbackEmail = 'goldtec.marketing@gmail.com';

  static const String privacyPolicyUrl =
      'https://sites.google.com/view/webtoapp-privacypolicy/home';

  static const String termsAndConditionsUrl =
      'https://sites.google.com/view/termscondtions-makapps/home';

  static String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$androidPackage';

  /// Opens Google Play subscription management for this app.
  static String get playStoreSubscriptionsUrl =>
      'https://play.google.com/store/account/subscriptions?package=$androidPackage';

  /// Opens Apple subscription management (Settings → Subscriptions).
  static const String appStoreSubscriptionsUrl =
      'https://apps.apple.com/account/subscriptions';
}
