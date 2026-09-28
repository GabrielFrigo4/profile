#!/usr/bin/env python3
"""
Audit Skills: Varredura de integridade e orçamento canônico para Portable AI Skills.
Filosofia: Orçamento de Linhas (Regra 17 - 128 - 256).
- Piso Rígido: < 17 linhas (Erro Fatal - sem substância procedimental)
- Sweet Spot Canônico: 17 a 128 linhas
- Faixa de Densidade: 129 a 256 linhas
- Teto Rígido (Monólito): > 256 linhas (Erro Fatal)
- Validações Adicionais: Frontmatter YAML (name e description), octais proibidos (\\033).
"""

import os
import re
import sys
import argparse


def scan_skills(skills_dir, min_lines=17, sweet_spot=128, max_lines=256):
    errors = []
    warnings = []
    clean_skills = []

    if not os.path.exists(skills_dir):
        return errors, warnings, clean_skills

    for entry in sorted(os.listdir(skills_dir)):
        skill_path = os.path.join(skills_dir, entry)
        if not os.path.isdir(skill_path):
            continue

        skill_md = os.path.join(skill_path, "SKILL.md")
        if not os.path.isfile(skill_md):
            errors.append((entry, "SKILL.md ausente no diretório"))
            continue

        with open(skill_md, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()

        line_count = len(lines)
        content = "".join(lines)

        # 1. Validação de Frontmatter
        frontmatter_match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
        if not frontmatter_match:
            errors.append((entry, "Frontmatter YAML delimitado por '---' ausente no topo"))
            continue

        fm_text = frontmatter_match.group(1)
        name_match = re.search(r"^name:\s*([^\s]+)", fm_text, re.MULTILINE)
        desc_match = re.search(r"^description:\s*(.+)", fm_text, re.MULTILINE)

        if not name_match:
            errors.append((entry, "Campo 'name' ausente no frontmatter"))
        else:
            declared_name = name_match.group(1).strip()
            if declared_name != entry:
                errors.append((entry, f"Nome no frontmatter '{declared_name}' diverge do diretório '{entry}'"))

        if not desc_match:
            errors.append((entry, "Campo 'description' ausente no frontmatter"))

        # 2. Orçamento Canônico de Linhas
        if line_count < min_lines:
            errors.append((entry, f"Abaixo do piso mínimo ({line_count} < {min_lines} linhas)"))
        elif line_count > max_lines:
            errors.append((entry, f"Monólito fatal: excede teto ({line_count} > {max_lines} linhas)"))
        elif line_count > sweet_spot:
            warnings.append((entry, line_count))
            clean_skills.append((entry, line_count))
        else:
            clean_skills.append((entry, line_count))

        # 3. Verificação de Escapes Octais Proibidos em Blocos de Código
        code_blocks = re.findall(r"```(?:[a-zA-Z0-9_-]+)?\n(.*?)\n```", content, re.DOTALL)
        has_octal_code = any(r"\033" in block or r"\001" in block for block in code_blocks)
        if has_octal_code:
            errors.append((entry, "Uso proibido de escapes octais (\\033 ou \\001) em bloco de código; utilize notação hexadecimal \\x1b ou [ -t 1 ] && echo -n $'\\e...'"))

    return errors, warnings, clean_skills


def main():
    parser = argparse.ArgumentParser(description="Auditor Canônico de Portable AI Skills")
    parser.add_argument("--min-lines", type=int, default=17, help="Piso mínimo de linhas (padrão: 17)")
    parser.add_argument("--sweet-spot", type=int, default=128, help="Teto do sweet spot (padrão: 128)")
    parser.add_argument("--max-lines", type=int, default=256, help="Teto rígido fatal (padrão: 256)")
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    skills_dir = os.path.join(repo_root, "skills")

    errors, warnings, clean_skills = scan_skills(
        skills_dir,
        min_lines=args.min_lines,
        sweet_spot=args.sweet_spot,
        max_lines=args.max_lines
    )

    total_scanned = len(clean_skills) + len([e for e in errors if "ausente" not in e[1]])
    print("=" * 80)
    print(f"AUDITORIA DE SKILLS (Piso: {args.min_lines} | Sweet Spot: <= {args.sweet_spot} | Teto: <= {args.max_lines} linhas)")
    print(f"Total de skills auditadas: {len(clean_skills)}")
    print("=" * 80)

    if warnings:
        print(f"\n⚠️  {len(warnings)} SKILL(S) NA FAIXA DE DENSIDADE ({args.sweet_spot + 1} a {args.max_lines} linhas):")
        for name, count in warnings:
            print(f"   {count:4d} linhas -> skills/{name}/SKILL.md")

    if errors:
        print(f"\n❌ ERRO FATAL: {len(errors)} INCONFORMIDADE(S) ENCONTRADA(S):")
        for name, err_msg in errors:
            print(f"   • [{name}]: {err_msg}")
        sys.exit(1)
    else:
        print(f"\nSUCESSO: 100% das {len(clean_skills)} skills respeitam a anatomia canônica e o orçamento de linhas!")
        sys.exit(0)


if __name__ == "__main__":
    main()
