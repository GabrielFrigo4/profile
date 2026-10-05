#!/usr/bin/env python3
"""
Audit Nano Scripts: Varredura de integridade contra micro-scripts excessivamente fragmentados.
Filosofia: Orçamento de Linhas (Regra 8 - 16 - 128 - 256).
- Piso Rígido: < 8 linhas (Erro Fatal)
- Averiguação (Aviso): 8 a 16 linhas (Candidatos à consolidação temática)
- Faixa Canônica: 17 a 128 linhas
"""

import os
import sys
import argparse
from collections import defaultdict

DEFAULT_WHITELIST = set()


def scan_nano_scripts(root_dir, hard_min=8, soft_min=16, whitelist=None):
    if whitelist is None:
        whitelist = set()

    fatal_nanos = []
    warning_scripts = []
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
                if total_lines < hard_min:
                    fatal_nanos.append((total_lines, len(lines), rel_path, is_whitelisted))
                elif total_lines <= soft_min:
                    warning_scripts.append((total_lines, len(lines), rel_path, is_whitelisted))
                else:
                    regular_scripts.append((total_lines, len(lines), rel_path))

    fatal_nanos.sort(key=lambda x: x[0])
    warning_scripts.sort(key=lambda x: x[0])
    return fatal_nanos, warning_scripts, regular_scripts


def main():
    parser = argparse.ArgumentParser(description="Auditor de Micro-scripts / Nano-scripts")
    parser.add_argument("--hard-min", type=int, default=8, help="Piso mínimo rígido por script (padrão: 8)")
    parser.add_argument("--soft-min", type=int, default=16, help="Limite de averiguação por script (padrão: 16)")
    parser.add_argument("--all", action="store_true", help="Exibe todos os scripts auditados")
    args = parser.parse_args()

    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
    fatal_nanos, warning_scripts, regular_scripts = scan_nano_scripts(
        root_dir, hard_min=args.hard_min, soft_min=args.soft_min, whitelist=DEFAULT_WHITELIST)

    total_scanned = len(fatal_nanos) + len(warning_scripts) + len(regular_scripts)
    print("=" * 80)
    print(f"AUDITORIA DE NANO-SCRIPTS (Erro Fatal: < {args.hard_min} | Aviso: <= {args.soft_min} linhas)")
    print(f"Total de scripts escaneados: {total_scanned}")
    print("=" * 80)

    unapproved_fatal = [n for n in fatal_nanos if not n[3]]
    approved_fatal = [n for n in fatal_nanos if n[3]]

    if approved_fatal:
        print("\nExceções Permitidas:")
        for total, code, path, _ in approved_fatal:
            print(f"   [WHITELIST] {total:2d} linhas ({code:2d} cód) -> {path}")

    if warning_scripts:
        print(f"\n⚠️  {len(warning_scripts)} SCRIPTS EM ZONA DE AVERIGUAÇÃO ({args.hard_min} a {args.soft_min} linhas) - CANDIDATOS À CONSOLIDAÇÃO TEMÁTICA:\n")
        by_folder = defaultdict(list)
        for total, code, path, _ in warning_scripts:
            parent = os.path.dirname(path)
            by_folder[parent].append((total, code, path))

        for parent, items in sorted(by_folder.items()):
            print(f"📁 {parent}/ ({len(items)} scripts):")
            for total, code, path in items:
                name = os.path.basename(path)
                print(f"   • {total:2d} linhas ({code:2d} cód) -> {name}")
            print()

    if unapproved_fatal:
        print(f"\n❌ ERRO FATAL: {len(unapproved_fatal)} NANO-SCRIPTS INADMISSÍVEIS (< {args.hard_min} linhas):")
        for total, code, path, _ in unapproved_fatal:
            print(f"   {total:2d} linhas -> {path}")
        sys.exit(1)
    else:
        print(f"\nSUCESSO: Nenhum nano-script fatal encontrado (todos >= {args.hard_min} linhas).")
        sys.exit(0)


if __name__ == "__main__":
    main()
