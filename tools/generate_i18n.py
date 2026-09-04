#!/usr/bin/env python3
"""Generate GetX translation Dart files from tools/i18n/*.json."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
I18N_DIR = ROOT / "tools" / "i18n"
OUT_DIR = ROOT / "lib" / "core" / "localization" / "translations"

LOCALES = [
    "en_us", "en_gb", "fr_fr", "de_de", "es_es", "it_it", "pt_pt", "nl_nl",
    "ru_ru", "pl_pl", "uk_ua", "sv_se", "es_mx", "pt_br", "es_co", "es_ar",
    "zh_cn", "ja_jp", "ko_kr", "id_id", "ms_my", "th_th", "vi_vn", "fil_ph",
    "ar_sa", "hi_in", "bn_bd", "tr_tr", "uz_uz", "af_za", "fa_ir",
]

APP_TITLE = {
    "en_us": "Website to App Builder",
    "en_gb": "Website to App Builder",
    "fr_fr": "Website to App Builder",
    "de_de": "Website to App Builder",
    "es_es": "Website to App Builder",
    "it_it": "Website to App Builder",
    "pt_pt": "Website to App Builder",
    "nl_nl": "Website to App Builder",
    "ru_ru": "Website to App Builder",
    "pl_pl": "Website to App Builder",
    "uk_ua": "Website to App Builder",
    "sv_se": "Website to App Builder",
    "es_mx": "Website to App Builder",
    "pt_br": "Website to App Builder",
    "es_co": "Website to App Builder",
    "es_ar": "Website to App Builder",
    "zh_cn": "Website to App Builder",
    "ja_jp": "Website to App Builder",
    "ko_kr": "Website to App Builder",
    "id_id": "Website to App Builder",
    "ms_my": "Website to App Builder",
    "th_th": "Website to App Builder",
    "vi_vn": "Website to App Builder",
    "fil_ph": "Website to App Builder",
    "ar_sa": "Website to App Builder",
    "hi_in": "Website to App Builder",
    "bn_bd": "Website to App Builder",
    "tr_tr": "Website to App Builder",
    "uz_uz": "Website to App Builder",
    "af_za": "Website to App Builder",
    "fa_ir": "Website to App Builder",
}


def locale_to_getx_key(locale_id: str) -> str:
    lang, country = locale_id.split("_")
    return f"{lang}_{country.upper()}"


def dart_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")


def var_name(locale_id: str) -> str:
    return "".join(part.capitalize() for part in locale_id.split("_")) + "Translations"


def write_locale_file(locale_id: str, data: dict) -> None:
    lines = [
        "// GENERATED — do not edit by hand. Run: python tools/generate_i18n.py",
        "// ignore_for_file: constant_identifier_names",
        f"const Map<String, String> {var_name(locale_id)} = {{",
    ]
    for key in sorted(data.keys()):
        lines.append(f"  '{key}': '{dart_escape(data[key])}',")
    lines.append("};")
    lines.append("")
    (OUT_DIR / f"{locale_id}.dart").write_text("\n".join(lines), encoding="utf-8")


def write_app_translations() -> None:
    imports = "\n".join(
        f"import 'package:web_to_app/core/localization/translations/{lid}.dart';"
        for lid in LOCALES
    )
    entries = "\n".join(
        f"    '{locale_to_getx_key(lid)}': {var_name(lid)}," for lid in LOCALES
    )
    content = f"""// GENERATED — do not edit by hand. Run: python tools/generate_i18n.py
import 'package:get/get.dart';
{imports}

class AppTranslations extends Translations {{
  @override
  Map<String, Map<String, String>> get keys => {{
{entries}
  }};
}}
"""
    (ROOT / "lib" / "core" / "localization" / "app_translations.dart").write_text(
        content, encoding="utf-8"
    )


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for locale_id in LOCALES:
        json_path = I18N_DIR / f"{locale_id}.json"
        if not json_path.exists():
            raise FileNotFoundError(f"Missing {json_path}")
        data = json.loads(json_path.read_text(encoding="utf-8"))
        data["app_title"] = APP_TITLE.get(locale_id, APP_TITLE["en_us"])
        sorted_data = {k: data[k] for k in sorted(data.keys())}
        json_path.write_text(
            json.dumps(sorted_data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        write_locale_file(locale_id, sorted_data)
        print(f"Wrote {locale_id}.dart ({len(sorted_data)} keys)")
    write_app_translations()
    print("Wrote app_translations.dart")


if __name__ == "__main__":
    main()
