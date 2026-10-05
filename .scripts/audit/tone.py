#!/usr/bin/env python3
"""
Audit Tone & Economy: Varredura de densidade de sinal, economia de tokens e tom sóbrio.
Filosofia: Comunicação técnica assertiva estilo RFC 2119.
- Detecção de superlativos dramáticos e jargão jurídico ("terminantemente proibido", "proibição absoluta", "erro fatal").
- Detecção de escapes octais ANSI em blocos de código e comandos.
- Exclusão contextual para linhas de documentação que exemplificam anti-padrões.
"""

import os
import re
import sys
import argparse

BANNED_PATTERNS = [
    (
        re.compile(r"\bterminantemente\s+(?:proibid[oa]s?|vedad[oa]s?)\b", re.IGNORECASE),
        "Substitua por diretiva declarativa ('Evite', 'Não use', 'Incompatível com').",
    ),
    (
        re.compile(r"\bproibi[çc][ãa]o\s+(?:absoluta|irrestrita)\b", re.IGNORECASE),
        "Substitua por 'Regra de...', 'Diretriz de...' ou 'Banimento de...'.",
    ),
    (
        re.compile(r"\berro\s+fatal\s*\(mon[óo]lito\)", re.IGNORECASE),
        "Substitua por 'Teto Máximo (Monólito)' ou 'Excede o orçamento'.",
    ),
    (
        re.compile(r"\bcl[áa]usulas?\s+p[ée]treas?\b", re.IGNORECASE),
        "Substitua por 'Regras Canônicas de Domínio' ou 'Invariantes'.",
    ),
    (
        re.compile(r"\bsob\s+pena\s+de\s+(?:nulidade|falha|quebra\s+fatal)\b", re.IGNORECASE),
        "Substitua pela consequência técnica objetiva sem tom intimidador.",
    ),
    (
        re.compile(r"\binvariante\s+sagrada\b", re.IGNORECASE),
        "Substitua por 'Invariante de...' ou 'Contrato Invariante'.",
    ),
    (
        re.compile(r"\bmon[óo]lito\s+fatal\b", re.IGNORECASE),
        "Substitua por 'Teto Máximo (Monólito)'.",
    ),
    (
        re.compile(r"\bfalha\s+sum[áa]ria\b", re.IGNORECASE),
        "Substitua por 'interrupção de execução' ou 'incompatibilidade'.",
    ),
]

OCTAL_PATTERN = re.compile(r"\\033|\\001|\\077")

BYPASS_MARKERS = [
    "| _\"",
    "(*\"",
    "anti-padrão",
    "anti-padrao",
    "evite:",
    "evite -",
    "exemplo de anti-padrão",
    "tone-and-economy.md",
]


def is_bypass_line(line, filepath):
    base = os.path.basename(filepath)
    if "tone-and-economy" in base:
        return True

    lower = line.lower()
    for marker in BYPASS_MARKERS:
        if marker in lower:
            return True
    return False


def scan_file(filepath):
    # Ignora o próprio script de auditoria de tom
    if os.path.basename(filepath) == "tone.py":
        return []

    issues = []
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
    except Exception as e:
        return [(0, "leitura", f"Falha ao ler arquivo: {e}")]

    in_code_block = False

    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()

        if stripped.startswith("```"):
            in_code_block = not in_code_block
            continue

        if is_bypass_line(line, filepath):
            continue

        # 1. Checagem de frases proibidas fora de blocos de código
        if not in_code_block and not filepath.endswith((".py", ".sh")):
            for pattern, suggestion in BANNED_PATTERNS:
                match = pattern.search(line)
                if match:
                    matched_text = match.group(0)
                    issues.append(
                        (
                            idx,
                            "Tom Hiperbólico",
                            f"Encontrado '{matched_text}'. Sugestão: {suggestion}",
                        )
                    )

        # 2. Checagem de escapes octais proibidos (\033, \001) em código
        # Ignora arquivos de auditoria que apenas testam ou linteam o padrão
        if (in_code_block or filepath.endswith((".sh", ".py", ".bash", ".zsh"))) and "audit/" not in filepath:
            octal_match = OCTAL_PATTERN.search(line)
            if octal_match:
                matched_octal = octal_match.group(0)
                issues.append(
                    (
                        idx,
                        "Escape Octal Proibido",
                        f"Uso de '{matched_octal}'. Use '$'\\e'' ou '\\x1b' para cores/escapes ANSI.",
                    )
                )

    return issues


def scan_directory(target_dir):
    all_issues = {}
    total_files = 0

    for root, dirs, files in os.walk(target_dir):
        dirs[:] = [d for d in dirs if d not in {".git", ".system_generated", "__pycache__", "node_modules"}]

        for file in sorted(files):
            if not file.endswith((".md", ".sh", ".py")):
                continue

            filepath = os.path.join(root, file)
            rel_path = os.path.relpath(filepath, target_dir)
            total_files += 1

            file_issues = scan_file(filepath)
            if file_issues:
                all_issues[rel_path] = file_issues

    return all_issues, total_files


def main():
    parser = argparse.ArgumentParser(description="Auditor de Tom Técnico & Economia de Tokens")
    parser.add_argument(
        "--path",
        type=str,
        default="",
        help="Caminho do diretório a auditar (padrão: raiz do Profile)",
    )
    args = parser.parse_args()

    if args.path:
        target_dir = os.path.abspath(args.path)
    else:
        target_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))

    all_issues, total_files = scan_directory(target_dir)

    print("=" * 80)
    print(f"AUDITORIA DE TOM TÉCNICO & ESCAPES ANSI ({total_files} arquivos analisados)")
    print(f"Diretório: {target_dir}")
    print("=" * 80)

    if not all_issues:
        print("\nSUCESSO: Nenhum padrão hiperbólico ou escape octal proibido encontrado!")
        print("=" * 80 + "\n")
        sys.exit(0)

    print(f"\n⚠️  {len(all_issues)} ARQUIVO(S) COM INCONFORMIDADES DE TOM OU ESCAPES:")
    for filepath, issues in all_issues.items():
        print(f"\n📄 {filepath}:")
        for line_num, category, msg in issues:
            print(f"   [L{line_num:4d}] [{category}] {msg}")

    print("\n" + "=" * 80)
    print("RECOMENDAÇÃO: Adote gramática contrastiva (Regra -> Evite -> Use) e escapes $'\\e'.")
    print("=" * 80 + "\n")
    sys.exit(1)


if __name__ == "__main__":
    main()
