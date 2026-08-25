import 'package:get/get.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';
import 'package:web_to_app/modules/create_app/models/preview_mode.dart';

/// Shared localization helpers for dynamic labels and parameterized strings.
class L10n {
  L10n._();

  static String slideOf(int current, int total) =>
      'slide_of'.trParams({'current': '$current', 'total': '$total'});

  static String stepOf(int current, int total) =>
      'step_of'.trParams({'current': '$current', 'total': '$total'});

  static String navTabLabel(NavTabType type) => switch (type) {
    NavTabType.home => 'tab_home'.tr,
    NavTabType.privacyPolicy => 'tab_privacy_policy'.tr,
    NavTabType.whatsapp => 'tab_whatsapp'.tr,
    NavTabType.externalLink => 'tab_external_link'.tr,
  };

  static List<String> stepTitles() => [
    'step_create_app'.tr,
    'step_app_settings'.tr,
    'step_onboarding'.tr,
    'step_permissions'.tr,
    'step_extra_features'.tr,
    'step_live_preview'.tr,
  ];

  static List<String> stepCtas() => [
    'cta_create_app'.tr,
    'cta_next_arrow'.tr,
    'cta_next'.tr,
    'cta_next'.tr,
    'cta_next'.tr,
    'cta_build_app'.tr,
  ];
}

extension PreviewModeL10n on PreviewMode {
  String get localizedLabel => switch (this) {
    PreviewMode.splash => 'preview_splash'.tr,
    PreviewMode.onboarding => 'preview_onboarding'.tr,
    PreviewMode.navigation => 'preview_navigation'.tr,
    PreviewMode.webview => 'preview_webview'.tr,
  };
}
