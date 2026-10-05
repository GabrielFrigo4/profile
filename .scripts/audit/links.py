#!/usr/bin/env python3
"""
Audit Links: Valida integridade de links relativos em arquivos Markdown (.md).
"""

import os
import re
import sys
import urllib.parse


def check_markdown_links(repo_root):
    md_files = []
    for root, dirs, files in os.walk(repo_root):
        if ".git" in root or "_OLD_" in root:
            continue
        for f in sorted(files):
            if f.endswith(".md"):
                md_files.append(os.path.join(root, f))

    link_pattern = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
    broken = []
    total_links = 0

    for md_path in md_files:
        rel_md = os.path.relpath(md_path, repo_root)
        with open(md_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        content_no_code = re.sub(r"```[\s\S]*?```", "", content)

        for m in link_pattern.finditer(content_no_code):
            text, link = m.groups()
            link = link.strip()

            if link.startswith(("http://", "https://", "mailto:", "<http", "#")):
                continue

            total_links += 1
            parts = link.split("#", 1)
            target = parts[0].strip()
            if not target:
                continue

            if target.startswith("<") and target.endswith(">"):
                target = target[1:-1]

            target_decoded = urllib.parse.unquote(target)
            md_dir = os.path.dirname(md_path)
            resolved = os.path.normpath(os.path.join(md_dir, target_decoded))

            if not os.path.exists(resolved):
                broken.append((rel_md, text, link, resolved))

    return md_files, total_links, broken


def main():
    repo_root = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "../.."))
    md_files, total_links, broken = check_markdown_links(repo_root)

    print("=" * 80)
    print(
        f"AUDITORIA DE LINKS MARKDOWN ({len(md_files)} arquivos .md | {total_links} links relativos)")
    print("=" * 80)

    if broken:
        print(f"\n❌ {len(broken)} LINK(S) QUEBRADO(S) ENCONTRADO(S):")
        for rel_md, text, link, resolved in broken:
            print(
                f"   • [{rel_md}] [{text}]({link}) -> não existe: {resolved}")
        sys.exit(1)
    else:
        print(
            f"\nSUCESSO: 100% dos {total_links} links relativos em {len(md_files)} documentos são válidos!")
        sys.exit(0)


if __name__ == "__main__":
    main()
