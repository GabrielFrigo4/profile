#!/usr/bin/env python3
"""
Audit Monoliths: Varredura de integridade contra scripts monolíticos (> 128 linhas).
Filosofia: Cada script no Configuration deve ser uma receita atômica, modular e focada.
"""

import os
import sys
import argparse

DEFAULT_WHITELIST = {
    "bootstrap/windows/native/pkg/winget.cmd",
    "software/terminals/powershell/profile.ps1",
}


def scan_repository(root_dir, limit=128, whitelist=None):
    if whitelist is None:
        whitelist = set()

    monoliths = []
    clean_scripts = []

    for root, dirs, files in os.walk(root_dir):
        if ".git" in root or "_OLD_" in root:
            continue
        for f in sorted(files):
            if f.endswith((".sh", ".cmd", ".ps1")):
                rel_path = os.path.relpath(os.path.join(root, f), root_dir)
                full_path = os.path.join(root, f)
                with open(full_path, "r", encoding="utf-8", errors="ignore") as file:
                    lines = file.readlines()
                count = len(lines)

                is_whitelisted = rel_path in whitelist
                if count > limit:
                    monoliths.append((count, rel_path, is_whitelisted))
                else:
                    clean_scripts.append((count, rel_path))

    monoliths.sort(key=lambda x: x[0], reverse=True)
    return monoliths, clean_scripts


def main():
    parser = argparse.ArgumentParser(
        description="Auditor de Scripts Monolíticos")
    parser.add_argument("--limit", type=int, default=128,
                        help="Limite máximo de linhas por script (padrão: 128)")
    parser.add_argument("--all", action="store_true",
                        help="Exibe todos os scripts auditados")
    args = parser.parse_args()

    root_dir = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "../.."))
    monoliths, clean_scripts = scan_repository(
        root_dir, limit=args.limit, whitelist=DEFAULT_WHITELIST)

    print("=" * 80)
    print(f"AUDITORIA DE MONÓLITOS (Limite: {args.limit} linhas)")
    print(
        f"Total de scripts escaneados: {len(monoliths) + len(clean_scripts)}")
    print("=" * 80)

    unapproved = [m for m in monoliths if not m[2]]
    approved = [m for m in monoliths if m[2]]

    if approved:
        print("\nExceções Permitidas (Catálogos / Profiles):")
        for count, path, _ in approved:
            print(f"   [WHITELIST] {count:4d} linhas -> {path}")

    if unapproved:
        print(
            f"\n{len(unapproved)} SCRIPTS MONOLÍTICOS ENCONTRADOS (> {args.limit} linhas):")
        for count, path, _ in unapproved:
            print(f"   {count:4d} linhas -> {path}")
        sys.exit(1)
    else:
        print(
            f"\nSUCESSO: Nenhum monólito encontrado! 100% dos scripts atendem à meta (< {args.limit} linhas).")
        sys.exit(0)


if __name__ == "__main__":
    main()
