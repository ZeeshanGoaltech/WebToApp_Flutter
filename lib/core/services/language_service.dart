import 'package:get/get.dart';
import 'package:web_to_app/core/localization/app_locale.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/modules/language/data/language_data.dart';
import 'package:web_to_app/modules/language/models/language_option.dart';

class LanguageService extends GetxService {
  final RxString selectedLanguageId = LanguageData.defaultLanguageId.obs;

  Future<void> init() async {
    final stored = Get.find<TokenStorage>().selectedLanguageId;
    final id = LanguageData.normalizeId(stored);
    selectedLanguageId.value = id;
    if (id != stored) {
      await Get.find<TokenStorage>().saveLanguageId(id);
    }
    _applyLocale(id);
  }

  LanguageOption get selected => LanguageData.byId(selectedLanguageId.value);

  String get settingsSubtitle => LanguageData.settingsLabel(selectedLanguageId.value);

  Future<void> setLanguage(String id) async {
    selectedLanguageId.value = id;
    await Get.find<TokenStorage>().saveLanguageId(id);
    _applyLocale(id);
  }

  void _applyLocale(String id) {
    Get.updateLocale(AppLocale.toFlutterLocale(id));
  }
}
