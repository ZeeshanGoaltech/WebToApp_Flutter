import 'package:get/get.dart';
import 'package:web_to_app/modules/create_app/models/onboarding_slide_model.dart';

class CreateAppValidator {
  CreateAppValidator._();

  /// Upgrades `http://` to `https://` so WebViews can load the site
  /// (Android blocks cleartext HTTP by default).
  static String normalizeWebsiteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return trimmed;
    if (uri.scheme.toLowerCase() != 'http') return trimmed;
    return uri.replace(scheme: 'https').toString();
  }

  static bool isValidUrl(String value) {
    final trimmed = normalizeWebsiteUrl(value);
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return false;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  static bool isValidPackageName(String value) {
    return RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$')
        .hasMatch(value.trim());
  }

  static bool isValidVersionCode(String value) {
    final n = int.tryParse(value.trim());
    return n != null && n > 0;
  }

  static bool isValidVersionName(String value) {
    return RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(value.trim());
  }

  static String? validateWebsiteUrl(String value) {
    final normalized = normalizeWebsiteUrl(value);
    if (normalized.isEmpty) return 'err_url_required'.tr;
    if (!isValidUrl(normalized)) return 'err_url_invalid'.tr;
    return null;
  }

  static String? validateAppName(String value) {
    if (value.trim().isEmpty) return 'err_app_name_required'.tr;
    if (value.trim().length < 2) return 'err_app_name_short'.tr;
    return null;
  }

  static String? validatePackageName(String value) {
    if (value.trim().isEmpty) return 'err_package_required'.tr;
    if (!isValidPackageName(value)) {
      return 'err_package_format'.tr;
    }
    return null;
  }

  static String? validateVersionCode(String value) {
    if (value.trim().isEmpty) return 'err_version_code_required'.tr;
    if (!isValidVersionCode(value)) return 'err_version_code_invalid'.tr;
    return null;
  }

  static String? validateVersionName(String value) {
    if (value.trim().isEmpty) return 'err_version_name_required'.tr;
    if (!isValidVersionName(value)) return 'err_version_name_format'.tr;
    return null;
  }

  static String? validateSlideTitle(String value) {
    if (value.trim().isEmpty) return 'err_slide_title_required'.tr;
    return null;
  }

  static String? validateCtaLabel(String value) {
    if (value.trim().isEmpty) return 'err_button_label_required'.tr;
    return null;
  }

  static bool isSlideComplete(OnboardingSlideModel slide) {
    if (slide.imagePath == null || slide.imagePath!.trim().isEmpty) {
      return false;
    }
    if (validateSlideTitle(slide.title) != null) return false;
    if (slide.description.trim().isEmpty) return false;
    if (slide.ctaEnabled && validateCtaLabel(slide.ctaLabel) != null) {
      return false;
    }
    return true;
  }

  static String incompleteSlideHint(OnboardingSlideModel slide) {
    if (slide.imagePath == null || slide.imagePath!.trim().isEmpty) {
      return 'err_slide_image_required'.tr;
    }
    final titleError = validateSlideTitle(slide.title);
    if (titleError != null) return titleError;
    if (slide.description.trim().isEmpty) {
      return 'err_slide_description_required'.tr;
    }
    if (slide.ctaEnabled) {
      final ctaError = validateCtaLabel(slide.ctaLabel);
      if (ctaError != null) return ctaError;
    }
    return 'complete_current_slide_to_add'.tr;
  }
}
