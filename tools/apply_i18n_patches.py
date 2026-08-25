#!/usr/bin/env python3
"""Merge tools/i18n_patches/*.json into tools/i18n/*.json then regenerate Dart."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
I18N_DIR = ROOT / "tools" / "i18n"
PATCH_DIR = ROOT / "tools" / "i18n_patches"

# Placeholders that must remain intact after translation.
PLACEHOLDERS = (
    "@price",
    "@percent",
    "@count",
    "@unit",
    "@title",
    "@label",
    "@url",
    "@current",
    "@total",
)


def main() -> int:
    patches = sorted(PATCH_DIR.glob("*.json"))
    if not patches:
        print("No patches in tools/i18n_patches/", file=sys.stderr)
        return 1

    errors: list[str] = []
    for patch_path in patches:
        locale = patch_path.stem
        target = I18N_DIR / f"{locale}.json"
        if not target.exists():
            errors.append(f"missing locale file for patch: {locale}")
            continue

        patch = json.loads(patch_path.read_text(encoding="utf-8"))
        data = json.loads(target.read_text(encoding="utf-8"))
        en = json.loads((I18N_DIR / "en_gb.json").read_text(encoding="utf-8"))

        for key, value in patch.items():
            if key not in data and key not in en:
                errors.append(f"{locale}: unknown key {key}")
                continue
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{locale}: empty value for {key}")
                continue
            en_val = en.get(key, "")
            for ph in PLACEHOLDERS:
                if ph in en_val and ph not in value:
                    errors.append(f"{locale}: missing {ph} in {key}")
            data[key] = value

        out = {k: data[k] for k in sorted(data)}
        target.write_text(
            json.dumps(out, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"merged {locale}: {len(patch)} keys")

    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1

    # Keep en_us in sync with en_gb for shared English strings.
    en_gb = json.loads((I18N_DIR / "en_gb.json").read_text(encoding="utf-8"))
    (I18N_DIR / "en_us.json").write_text(
        json.dumps({k: en_gb[k] for k in sorted(en_gb)}, ensure_ascii=False, indent=2)
        + "\n",
        encoding="utf-8",
    )
    print("synced en_us from en_gb")

    subprocess.check_call([sys.executable, str(ROOT / "tools" / "generate_i18n.py")])
    print("regenerated Dart translations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
