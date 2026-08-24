import 'package:web_to_app/core/constants/app_feature_flags.dart';

/// Centralized store product IDs for in-app purchases.
class IapProductIdResolver {
  IapProductIdResolver._();

  static final IapProductIdResolver instance = IapProductIdResolver._();

  static const String weeklyPremium = 'weekly_sub';
  static const String monthlyPremium = 'monthly_sub';
  static const String yearlyPremium = 'yearly_sub';
  static const String lifetimePremium = 'lifetime';

  /// Consumable credit pack (+N builds). Separate from subscription SKUs.
  static const String creditsPack = 'threescan_inapp';

  /// Consumable — Download APK paywall (same id as RC free-quota key).
  static const String apkDownloadInapp = 'apkdownload_inapp';

  /// Consumable — Download AAB paywall (same id as RC free-quota key).
  static const String bundleDownloadInapp = 'bundledownload_inapp';

  String getWeeklySubscriptionId() => weeklyPremium;

  String getMonthlySubscriptionId() => monthlyPremium;

  String getYearlySubscriptionId() => yearlyPremium;

  String getLifetimeProductId() => lifetimePremium;

  String getCreditsPackProductId() => creditsPack;

  String getApkDownloadInappProductId() => apkDownloadInapp;

  String getBundleDownloadInappProductId() => bundleDownloadInapp;

  String getDownloadInappProductId({required bool isAab}) =>
      isAab ? getBundleDownloadInappProductId() : getApkDownloadInappProductId();

  bool isLifetimeProductId(String productId) =>
      productId == getLifetimeProductId();

  bool isCreditsPackProductId(String productId) =>
      productId == getCreditsPackProductId();

  bool isDownloadInappProductId(String productId) =>
      productId == getApkDownloadInappProductId() ||
      productId == getBundleDownloadInappProductId();

  /// Only `threescan_inapp` grants [CreditService] pack credits.
  /// Download products grant one-shot download tokens instead.
  bool isCreditsGrantingProductId(String productId) =>
      isCreditsPackProductId(productId);

  Set<String> getAllProductIds() => {
        getWeeklySubscriptionId(),
        if (AppFeatureFlags.monthlyPlanEnabled) getMonthlySubscriptionId(),
        getYearlySubscriptionId(),
        getLifetimeProductId(),
        getCreditsPackProductId(),
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
