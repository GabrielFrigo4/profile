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
    "node_modules",
    "var",
    "cache",
    "elpa",
    "vendor",
    "third_party",
}

IGNORE_FILES = {
    "plug.vim",
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
    ".el": {"prefixes": [";"]},
    ".conf": {"prefixes": ["#"]},
}

MAKEFILE_NAMES = {"Makefile", "GNUmakefile"}

if sys.stdout.isatty():
    C_RED = "\033[0;31m"
    C_GREEN = "\033[0;32m"
    C_YELLOW = "\033[1;33m"
    C_CYAN = "\033[0;36m"
    C_BOLD = "\033[1m"
    C_RESET = "\033[0m"
else:
    C_RED = C_GREEN = C_YELLOW = C_CYAN = C_BOLD = C_RESET = ""

def is_banner_delim_64(line):
    clean = re.sub(r"^(#|--|\"|;+|rem|::)\s*", "", line)
    return clean == "-" * 64

def is_banner_title(line):
    clean = re.sub(r"^(#|--|\"|;+|rem|::)\s*", "", line)
    return bool(re.match(r"^(Recipe|Utility|Module|Makefile|Config|Suite|Test|Auditor|Library|Package|Benchmark):", clean, re.I))

def is_section_delim_32(line):
    clean = re.sub(r"^(###|--|\"|;{2,3}|rem|::)\s*", "", line)
    return clean in ("=" * 32, "-" * 32)

def audit_file(filepath):
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        lines = [l.rstrip("\r\n") for l in f]

    ext = os.path.splitext(filepath)[1]
    base = os.path.basename(filepath)

    prefixes = LANG_CONFIG.get(ext, {}).get("prefixes", [])
    if not prefixes and base in MAKEFILE_NAMES:
        prefixes = ["#"]

    if not prefixes:
        return []

    issues = []
    in_ps1_block = False
    in_py_docstring = False

    for idx, raw_line in enumerate(lines, 1):
        line = raw_line.strip()
        if not line:
            continue

        if idx == 1 and line.startswith("#!"):
            continue

        if ext == ".ps1":
            if "<#" in line:
                in_ps1_block = True
                continue
            if "#>" in line:
                in_ps1_block = False
                continue

        if ext == ".py":
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

        if re.match(r"^(#|--|\"|;+|rem)\s*-{40,}$", line):
            dashes = len(re.sub(r"^(#|--|\"|;+|rem)\s*", "", line))
            if dashes != 64:
                issues.append((idx, "HEADER_BANNER_NOT_64", f"Banner possui {dashes} hífens (esperado 64): '{line}'"))
            continue

        if is_banner_title(line):
            continue

        sec_delim = re.match(r"^(###|--|\"|;{2,3}|rem)\s*(=|-){20,}$", line)
        if sec_delim:
            symbols = len(re.sub(r"^(###|--|\"|;{2,3}|rem)\s*", "", line))
            if symbols != 32:
                issues.append((idx, "SECTION_DELIM_NOT_32", f"Delimitador possui {symbols} caracteres (esperado 32): '{line}'"))
            continue

        prev_line = lines[idx - 2].strip() if idx >= 2 else ""
        next_line = lines[idx].strip() if idx < len(lines) else ""
        is_sec_boundary = is_section_delim_32(prev_line) or is_section_delim_32(next_line)

        if is_sec_boundary:
            title_text = re.sub(r"^(###|--|\"|;{2,3}|rem)\s+", "", line)
            if len(title_text) > 32:
                issues.append((idx, "SECTION_TITLE_OVERFLOW", f"Título vazou a régua de 32 caracteres ({len(title_text)}): '{title_text}'"))
            if re.search(r"[\(\)\[\]]", title_text):
                issues.append((idx, "SECTION_TITLE_PARENS", f"Título contém parênteses/colchetes: '{title_text}'"))
            continue

        if line.startswith("#!/"):
            continue

        issues.append((idx, "NARRATIVE_COMMENT", f"Comentário narrativo ou código morto: '{line}'"))

    return issues

def main():
    parser = argparse.ArgumentParser(description="Auditor estático de arquitetura de comentários e regras de não-vazamento.")
    parser.add_argument("target", nargs="?", default=".", help="Diretório ou arquivo a ser auditado (padrão: '.')")
    args = parser.parse_args()

    target_path = os.path.abspath(args.target)
    if not os.path.exists(target_path):
        print(f"{C_RED}❌ Caminho não encontrado: {target_path}{C_RESET}", file=sys.stderr)
        sys.exit(1)

    files_to_scan = []
    if os.path.isfile(target_path):
        files_to_scan.append(target_path)
    else:
        for root, dirs, files in os.walk(target_path):
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
            for f in files:
                if f in IGNORE_FILES:
                    continue
                ext = os.path.splitext(f)[1]
                if ext in LANG_CONFIG or f in MAKEFILE_NAMES:
                    files_to_scan.append(os.path.join(root, f))

    print(f"\n{C_CYAN}{C_BOLD}🔍 AUDITORIA DE ARQUITETURA DE COMENTÁRIOS (Clean Code){C_RESET}")
    print(f"{C_CYAN}Alvo: {target_path} ({len(files_to_scan)} arquivos){C_RESET}\n" + "-" * 70)

    total_issues = 0
    files_with_issues = 0

    for filepath in sorted(files_to_scan):
        issues = audit_file(filepath)
        if issues:
            files_with_issues += 1
            total_issues += len(issues)
            rel = os.path.relpath(filepath, target_path)
            print(f"\n{C_RED}❌ {rel} ({len(issues)} inconformidade(s)):{C_RESET}")
            for line_idx, kind, msg in issues:
                print(f"   L{line_idx:3d} [{C_YELLOW}{kind}{C_RESET}] {msg}")

    print("\n" + "=" * 70)
    if total_issues == 0:
        print(f"{C_GREEN}🎉 SUCESSO: Todos os {len(files_to_scan)} arquivos estão 100% em conformidade com a arquitetura de comentários!{C_RESET}\n")
        sys.exit(0)
    else:
        print(f"{C_RED}⚠️  ATENÇÃO: {total_issues} inconformidade(s) encontrada(s) em {files_with_issues} arquivo(s).{C_RESET}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
