#!/usr/bin/env python3
"""
Audit Nano Scripts: Varredura de integridade contra micro-scripts excessivamente fragmentados (< 8 linhas).
Filosofia: Equilíbrio arquitetural — evitar monolitos gigantes (> 128 linhas) e evitar
micro-scripts órfãos de 1 comando (< 8 linhas), unindo-os por temas coesos para navegação limpa no GitHub.
"""

import os
import sys
import argparse
from collections import defaultdict

DEFAULT_WHITELIST = {
    # Scripts onde 1 comando é a responsabilidade atômica estrita e intencional
}

def scan_nano_scripts(root_dir, min_lines=8, whitelist=None):
    if whitelist is None:
        whitelist = set()

    nano_scripts = []
    regular_scripts = []

    for root, dirs, files in os.walk(root_dir):
        if ".git" in root or "_OLD_" in root:
            continue
        for f in sorted(files):
            if f.endswith((".sh", ".cmd", ".ps1")):
                rel_path = os.path.relpath(os.path.join(root, f), root_dir)
                full_path = os.path.join(root, f)
                with open(full_path, "r", encoding="utf-8", errors="ignore") as file:
                    lines = [line.strip() for line in file.readlines() if line.strip() and not line.strip().startswith(("#", "rem", "@echo", "[CmdletBinding()"))]

                with open(full_path, "r", encoding="utf-8", errors="ignore") as file:
                    total_lines = len(file.readlines())

                is_whitelisted = rel_path in whitelist
                if total_lines < min_lines:
                    nano_scripts.append((total_lines, len(lines), rel_path, is_whitelisted))
                else:
                    regular_scripts.append((total_lines, len(lines), rel_path))

    nano_scripts.sort(key=lambda x: x[0])
    return nano_scripts, regular_scripts

def main():
    parser = argparse.ArgumentParser(description="Auditor de Micro-scripts / Nano-scripts")
    parser.add_argument("--min-lines", type=int, default=8, help="Limite mínimo de linhas recomendadas por script (padrão: 8)")
    parser.add_argument("--all", action="store_true", help="Exibe todos os scripts auditados")
    args = parser.parse_args()

    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
    nano_scripts, regular_scripts = scan_nano_scripts(root_dir, min_lines=args.min_lines, whitelist=DEFAULT_WHITELIST)

    print("=" * 80)
    print(f"AUDITORIA DE NANO-SCRIPTS (Limite mínimo recomendado: {args.min_lines} linhas)")
    print(f"Total de scripts escaneados: {len(nano_scripts) + len(regular_scripts)}")
    print("=" * 80)

    unapproved = [n for n in nano_scripts if not n[3]]
    approved = [n for n in nano_scripts if n[3]]

    if approved:
        print("\nExceções Permitidas:")
        for total, code, path, _ in approved:
            print(f"   [WHITELIST] {total:2d} linhas ({code:2d} cód) -> {path}")

    if unapproved:
        print(f"\n⚠️  {len(unapproved)} MICRO-SCRIPTS ENCONTRADOS (< {args.min_lines} linhas) - CANDIDATOS À CONSOLIDAÇÃO TEMÁTICA:\n")

        by_folder = defaultdict(list)
        for total, code, path, _ in unapproved:
            parent = os.path.dirname(path)
            by_folder[parent].append((total, code, path))

        for parent, items in sorted(by_folder.items()):
            print(f"📁 {parent}/ ({len(items)} scripts):")
            for total, code, path in items:
                name = os.path.basename(path)
                print(f"   • {total:2d} linhas ({code:2d} cód) -> {name}")
            print()
    else:
        print(f"\nSUCESSO: Nenhum micro-script excessivamente fragmentado encontrado (todos >= {args.min_lines} linhas).")

if __name__ == "__main__":
    main()
