#!/usr/bin/env python3
# ----------------------------------------------------------------
# Utility: Clean Code Comment Architecture & Non-Leakage Auditor
# ----------------------------------------------------------------

import argparse
import os
import re
import sys

IGNORE_DIRS = {
    ".git",
    ".githooks",
    ".venv",
    "venv",
    "node_modules",
    "OSS",
    "elpaca",
    "elpa",
    "usr/local",
    "build",
    "dist",
    "target",
    "var",
    "tmp",
    "cache",
    ".cache",
    "vendor",
    "third_party",
    "_OLD_",
    "examples",
    "references",
    "resources",
    "templates",
    "terminals",
    "editors",
    "docs",
    "agents",
    "skills",
    "__pycache__",
}

LANG_CONFIG = {
    ".sh": {"prefixes": ["#"]},
    ".bash": {"prefixes": ["#"]},
    ".zsh": {"prefixes": ["#"]},
    ".ksh": {"prefixes": ["#"]},
    ".py": {"prefixes": ["#"]},
    ".ps1": {"prefixes": ["#", "<#"]},
    ".cmd": {"prefixes": ["rem", "::"]},
    ".bat": {"prefixes": ["rem", "::"]},
    ".lua": {"prefixes": ["--"]},
    ".vim": {"prefixes": ['"']},
}

MAKEFILE_NAMES = {"Makefile", "GNUmakefile"}

CODE_BLOCK_LANGS = {
    "sh": ["#"],
    "bash": ["#"],
    "zsh": ["#"],
    "ksh": ["#"],
    "shell": ["#"],
    "posix": ["#"],
    "py": ["#"],
    "python": ["#"],
    "ps1": ["#"],
    "powershell": ["#"],
    "cmd": ["rem", "::"],
    "bat": ["rem", "::"],
    "lua": ["--"],
    "make": ["#"],
    "makefile": ["#"],
}


def is_banner_delim(line):
    clean = re.sub(r"^(###|#|--|\"|;+|rem|::)\s*", "", line).strip()
    return clean in ("-" * 64, "=" * 64, "=" * 78, "=" * 80)


def is_banner_title(line):
    clean = re.sub(r"^(###|#|--|\"|;+|rem|::)\s*", "", line).strip()
    return bool(re.match(r"^(Recipe|Utility|Module|Interface|Scaffolding|Build|Example|Makefile|Config|Suite|Test|Auditor|Library|Package|Benchmark|Hook|Runner|Template):", clean, re.I))


def is_section_delim(line):
    clean = re.sub(r"^(###|#|--|\"|;{2,3}|rem|::)\s*", "", line).strip()
    return clean in ("=" * 32, "-" * 32, "=" * 64, "-" * 64, "=" * 78, "=" * 80)


def check_code_lines(lines, prefixes, is_py=False, is_ps1=False, ext=""):
    issues = []
    in_ps1_block = False
    in_py_docstring = False

    for idx, raw_line in enumerate(lines, 1):
        line = raw_line.strip()
        if not line:
            continue

        if idx == 1 and line.startswith("#!"):
            continue

        if is_ps1:
            if "<#" in line:
                in_ps1_block = True
                continue
            if "#>" in line:
                in_ps1_block = False
                continue

        if is_py:
            if line.startswith('"""') or line.startswith("'''"):
                if line.count('"""') == 2 or line.count("'''") == 2:
                    continue
                in_py_docstring = not in_py_docstring
                continue
            if in_py_docstring:
                continue

        is_comment = in_ps1_block
        if not is_comment:
            for p in prefixes:
                if line.startswith(p):
                    is_comment = True
                    break

        if not is_comment:
            continue

        if ext in (".cmd", ".bat") and line.startswith("::"):
            issues.append((idx, "BATCH_NON_CANONICAL_SYNTAX", f"Uso de '::' em vez do canônico 'rem': '{line}'"))
            continue

        if line.startswith("#!") or "shellcheck" in line or "noqa" in line or "type: ignore" in line or "-*- lexical-binding" in line:
            continue

        prev_line = lines[idx - 2].strip() if idx >= 2 else ""
        next_line = lines[idx].strip() if idx < len(lines) else ""

        if is_banner_delim(line):
            continue

        if is_banner_delim(prev_line) or is_banner_delim(next_line):
            continue

        if is_banner_title(line):
            continue

        if is_section_delim(line):
            continue

        if is_section_delim(prev_line) or is_section_delim(next_line):
            title_text = re.sub(r"^(###|#|--|\"|;{2,3}|rem|::)\s*", "", line).strip()
            if len(title_text) > 80:
                issues.append((idx, "SECTION_TITLE_OVERFLOW", f"Título de seção vazou a régua ({len(title_text)}): '{title_text}'"))
            elif re.search(r"[\(\)\[\]]", title_text):
                issues.append((idx, "SECTION_TITLE_PARENS", f"Título contém parênteses/colchetes: '{title_text}'"))
            continue

        issues.append((idx, "NARRATIVE_COMMENT", f"Comentário narrativo ou código morto: '{line}'"))

    return issues


