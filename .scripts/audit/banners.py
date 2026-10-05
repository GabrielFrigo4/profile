#!/usr/bin/env python3
# ----------------------------------------------------------------
# Recipe: Banner & Section Ruler Geometry Validator
# ----------------------------------------------------------------
"""
Valida a geometria estrutural de banners (réguas de 32 e 64) e não-vazamento.
"""

import os
import re
import sys


def check_file(full_path, repo_root, fix=False):
    rel_path = os.path.relpath(full_path, repo_root)
    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
        lines = [line.rstrip("\r\n") for line in f]

    issues = []
    modified = False

    for idx, line in enumerate(lines):
        line_no = idx + 1

        m_sec = re.match(r"^###\s+(=+|-+)$", line)
        if m_sec:
            syms = m_sec.group(1)
            char = syms[0]
            if len(syms) != 32:
                issues.append(
                    f"L{line_no}: Régua de seção possui {len(syms)} caracteres (esperado 32): {line}"
                )
                if fix:
                    lines[idx] = f"### {char * 32}"
                    modified = True
            continue

        prev_line = lines[idx - 1] if idx > 0 else ""
        next_line = lines[idx + 1] if idx + 1 < len(lines) else ""
        is_prev_delim = bool(re.match(r"^###\s+(=|-){20,}$", prev_line))
        is_next_delim = bool(re.match(r"^###\s+(=|-){20,}$", next_line))

        if (is_prev_delim or is_next_delim) and line.startswith("### "):
            title = line[4:]
            if len(title) > 32:
                issues.append(
                    f"L{line_no}: Título vazou a régua de 32 caracteres ({len(title)} cols): '{title}'"
                )
            if re.search(r"[\(\)\[\]]", title):
                issues.append(
                    f"L{line_no}: Título da seção contém parênteses/colchetes: '{title}'"
                )
            continue

        if idx < 6:
            m_hdr = re.match(r"^#\s+(-+)$", line)
            if m_hdr:
                dashes = m_hdr.group(1)
                if len(dashes) >= 20 and len(dashes) != 64:
                    issues.append(
                        f"L{line_no}: Régua de cabeçalho possui {len(dashes)} hífens (esperado 64): {line}"
                    )
                    if fix:
                        lines[idx] = f"# {'-' * 64}"
                        modified = True
                continue

            is_prev_hdr = bool(re.match(r"^#\s+-{60,}$", prev_line))
            is_next_hdr = bool(re.match(r"^#\s+-{60,}$", next_line))
            if (is_prev_hdr or is_next_hdr) and line.startswith("# "):
                title = line[2:]
                if len(title) > 64:
                    issues.append(
                        f"L{line_no}: Título de cabeçalho vazou a régua de 64 hífens ({len(title)} cols): '{title}'"
                    )

    if fix and modified:
        with open(full_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

    return rel_path, issues


def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
    fix_mode = "--fix" in sys.argv
    args = [a for a in sys.argv[1:] if a != "--fix"]

    script_files = []
    if args:
        for arg in args:
            full = os.path.abspath(arg)
            if os.path.isfile(full):
                script_files.append(full)
    else:
        for root, dirs, files in os.walk(repo_root):
            if any(p in root for p in [".git", "_OLD_"]):
                continue
            for f in sorted(files):
                if f.endswith((".sh", ".ps1")):
                    script_files.append(os.path.join(root, f))

    print("=" * 80)
    print(f"AUDITORIA DE GEOMETRIA DE BANNERS & NÃO-VAZAMENTO ({len(script_files)} scripts)")
    print("=" * 80)

    failed = 0
    for full_path in script_files:
        rel_path, issues = check_file(full_path, repo_root, fix=fix_mode)
        if issues:
            failed += 1
            print(f"\n❌ {rel_path}:")
            for iss in issues:
                print(f"   • {iss}")

    if failed > 0:
        print(f"\nFALHA: {failed} script(s) com réguas fora do padrão ou títulos vazados.")
        sys.exit(1)
    else:
        print(f"\nSUCESSO: 100% dos {len(script_files)} scripts respeitam as réguas de 32 e 64!")
        sys.exit(0)


if __name__ == "__main__":
    main()
