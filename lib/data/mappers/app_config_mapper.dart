import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/data/create_app_validator.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';

class AppConfigMapper {
  AppConfigMapper._();

  static Map<String, dynamic> fromWizard(
    CreateAppController controller, {
    required String? iconAssetId,
    required String? splashAssetId,
    required Map<String, String> slideAssetIds,
  }) {
    final startUrl = CreateAppValidator.normalizeWebsiteUrl(
      controller.websiteUrlController.text,
    );
    final versionCode = int.parse(controller.versionCodeController.text.trim());
    final primaryColor = _colorToHex(controller.selectedThemeColor.value);

    final pages = <Map<String, dynamic>>[];
    final navItems = <Map<String, dynamic>>[];

    if (controller.bottomNavEnabled.value && controller.navTabs.isNotEmpty) {
      final usedIds = <String>{};
      for (final tab in controller.navTabs) {
        final pageId = _uniqueId(_pageIdForTab(tab), usedIds);
        final url = _urlForTab(tab.type, startUrl);
        pages.add(
          _remotePage(
            id: pageId,
            title: tab.label,
            url: url,
            pullToRefresh: controller.pullToRefresh.value,
          ),
        );
        navItems.add({
          'id': pageId,
          'label': tab.label,
          'icon': _navIcon(tab.type),
          'target': {'pageId': pageId},
          if (tab.mode == NavTabMode.browser) 'presentation': 'systemBrowser',
        });
      }
    } else {
      pages.add(
        _remotePage(
          id: 'home',
          title: 'tab_home'.tr,
          url: startUrl,
          pullToRefresh: controller.pullToRefresh.value,
        ),
      );
      navItems.add({
        'id': 'home',
        'label': 'tab_home'.tr,
        'icon': 'home',
        'target': {'pageId': 'home'},
      });
    }

    final theme = <String, dynamic>{
      'darkMode': controller.darkStatusBar.value ? 'dark' : 'system',
      'colors': {'primary': primaryColor},
      'loadingIndicator': controller.extraFeatures['loadingScreen'] == true
          ? 'logo'
          : 'spinner',
    };
    if (iconAssetId != null) theme['appIconAssetId'] = iconAssetId;
    if (splashAssetId != null) theme['splashAssetId'] = splashAssetId;

    // Field names must match live AppConfig schema (PUT is loosely
    // validated; the worker compiles against this contract).
    final config = <String, dynamic>{
      'schemaVersion': 3,
      'identity': {
        'name': controller.appNameController.text.trim(),
        'androidPackage': controller.packageNameController.text.trim(),
        'versionName': controller.versionNameController.text.trim(),
        'versionCode': versionCode,
        'startUrl': startUrl,
      },
      'theme': theme,
      'behavior': {
        'pullToRefresh': controller.pullToRefresh.value,
        'desktopMode': controller.desktopMode.value,
        'keepAwake': controller.keepScreenAlive.value,
      },
      'navigation': {
        'model': controller.bottomNavEnabled.value ? 'bottomTabs' : 'single',
        'items': navItems,
      },
      'pages': pages,
    };

    if (controller.onboardingEnabled.value) {
      final slides = <Map<String, dynamic>>[];
      for (var i = 0; i < controller.slides.length; i++) {
        final slide = controller.slides[i];
        final map = <String, dynamic>{
          'id': _androidSafeId(slide.id, fallback: 'slide_${i + 1}'),
          'title': slide.title.trim(),
          'body': slide.description.trim(),
        };
        final assetId = slideAssetIds[slide.id];
        if (assetId != null) map['imageAssetId'] = assetId;
        if (slide.ctaEnabled && slide.ctaLabel.trim().isNotEmpty) {
          map['cta'] = {
            'label': slide.ctaLabel.trim(),
            'action': 'finish',
          };
        }
        slides.add(map);
      }
      config['onboarding'] = {
        'enabled': true,
        'slides': slides,
      };
    }

    final enabledPermissions = controller.permissions.entries
        .where((e) => e.value)
        .map(
          (e) => {
            'key': _permissionKey(e.key),
            'rationale': _permissionRationale(e.key),
            'requestLazily': true,
          },
        )
        .toList();
    if (enabledPermissions.isNotEmpty) {
      config['permissions'] = enabledPermissions;
    }

    if (controller.extraFeatures['noInternetDialog'] == true) {
      config['noInternetScreen'] = {
        'title': 'no_internet_title'.tr,
        'description': 'no_internet_desc'.tr,
        'autoRetry': true,
      };
    }

    if (controller.extraFeatures['pushNotificationPopup'] == true) {
      config['push'] = {
        'enabled': true,
        'provider': 'fcm',
        'promptOnLaunch': true,
      };
    }

    return config;
  }

  static Map<String, dynamic> _remotePage({
    required String id,
    required String title,
    required String url,
    required bool pullToRefresh,
  }) => {
    'id': id,
    'slug': id,
    'title': title,
    'kind': 'remote',
    'remote': {'url': url, 'pullToRefresh': pullToRefresh},
  };

  static String _urlForTab(NavTabType type, String startUrl) {
    return switch (type) {
      NavTabType.home => startUrl,
      NavTabType.privacyPolicy => '$startUrl/privacy-policy',
      NavTabType.whatsapp => 'https://wa.me/',
      NavTabType.externalLink => startUrl,
    };
  }

  static String _pageIdForTab(NavTabModel tab) => switch (tab.type) {
    NavTabType.home => 'home',
    NavTabType.privacyPolicy => 'privacy',
    NavTabType.whatsapp => 'whatsapp',
    NavTabType.externalLink => 'external',
  };

  static String _navIcon(NavTabType type) => switch (type) {
    NavTabType.home => 'home',
    NavTabType.privacyPolicy => 'shield',
    NavTabType.whatsapp => 'whatsapp',
    NavTabType.externalLink => 'link',
  };

  static String _uniqueId(String preferred, Set<String> used) {
    var id = _androidSafeId(preferred, fallback: 'page');
    if (!used.contains(id)) {
      used.add(id);
      return id;
    }
    var n = 2;
    while (used.contains('${id}_$n')) {
      n++;
    }
    final unique = '${id}_$n';
    used.add(unique);
    return unique;
  }

  /// Android resource names must be `[a-z][a-z0-9_]*`. Numeric wizard
  /// ids like `1` crash aapt during "Compiling resources".
  static String _androidSafeId(String raw, {required String fallback}) {
    var value = raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    value = value.replaceAll(RegExp(r'_+'), '_');
    if (value.isEmpty || RegExp(r'^[0-9]').hasMatch(value)) {
      return fallback;
    }
    return value;
  }

  static String _permissionKey(String key) => switch (key) {
    'push' => 'notifications',
    'camera' => 'camera',
    'location' => 'location',
    'storage' => 'storage',
    'microphone' => 'microphone',
    _ => key,
  };

  static String _permissionRationale(String key) => switch (key) {
    'push' => 'perm_rationale_push'.tr,
    'camera' => 'perm_rationale_camera'.tr,
    'location' => 'perm_rationale_location'.tr,
    'storage' => 'perm_rationale_storage'.tr,
    'microphone' => 'perm_rationale_microphone'.tr,
    _ => 'perm_rationale_default'.tr,
  };

  static String _colorToHex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
