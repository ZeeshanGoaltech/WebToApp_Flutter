import 'package:get/get.dart';
import 'package:web_to_app/modules/create_app/models/onboarding_slide_model.dart';

class CreateAppValidator {
  CreateAppValidator._();

  /// Upgrades `http://` to `https://` so WebViews can load the site
  /// (Android blocks cleartext HTTP by default). Also fixes common
  /// `wwww…` typos to `www`.
  static String normalizeWebsiteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    var uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return trimmed;

    var changed = false;
    if (uri.scheme.toLowerCase() == 'http') {
      uri = uri.replace(scheme: 'https');
      changed = true;
    }

    final host = uri.host;
    if (host.isNotEmpty) {
      // wwww.example.com / wwwww.example.com → www.example.com
      final fixedHost = host.replaceFirstMapped(
        RegExp(r'^w{4,}\.', caseSensitive: false),
        (_) => 'www.',
      );
      if (fixedHost != host) {
        uri = uri.replace(host: fixedHost);
        changed = true;
      }
    }

    return changed ? uri.toString() : trimmed;
  }

  /// Rejects hosts whose first label is only `w`s but not exactly `www`
  /// (e.g. `ww.example.com`, leftover typos after normalize).
  static bool _hasWwwTypo(String host) {
    if (host.isEmpty) return false;
    final firstLabel = host.split('.').first.toLowerCase();
    return RegExp(r'^w+$').hasMatch(firstLabel) && firstLabel != 'www';
  }

  static bool _isValidIpv4(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  /// Domain like `example.com` or `www.example.co.uk` (TLD ≥ 2 letters).
  static final _domainHostPattern = RegExp(
    r'^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$',
    caseSensitive: false,
  );

  static bool isValidUrl(String value) {
    final trimmed = normalizeWebsiteUrl(value);
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;

    final host = uri.host.toLowerCase();
    if (_hasWwwTypo(host)) return false;
    if (_isValidIpv4(host)) return true;
    return _domainHostPattern.hasMatch(host);
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
