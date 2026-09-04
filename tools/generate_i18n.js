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
  en_us: 'Website to App Builder',
  en_gb: 'Website to App Builder',
  fr_fr: 'Website to App Builder',
  de_de: 'Website to App Builder',
  es_es: 'Website to App Builder',
  it_it: 'Website to App Builder',
  pt_pt: 'Website to App Builder',
  nl_nl: 'Website to App Builder',
  ru_ru: 'Website to App Builder',
  pl_pl: 'Website to App Builder',
  uk_ua: 'Website to App Builder',
  sv_se: 'Website to App Builder',
  es_mx: 'Website to App Builder',
  pt_br: 'Website to App Builder',
  es_co: 'Website to App Builder',
  es_ar: 'Website to App Builder',
  zh_cn: 'Website to App Builder',
  ja_jp: 'Website to App Builder',
  ko_kr: 'Website to App Builder',
  id_id: 'Website to App Builder',
  ms_my: 'Website to App Builder',
  th_th: 'Website to App Builder',
  vi_vn: 'Website to App Builder',
  fil_ph: 'Website to App Builder',
  ar_sa: 'Website to App Builder',
  hi_in: 'Website to App Builder',
  bn_bd: 'Website to App Builder',
  tr_tr: 'Website to App Builder',
  uz_uz: 'Website to App Builder',
  af_za: 'Website to App Builder',
  fa_ir: 'Website to App Builder',
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
