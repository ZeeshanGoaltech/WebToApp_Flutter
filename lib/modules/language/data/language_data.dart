import 'package:web_to_app/modules/language/models/language_option.dart';

class LanguageData {
  LanguageData._();

  static const String defaultLanguageId = 'en_gb';

  static final List<LanguageOption> languages = [
    _lang('en_gb', 'English (UK)', 'United Kingdom', 'GB'),
    _lang('es_es', 'Spanish', 'Spain', 'ES'),
    _lang('fr_fr', 'French', 'France', 'FR'),
    _lang('de_de', 'German', 'Germany', 'DE'),
    _lang('ja_jp', 'Japanese', 'Japan', 'JP'),
    _lang('ko_kr', 'Korean', 'South Korea', 'KR'),
    _lang('it_it', 'Italian', 'Italy', 'IT'),
    _lang('pt_pt', 'Portuguese', 'Portugal', 'PT'),
    _lang('ru_ru', 'Russian', 'Russia', 'RU'),
    _lang('ar_sa', 'Arabic', 'Saudi Arabia', 'SA'),
    _lang('th_th', 'Thai', 'Thailand', 'TH'),
    _lang('hi_in', 'Hindi', 'India', 'IN'),
    _lang('bn_bd', 'Bengali', 'Bangladesh', 'BD'),
    _lang('zh_cn', 'Chinese', 'China', 'CN'),
    _lang('tr_tr', 'Turkish', 'Turkey', 'TR'),
    _lang('vi_vn', 'Vietnamese', 'Vietnam', 'VN'),
    _lang('id_id', 'Indonesian', 'Indonesia', 'ID'),
    _lang('pl_pl', 'Polish', 'Poland', 'PL'),
    _lang('nl_nl', 'Dutch', 'Netherlands', 'NL'),
    _lang('uk_ua', 'Ukrainian', 'Ukraine', 'UA'),
    _lang('fil_ph', 'Filipino', 'Philippines', 'PH'),
    _lang('ms_my', 'Malay', 'Malaysia', 'MY'),
    _lang('uz_uz', 'Uzbek', 'Uzbekistan', 'UZ'),
    _lang('af_za', 'Afrikaans', 'South Africa', 'ZA'),
    _lang('fa_ir', 'Persian', 'Iran', 'IR'),
  ];

  /// Maps removed / legacy IDs onto the current catalog.
  static const Map<String, String> _legacyIds = {
    'en_us': 'en_gb',
    'es_mx': 'es_es',
    'es_co': 'es_es',
    'es_ar': 'es_es',
    'pt_br': 'pt_pt',
    'sv_se': 'en_gb',
  };

  static String normalizeId(String id) {
    if (languages.any((lang) => lang.id == id)) return id;
    return _legacyIds[id] ?? defaultLanguageId;
  }

  static LanguageOption byId(String id) => languages.firstWhere(
        (lang) => lang.id == normalizeId(id),
        orElse: () => languages.first,
      );

  static String settingsLabel(String id) {
    final lang = byId(id);
    return '${_flagEmoji(lang.countryCode)} ${lang.languageName}';
  }

  static String _flagEmoji(String countryCode) {
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '🌐';
    return String.fromCharCodes([
      0x1F1E6 + code.codeUnitAt(0) - 65,
      0x1F1E6 + code.codeUnitAt(1) - 65,
    ]);
  }

  static LanguageOption _lang(
    String id,
    String name,
    String country,
    String countryCode,
  ) {
    return LanguageOption(
      id: id,
      languageName: name,
      countryName: country,
      countryCode: countryCode,
    );
  }
}
