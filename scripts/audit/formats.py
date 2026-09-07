#!/usr/bin/env python3
"""
Audit Formats: Valida integridade e sintaxe de formatos declarativos e scripts.
"""

import glob
import json
import os
import re
import sys

try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False


def strip_jsonc(text):
    result = []
    in_string = False
    in_line_comment = False
    in_block_comment = False
    escape = False
    i = 0
    while i < len(text):
        c = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if in_line_comment:
            if c == "\n":
                in_line_comment = False
                result.append(c)
            i += 1
            continue
        if in_block_comment:
            if c == "*" and nxt == "/":
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            result.append(c)
            if escape:
                escape = False
            elif c == "\\":
                escape = True
            elif c == "\"":
                in_string = False
            i += 1
            continue
        if c == "/" and nxt == "/":
            in_line_comment = True
            i += 2
            continue
        if c == "/" and nxt == "*":
            in_block_comment = True
            i += 2
            continue
        if c == "\"":
            in_string = True
            result.append(c)
            i += 1
            continue
        result.append(c)
        i += 1

    cleaned = "".join(result)
    return re.sub(r",\s*([\]}])", r"\1", cleaned)


def main():
    repo_root = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "../.."))
    errors = []
    scanned = 0

    # 1. JSON & JSONC
    for root, dirs, files in os.walk(repo_root):
        if ".git" in root or "_OLD_" in root:
            continue
        for f in files:
            if f.endswith(".json"):
                scanned += 1
                p = os.path.join(root, f)
                rel = os.path.relpath(p, repo_root)
                with open(p, "r", encoding="utf-8") as jf:
                    content = jf.read()
                try:
                    json.loads(strip_jsonc(content))
                except Exception as e:
                    errors.append(f"[JSON] {rel}: {e}")

    # 2. YAML
    if HAS_YAML:
        for root, dirs, files in os.walk(repo_root):
            if ".git" in root or "_OLD_" in root:
                continue
            for f in files:
                if f.endswith((".yaml", ".yml")):
                    scanned += 1
                    p = os.path.join(root, f)
                    rel = os.path.relpath(p, repo_root)
                    with open(p, "r", encoding="utf-8") as yf:
                        try:
                            list(yaml.safe_load_all(yf))
                        except Exception as e:
                            errors.append(f"[YAML] {rel}: {e}")

    # 3. Registry (.reg)
    for p in glob.glob(f"{repo_root}/**/*.reg", recursive=True):
        scanned += 1
        rel = os.path.relpath(p, repo_root)
        with open(p, "r", encoding="utf-8", errors="ignore") as f:
            first = f.readline().strip()
            if not first.startswith("Windows Registry Editor Version 5.00"):
                errors.append(f"[REG] {rel}: Cabeçalho inválido '{first}'")

    # 4. PowerShell (.ps1)
    for p in glob.glob(f"{repo_root}/**/*.ps1", recursive=True):
        scanned += 1
        rel = os.path.relpath(p, repo_root)
        with open(p, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            if content.count("{") != content.count("}"):
                errors.append(f"[PS1] {rel}: Chaves não balanceadas")
            if content.count("(") != content.count(")"):
                errors.append(f"[PS1] {rel}: Parênteses não balanceados")

    print("=" * 80)
    print(
        f"AUDITORIA DE FORMATOS DECLARATIVOS ({scanned} arquivos verificados)")
    print("=" * 80)

    if errors:
        print(f"\n❌ {len(errors)} ERRO(S) ENCONTRADO(S):")
        for err in errors:
            print(f"   • {err}")
        sys.exit(1)
    else:
        print(f"\nSUCESSO: 100% dos arquivos JSON, YAML, .reg e .ps1 são válidos!")
        sys.exit(0)


if __name__ == "__main__":
    main()
