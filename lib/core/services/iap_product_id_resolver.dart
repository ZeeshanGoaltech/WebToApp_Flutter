import 'package:web_to_app/core/constants/app_feature_flags.dart';

/// Centralized store product IDs for in-app purchases.
class IapProductIdResolver {
  IapProductIdResolver._();

  static final IapProductIdResolver instance = IapProductIdResolver._();

  static const String weeklyPremium = 'weekly_sub';
  static const String monthlyPremium = 'monthly_sub';
  static const String yearlyPremium = 'yearly_sub';
  static const String lifetimePremium = 'lifetime';

  /// Consumable — Download APK paywall (unlocks that project).
  static const String apkDownloadInapp = 'apkdownload_inapp';

  /// Consumable — Download AAB paywall (unlocks that project).
  static const String bundleDownloadInapp = 'bundledownload_inapp';

  String getWeeklySubscriptionId() => weeklyPremium;

  String getMonthlySubscriptionId() => monthlyPremium;

  String getYearlySubscriptionId() => yearlyPremium;

  String getLifetimeProductId() => lifetimePremium;

  String getApkDownloadInappProductId() => apkDownloadInapp;

  String getBundleDownloadInappProductId() => bundleDownloadInapp;

  String getDownloadInappProductId({required bool isAab}) =>
      isAab ? getBundleDownloadInappProductId() : getApkDownloadInappProductId();

  bool isLifetimeProductId(String productId) =>
      productId == getLifetimeProductId();

  bool isDownloadInappProductId(String productId) =>
      productId == getApkDownloadInappProductId() ||
      productId == getBundleDownloadInappProductId();

  Set<String> getAllProductIds() => {
        getWeeklySubscriptionId(),
        if (AppFeatureFlags.monthlyPlanEnabled) getMonthlySubscriptionId(),
        getYearlySubscriptionId(),
        getLifetimeProductId(),
        getApkDownloadInappProductId(),
        getBundleDownloadInappProductId(),
      };

  /// Subscription SKUs only (excludes lifetime + consumable packs).
  Set<String> getSubscriptionProductIds() => {
        getWeeklySubscriptionId(),
        if (AppFeatureFlags.monthlyPlanEnabled) getMonthlySubscriptionId(),
        getYearlySubscriptionId(),
      };

  bool isValidSubscriptionProductId(String productId) =>
      productId == getWeeklySubscriptionId() ||
      productId == getMonthlySubscriptionId() ||
      productId == getYearlySubscriptionId();
}
