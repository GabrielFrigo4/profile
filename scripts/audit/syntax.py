#!/usr/bin/env python3
"""
Audit Syntax & POSIX: Valida sintaxe, shebang, modo defensivo e regras de shell.
"""

import os
import re
import subprocess
import sys


def check_script(full_path, repo_root):
    rel_path = os.path.relpath(full_path, repo_root)
    issues = []

    res = subprocess.run(["sh", "-n", full_path],
                         capture_output=True, text=True)
    if res.returncode != 0:
        issues.append(f"Sintaxe POSIX inválida: {res.stderr.strip()}")

    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
        lines = [l.rstrip("\r\n") for l in f]

    if not lines or lines[0].strip() != "#!/usr/bin/env sh":
        first = lines[0] if lines else "Arquivo vazio"
        issues.append(
            f"Shebang não-canônico: '{first}' (esperado: '#!/usr/bin/env sh')")

    content = "\n".join(lines)
    if "set -eu" not in content:
        issues.append("Modo defensivo ausente (esperado: 'set -eu')")

    for idx, line in enumerate(lines, 1):
        if re.search(r">\s*/dev/null(?!\")", line) or re.search(r"2>\s*/dev/null(?!\")", line):
            if not re.search(r"> [\"\x27]/dev/null[\"\x27]", line):
                issues.append(
                    f"L{idx}: Redirecionamento para /dev/null sem aspas: {line.strip()}")

        for m in re.finditer(r"\bchmod\s+([0-9a-zA-Z\+\-\=]+)", line):
            mode = m.group(1)
            if re.match(r"^[0-7]{3}$", mode):
                issues.append(
                    f"L{idx}: chmod com 3 dígitos '{mode}' (esperado octal de 4 dígitos)")
            elif re.match(r"^[\+\-][rwxXst]+$", mode) or re.match(r"^[ugoa]+[\+\-\=]", mode):
                issues.append(
                    f"L{idx}: chmod simbólico '{mode}' (esperado octal de 4 dígitos)")

    return rel_path, issues


def main():
    repo_root = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "../.."))
    sh_files = []

    for root, dirs, files in os.walk(repo_root):
        if ".git" in root or "_OLD_" in root:
            continue
        for f in sorted(files):
            if f.endswith(".sh"):
                sh_files.append(os.path.join(root, f))

    print("=" * 80)
    print(f"AUDITORIA DE SINTAXE E PADRÕES POSIX ({len(sh_files)} scripts)")
    print("=" * 80)

    failed = 0
    for full_path in sh_files:
        rel_path, issues = check_script(full_path, repo_root)
        if issues:
            failed += 1
            print(f"\n❌ {rel_path}:")
            for iss in issues:
                print(f"   • {iss}")

    if failed > 0:
        print(
            f"\nFALHA: {failed} script(s) com violações de sintaxe ou diretrizes POSIX.")
        sys.exit(1)
    else:
        print(
            f"\nSUCESSO: 100% dos {len(sh_files)} scripts .sh estão em conformidade canônica!")
        sys.exit(0)


if __name__ == "__main__":
    main()
