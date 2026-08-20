const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const I18N_DIR = path.join(ROOT, 'tools', 'i18n');
const OUT_DIR = path.join(ROOT, 'lib', 'core', 'localization', 'translations');

const LOCALES = [
  'en_us', 'en_gb', 'fr_fr', 'de_de', 'es_es', 'it_it', 'pt_pt', 'nl_nl',
  'ru_ru', 'pl_pl', 'uk_ua', 'sv_se', 'es_mx', 'pt_br', 'es_co', 'es_ar',
  'zh_cn', 'ja_jp', 'ko_kr', 'id_id', 'ms_my', 'th_th', 'vi_vn', 'fil_ph',
  'ar_sa', 'hi_in', 'bn_bd', 'tr_tr', 'uz_uz', 'af_za', 'fa_ir',
];

const APP_TITLE = {
  en_us: 'Web to App Converter',
  en_gb: 'Web to App Converter',
  fr_fr: 'Web vers App',
  de_de: 'Web zu App',
  es_es: 'Web a App',
  it_it: 'Web in App',
  pt_pt: 'Web para App',
  nl_nl: 'Web naar App',
  ru_ru: 'Веб в приложение',
  pl_pl: 'Web na aplikację',
  uk_ua: 'Веб у додаток',
  sv_se: 'Webb till app',
  es_mx: 'Web a App',
  pt_br: 'Web para App',
  es_co: 'Web a App',
  es_ar: 'Web a App',
  zh_cn: '网站转应用',
  ja_jp: 'Web to App Converter',
  ko_kr: '웹을 앱으로',
  id_id: 'Web ke Aplikasi',
  ms_my: 'Web ke Aplikasi',
  th_th: 'เว็บเป็นแอป',
  vi_vn: 'Web thành App',
  fil_ph: 'Web to App Converter',
  ar_sa: 'محول الويب إلى تطبيق',
  hi_in: 'वेब से ऐप कनवर्टर',
  bn_bd: 'ওয়েব টু অ্যাপ কনভার্টার',
  tr_tr: "Web'den Uygulamaya Dönüştürücü",
  uz_uz: 'Vebdan Ilovaga Konverter',
  af_za: 'Web na App Omskakelaar',
  fa_ir: 'تبدیل وب به اپلیکیشن',
};

function localeToGetXKey(id) {
  const [lang, country] = id.split('_');
  return `${lang}_${country.toUpperCase()}`;
}

function dartEscape(s) {
  return s.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '\\n');
}

function varName(localeId) {
  return localeId.split('_').map((p) => p.charAt(0).toUpperCase() + p.slice(1)).join('') + 'Translations';
}

for (const locale of LOCALES) {
  const filePath = path.join(I18N_DIR, `${locale}.json`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  data.app_title = APP_TITLE[locale] || APP_TITLE.en_us;
  const sorted = Object.fromEntries(Object.keys(data).sort().map((k) => [k, data[k]]));
  fs.writeFileSync(filePath, JSON.stringify(sorted, null, 2) + '\n', 'utf8');

  const lines = [
    '// GENERATED — do not edit by hand. Run: node tools/generate_i18n.js',
    '// ignore_for_file: constant_identifier_names',
    `const Map<String, String> ${varName(locale)} = {`,
  ];
  for (const key of Object.keys(sorted)) {
    lines.push(`  '${key}': '${dartEscape(sorted[key])}',`);
  }
  lines.push('};', '');
  fs.writeFileSync(path.join(OUT_DIR, `${locale}.dart`), lines.join('\n'), 'utf8');
  console.log(`Updated ${locale} (${Object.keys(sorted).length} keys)`);
}

const imports = LOCALES.map(
  (lid) => `import 'package:web_to_app/core/localization/translations/${lid}.dart';`,
).join('\n');
const entries = LOCALES.map(
  (lid) => `    '${localeToGetXKey(lid)}': ${varName(lid)},`,
).join('\n');

const appTranslations = `// GENERATED — do not edit by hand. Run: node tools/generate_i18n.js
import 'package:get/get.dart';
${imports}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
${entries}
  };
}
`;

fs.writeFileSync(path.join(ROOT, 'lib', 'core', 'localization', 'app_translations.dart'), appTranslations, 'utf8');
console.log('Wrote app_translations.dart');
