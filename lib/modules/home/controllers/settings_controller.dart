import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/constants/app_info.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/modules/home/controllers/home_controller.dart';
import 'package:web_to_app/modules/home/widgets/rate_us_dialog.dart';
import 'package:web_to_app/modules/language/controllers/language_controller.dart';

class SettingsController extends GetxController {
  final isLoggingOut = false.obs;
  final appRating = 0.obs;

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await Get.find<SessionService>().clearSession();
      Get.find<HomeController>().apps.clear();
      Get.offAllNamed(AppRoutes.auth);
    } finally {
      isLoggingOut.value = false;
    }
  }

  void openAuth() => Get.offAllNamed(AppRoutes.auth);

  Future<void> showRateDialog() async {
    final context = Get.context;
    if (context == null) return;

    final rating = await showRateUsDialog(
      context,
      initial: appRating.value > 0 ? appRating.value : 5,
    );
    if (rating == null) return;

    appRating.value = rating;
    AppToast.success('rate_dialog_thanks'.tr);

    if (rating >= 4) {
      final opened = await launchUrl(
        Uri.parse(AppInfo.playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        AppToast.info(
          'rate_app'.tr,
          description: 'rate_dialog_store_unavailable'.tr,
        );
      }
      return;
    }

    final subject = Uri.encodeComponent('rate_dialog_feedback_subject'.tr);
    final uri = Uri.parse('mailto:${AppInfo.feedbackEmail}?subject=$subject');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      AppToast.info(AppInfo.feedbackEmail);
    }
  }

  Future<void> openPrivacyPolicy() =>
      _openExternalUrl(AppInfo.privacyPolicyUrl);

  Future<void> openTermsAndConditions() =>
      _openExternalUrl(AppInfo.termsAndConditionsUrl);

  Future<void> shareApp() async {
    final text = '${AppInfo.name}\n${AppInfo.playStoreUrl}';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _openExternalUrl(String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      AppToast.info('request_failed'.tr, description: url);
    }
  }

  Future<void> upgradeToPremium() async {
    LaunchFlow.openIapFromSettings();
  }

  void openLanguage() {
    if (Get.isRegistered<LanguageController>()) {
      Get.delete<LanguageController>(force: true);
    }
    Get.toNamed(AppRoutes.language, arguments: 'settings');
  }
}
