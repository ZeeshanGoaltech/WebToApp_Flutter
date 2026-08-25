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
    "en_us": "Web to App Converter",
    "en_gb": "Web to App Converter",
    "fr_fr": "Web vers App",
    "de_de": "Web zu App",
    "es_es": "Web a App",
    "it_it": "Web in App",
    "pt_pt": "Web para App",
    "nl_nl": "Web naar App",
    "ru_ru": "Веб в приложение",
    "pl_pl": "Web na aplikację",
    "uk_ua": "Веб у додаток",
    "sv_se": "Webb till app",
    "es_mx": "Web a App",
    "pt_br": "Web para App",
    "es_co": "Web a App",
    "es_ar": "Web a App",
    "zh_cn": "网站转应用",
    "ja_jp": "Web to App Converter",
    "ko_kr": "웹을 앱으로",
    "id_id": "Web ke Aplikasi",
    "ms_my": "Web ke Aplikasi",
    "th_th": "เว็บเป็นแอป",
    "vi_vn": "Web thành App",
    "fil_ph": "Web to App Converter",
    "ar_sa": "محول الويب إلى تطبيق",
    "hi_in": "वेब से ऐप कनवर्टर",
    "bn_bd": "ওয়েব টু অ্যাপ কনভার্টার",
    "tr_tr": "Web'den Uygulamaya Dönüştürücü",
    "uz_uz": "Vebdan Ilovaga Konverter",
    "af_za": "Web na App Omskakelaar",
    "fa_ir": "تبدیل وب به اپلیکیشن",
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
