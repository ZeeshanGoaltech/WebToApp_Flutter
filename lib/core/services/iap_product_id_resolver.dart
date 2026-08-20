import 'package:web_to_app/core/constants/app_feature_flags.dart';

/// Centralized store product IDs for in-app purchases.
class IapProductIdResolver {
  IapProductIdResolver._();

  static final IapProductIdResolver instance = IapProductIdResolver._();

  static const String weeklyPremium = 'weekly_sub';
  static const String monthlyPremium = 'monthly_sub';
  static const String yearlyPremium = 'yearly_sub';
  static const String lifetimePremium = 'lifetime';

  String getWeeklySubscriptionId() => weeklyPremium;

  String getMonthlySubscriptionId() => monthlyPremium;

  String getYearlySubscriptionId() => yearlyPremium;

  String getLifetimeProductId() => lifetimePremium;

  bool isLifetimeProductId(String productId) =>
      productId == getLifetimeProductId();

  Set<String> getAllProductIds() => {
        getWeeklySubscriptionId(),
        if (AppFeatureFlags.monthlyPlanEnabled) getMonthlySubscriptionId(),
        getYearlySubscriptionId(),
        getLifetimeProductId(),
      };

  bool isValidSubscriptionProductId(String productId) =>
      productId == getWeeklySubscriptionId() ||
      productId == getMonthlySubscriptionId() ||
      productId == getYearlySubscriptionId();
}
