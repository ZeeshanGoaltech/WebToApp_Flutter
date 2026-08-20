#!/usr/bin/env python3
"""Generate GetX translation Dart files from tools/i18n/*.json."""

import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
I18N_DIR = ROOT / "tools" / "i18n"
OUT_DIR = ROOT / "lib" / "core" / "localization" / "translations"

LOCALES = [
    "en_us", "en_gb", "fr_fr", "de_de", "es_es", "it_it", "pt_pt", "nl_nl",
    "ru_ru", "pl_pl", "uk_ua", "sv_se", "es_mx", "pt_br", "es_co", "es_ar",
    "zh_cn", "ja_jp", "ko_kr", "id_id", "ms_my", "th_th", "vi_vn", "fil_ph",
]


def locale_to_getx_key(locale_id: str) -> str:
    lang, country = locale_id.split("_")
    return f"{lang}_{country.upper()}"


def dart_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")


def write_locale_file(locale_id: str, data: dict[str, str]) -> None:
    getx_key = locale_to_getx_key(locale_id)
    var_name = "".join(part.capitalize() for part in locale_id.split("_")) + "Translations"
    lines = [
        "// GENERATED — do not edit by hand. Run: python tools/generate_i18n.py",
        "// ignore_for_file: constant_identifier_names",
        f"const Map<String, String> {var_name} = {{",
    ]
    for key in sorted(data.keys()):
        lines.append(f"  '{key}': '{dart_escape(data[key])}',")
    lines.append("};")
    lines.append("")
    out_path = OUT_DIR / f"{locale_id}.dart"
    out_path.write_text("\n".join(lines), encoding="utf-8")


def write_app_translations() -> None:
    imports = "\n".join(
        f"import 'package:web_to_app/core/localization/translations/{lid}.dart';"
        for lid in LOCALES
    )
    entries = "\n".join(
        f"    '{locale_to_getx_key(lid)}': "
        f"{''.join(part.capitalize() for part in lid.split('_'))}Translations,"
        for lid in LOCALES
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
        write_locale_file(locale_id, data)
        print(f"Wrote {locale_id}.dart ({len(data)} keys)")
    write_app_translations()
    print("Wrote app_translations.dart")


if __name__ == "__main__":
    main()
