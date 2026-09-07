#!/usr/bin/env python3
"""
Audit Suite Runner: Executa a suite completa de auditoria de qualidade e arquitetura.
"""

import os
import subprocess
import sys

SCRIPTS = [
    ("monoliths.py", "scripts/audit/monoliths.py", "Controle de Monólitos (< 128 linhas)"),
    ("nanos.py", "scripts/audit/nanos.py", "Controle de Micro-scripts (>= 16 linhas)"),
    ("syntax.py", "scripts/audit/syntax.py", "Sintaxe POSIX, Shebangs & Diretrizes Shell"),
    ("links.py", "scripts/audit/links.py", "Integridade de Links Relativos (.md)"),
    ("formats.py", "scripts/audit/formats.py", "Validação de Formatos (JSON, YAML, PS1, REG)"),
]

def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
    results = []
    overall_success = True

    print("\n" + "=" * 80)
    print("🚀 INICIANDO SUITE COMPLETA DE AUDITORIA DO REPOSITÓRIO")
    print("=" * 80 + "\n")

    for name, rel_path, desc in SCRIPTS:
        full_path = os.path.join(repo_root, rel_path)
        print(f"▶️  Executando {name:14s} ({desc})...")
        res = subprocess.run([sys.executable, full_path], capture_output=True, text=True)
        is_ok = res.returncode == 0
        results.append((name, desc, is_ok, res.stdout, res.stderr))
        if not is_ok:
            overall_success = False

    print("\n" + "=" * 80)
    print("📊 RESUMO GERAL DA AUDITORIA")
    print("=" * 80)

    for name, desc, is_ok, stdout, stderr in results:
        status_icon = "✅ APROVADO" if is_ok else "❌ FALHOU"
        print(f"  {status_icon:12s} | {name:14s} | {desc}")
        if not is_ok:
            print("\n--- DETALHES DA FALHA ---")
            print(stdout or stderr)
            print("-------------------------\n")

    print("=" * 80)
    if overall_success:
        print("🎉 SUCESSO ABSOLUTO: 100% dos testes de auditoria foram aprovados!")
        print("=" * 80 + "\n")
        sys.exit(0)
    else:
        print("⚠️  ATENÇÃO: Foram encontradas inconformidades nos testes acima.")
        print("=" * 80 + "\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
