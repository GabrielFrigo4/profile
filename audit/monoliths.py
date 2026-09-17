#!/usr/bin/env python3
"""
Audit Monoliths: Varredura de integridade contra scripts monolíticos (> 256 linhas).
Filosofia: Orçamento de Linhas (Regra 8 - 16 - 128 - 256).
- Sweet spot: <= 128 linhas
- Averiguação (Aviso): 129 a 256 linhas
- Erro Fatal: > 256 linhas (salvo Whitelist)
"""

import os
import sys
import argparse

# Whitelist com justificativa técnica explícita:
DEFAULT_WHITELIST = {
    # Perfil extensivo do PowerShell contendo inicialização de módulos e keybindings
    "terminals/powershell/profile.ps1",
}


def scan_repository(root_dir, soft_limit=128, hard_limit=256, whitelist=None):
    if whitelist is None:
        whitelist = set()

    fatal_monoliths = []
    warning_scripts = []
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
                if count > hard_limit:
                    fatal_monoliths.append((count, rel_path, is_whitelisted))
                elif count > soft_limit:
                    warning_scripts.append((count, rel_path, is_whitelisted))
                else:
                    clean_scripts.append((count, rel_path))

    fatal_monoliths.sort(key=lambda x: x[0], reverse=True)
    warning_scripts.sort(key=lambda x: x[0], reverse=True)
    return fatal_monoliths, warning_scripts, clean_scripts


def main():
    parser = argparse.ArgumentParser(
        description="Auditor de Scripts Monolíticos")
    parser.add_argument("--soft-limit", type=int, default=128,
                        help="Limite de averiguação por script (padrão: 128)")
    parser.add_argument("--hard-limit", type=int, default=256,
                        help="Limite máximo rígido por script (padrão: 256)")
    parser.add_argument("--all", action="store_true",
                        help="Exibe todos os scripts auditados")
    args = parser.parse_args()

    root_dir = os.path.abspath(os.path.join(
        os.path.dirname(__file__), ".."))
    fatal_monoliths, warning_scripts, clean_scripts = scan_repository(
        root_dir, soft_limit=args.soft_limit, hard_limit=args.hard_limit, whitelist=DEFAULT_WHITELIST)

    total_scanned = len(fatal_monoliths) + len(warning_scripts) + len(clean_scripts)
    print("=" * 80)
    print(f"AUDITORIA DE MONÓLITOS (Aviso: > {args.soft_limit} | Erro Fatal: > {args.hard_limit} linhas)")
    print(f"Total de scripts escaneados: {total_scanned}")
    print("=" * 80)

    unapproved_fatal = [m for m in fatal_monoliths if not m[2]]
    approved_fatal = [m for m in fatal_monoliths if m[2]]

    if approved_fatal:
        print("\nExceções Permitidas em Whitelist (> 256 linhas):")
        for count, path, _ in approved_fatal:
            print(f"   [WHITELIST] {count:4d} linhas -> {path}")

    if warning_scripts:
        print(f"\n⚠️  {len(warning_scripts)} SCRIPTS EM ZONA DE AVERIGUAÇÃO ({args.soft_limit + 1} a {args.hard_limit} linhas):")
        for count, path, is_wl in warning_scripts:
            wl_tag = " [WHITELIST]" if is_wl else ""
            print(f"   {count:4d} linhas -> {path}{wl_tag}")

    if unapproved_fatal:
        print(f"\n❌ ERRO FATAL: {len(unapproved_fatal)} SCRIPTS MONOLÍTICOS ENCONTRADOS (> {args.hard_limit} linhas):")
        for count, path, _ in unapproved_fatal:
            print(f"   {count:4d} linhas -> {path}")
        sys.exit(1)
    else:
        print(f"\nSUCESSO: Nenhum monólito fatal encontrado! 100% dos scripts respeitam o teto rígido (<= {args.hard_limit} linhas).")
        sys.exit(0)


if __name__ == "__main__":
    main()