def audit_file(filepath):
    ext = os.path.splitext(filepath)[1]
    base = os.path.basename(filepath)

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        lines = [l.rstrip("\r\n") for l in f]

    if ext == ".md":
        issues = []
        in_block = False
        block_lines = []
        block_start_idx = 0
        prefixes = []
        block_lang = ""

        for idx, line in enumerate(lines, 1):
            s = line.strip()
            if s.startswith("```"):
                if in_block:
                    if prefixes:
                        block_issues = check_code_lines(block_lines, prefixes, is_py=(block_lang in ("py", "python")), is_ps1=(block_lang in ("ps1", "powershell")), ext=f".{block_lang}")
                        for b_idx, kind, msg in block_issues:
                            issues.append((block_start_idx + b_idx, kind, msg))
                    in_block = False
                    block_lines = []
                    prefixes = []
                    block_lang = ""
                else:
                    in_block = True
                    block_start_idx = idx
                    block_lang = s[3:].strip().lower()
                    prefixes = CODE_BLOCK_LANGS.get(block_lang, [])
                continue
            if in_block and prefixes:
                block_lines.append(line)

        return issues

    prefixes = LANG_CONFIG.get(ext, {}).get("prefixes", [])
    if not prefixes and base in MAKEFILE_NAMES:
        prefixes = ["#"]

    if not prefixes:
        return []

    return check_code_lines(lines, prefixes, is_py=(ext == ".py"), is_ps1=(ext == ".ps1"), ext=ext)


def main():
    parser = argparse.ArgumentParser(description="Auditor estático de arquitetura de comentários e não-vazamento.")
    parser.add_argument("target", nargs="?", default=".", help="Diretório ou arquivo a ser auditado (padrão: '.')")
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
    if args.target != ".":
        target_path = os.path.abspath(args.target)
    else:
        target_path = repo_root

    if not os.path.exists(target_path):
        print(f"❌ Caminho não encontrado: {target_path}", file=sys.stderr)
        sys.exit(1)

    files_to_scan = []
    if os.path.isfile(target_path):
        files_to_scan.append(target_path)
    else:
        for root, dirs, files in os.walk(target_path):
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS and not any(ign in root.split(os.sep) for ign in IGNORE_DIRS)]
            for f in sorted(files):
                ext = os.path.splitext(f)[1]
                if ext in LANG_CONFIG or f in MAKEFILE_NAMES or ext == ".md":
                    files_to_scan.append(os.path.join(root, f))

    print("=" * 80)
    print(f"AUDITORIA DE ARQUITETURA DE COMENTÁRIOS (Clean Code) ({len(files_to_scan)} arquivos)")
    print("=" * 80)

    total_issues = 0
    files_with_issues = 0

    for filepath in sorted(files_to_scan):
        issues = audit_file(filepath)
        if issues:
            files_with_issues += 1
            total_issues += len(issues)
            rel = os.path.relpath(filepath, target_path)
            print(f"\n❌ {rel} ({len(issues)} inconformidade(s)):")
            for line_idx, kind, msg in issues:
                print(f"   L{line_idx:3d} [{kind}] {msg}")

    print("\n" + "=" * 80)
    if total_issues == 0:
        print(f"SUCESSO: 100% dos {len(files_to_scan)} arquivos estão em conformidade canônica ([PASS])!")
        print("=" * 80 + "\n")
        sys.exit(0)
    else:
        print(f"FALHA: {total_issues} inconformidade(s) encontrada(s) em {files_with_issues} arquivo(s).")
        print("=" * 80 + "\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
