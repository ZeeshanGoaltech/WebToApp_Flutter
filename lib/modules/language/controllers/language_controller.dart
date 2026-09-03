import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/core/services/language_service.dart';
import 'package:web_to_app/modules/language/data/language_data.dart';
import 'package:web_to_app/modules/language/models/language_option.dart';

class LanguageController extends GetxController {
  final RxString selectedLanguageId = LanguageData.defaultLanguageId.obs;
  final RxBool isDoneReady = false.obs;
  late final bool fromSettings;
  DateTime? _lastBackPressAt;

  List<LanguageOption> get languages => LanguageData.languages;

  @override
  void onInit() {
    super.onInit();
    fromSettings = Get.arguments == 'settings';
    selectedLanguageId.value = LanguageData.normalizeId(
      Get.find<LanguageService>().selectedLanguageId.value,
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!isClosed) isDoneReady.value = true;
    });
  }

  void selectLanguage(String id) {
    selectedLanguageId.value = id;
  }

  bool isSelected(String id) => selectedLanguageId.value == id;

  Future<void> onDone() async {
    await Get.find<LanguageService>().setLanguage(selectedLanguageId.value);
    if (fromSettings) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.intro);
    }
  }

  void onBack() => Get.back();

  Future<bool> handleSystemBack() async {
    // Swallow while inter/app-open is up; do not permanently disable after X dismiss.
    if (AdPresentationGate.shouldBlockBack) return false;

    if (fromSettings) return true;

    final now = DateTime.now();
    if (_lastBackPressAt == null ||
        now.difference(_lastBackPressAt!) > const Duration(seconds: 2)) {
      _lastBackPressAt = now;
      await AppToast.info('press_back_again_to_close'.tr);
      return false;
    }
    return true;
  }
}
