import 'package:flutter/material.dart';
import 'package:web_to_app/core/localization/l10n.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';
import 'package:web_to_app/modules/create_app/models/onboarding_slide_model.dart';

class CreateAppDefaults {
  CreateAppDefaults._();

  static List<NavTabModel> defaultNavTabs() => [
        NavTabModel(
          id: 'home',
          type: NavTabType.home,
          label: L10n.navTabLabel(NavTabType.home),
        ),
        NavTabModel(
          id: 'privacy',
          type: NavTabType.privacyPolicy,
          label: L10n.navTabLabel(NavTabType.privacyPolicy),
        ),
      ];

  static List<OnboardingSlideModel> defaultSlides() => [
        OnboardingSlideModel(id: 'slide_1'),
      ];

  static const Map<String, bool> defaultPermissions = {
    'push': false,
    'camera': false,
    'location': false,
    'storage': false,
    'microphone': false,
  };

  static const Map<String, bool> defaultExtraFeatures = {
    'noInternetDialog': false,
    'pushNotificationPopup': false,
    'loadingScreen': false,
    'errorScreen': false,
    'exitConfirmation': false,
    'backButtonHandling': false,
  };

  static const List<Color> themeColors = [
    Color(0xFF6C63FF),
    Color(0xFF2F6BFF),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
  ];
}
