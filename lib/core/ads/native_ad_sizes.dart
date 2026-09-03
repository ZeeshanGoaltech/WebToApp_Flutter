/// Native ad factory IDs + slot heights (aligned with Nail_Art layouts).
abstract final class NativeAdSizes {
  static const String mediumFactory = 'mediumAd';

  /// Onboarding — headline, media row, CTA in right column.
  static const String selectCurrencyMediumFactory = 'select_currency_medium';

  /// Language — headline, media row, full-width bottom CTA.
  static const String mediumFullCtaFactory = 'mediumfullCTA';

  static const double medium = 176;

  /// `native_ad_select_currency_medium` (~180dp).
  static const double selectCurrencyMedium = 180;

  /// `native_ad_medium_full_cta` (~215dp).
  static const double mediumFullCta = 215;
}
