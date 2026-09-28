#!/usr/bin/env python3
# ----------------------------------------------------------------
# Utility: Portable AI Skills - External URLs & Integrity Verifier
# ----------------------------------------------------------------

import argparse
import os
import re
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
if sys.stdout.isatty():
    BLUE = "\033[0;34m"
    GREEN = "\033[0;32m"
    RED = "\033[0;31m"
    YELLOW = "\033[1;33m"
    CYAN = "\033[0;36m"
    BOLD = "\033[1m"
    NC = "\033[0m"
else:
    BLUE = GREEN = RED = YELLOW = CYAN = BOLD = NC = ""
CTX = ssl.create_default_context()
CTX.check_hostname = False
CTX.verify_mode = ssl.CERT_NONE

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    )
}

URL_REGEX = re.compile(r'https?://[^\s)><"\'`]+')
IGNORE_PATTERNS = [
    "usuario/repo",
    "example.com",
    "localhost",
    "127.0.0.1",
    "https://...",
    "http://...",
    "<org>",
    "<repo>",
]


def extract_urls(file_path):
    """Extrai URLs válidas de um arquivo markdown."""
    found_urls = set()
    try:
        with open(file_path, "r", encoding="utf-8") as fh:
            for line in fh:
                if any(ig in line for ig in IGNORE_PATTERNS):
                    continue
                matches = URL_REGEX.findall(line)
                for u in matches:
                    cleaned = u.rstrip("`.,;:)\"'")
                    if cleaned.startswith("http://") or cleaned.startswith("https://"):
                        found_urls.add(cleaned)
    except Exception as err:
        print(f"{RED}Erro ao ler {file_path}: {err}{NC}", file=sys.stderr)
    return found_urls


def check_url(url_item):
    """Verifica uma URL individual e retorna status HTTP."""
    url, files = url_item
    try:
        parsed = urllib.parse.urlsplit(url)
        encoded_path = urllib.parse.quote(parsed.path, safe="/:@&=+$,-_.!~*'()")
        encoded_query = urllib.parse.quote(parsed.query, safe="/:@&=+$,-_.!~*'()?")
        safe_url = urllib.parse.urlunsplit(
            (parsed.scheme, parsed.netloc, encoded_path, encoded_query, parsed.fragment)
        )

        req = urllib.request.Request(safe_url, headers=HEADERS)
        with urllib.request.urlopen(req, context=CTX, timeout=10) as resp:
            return (url, resp.status, None, files)
    except urllib.error.HTTPError as err:
        return (url, err.code, None, files)
    except Exception as err:
        return (url, None, str(err), files)


def main():
    parser = argparse.ArgumentParser(
        description="Verificador automatizado de integridade de links para Portable AI Skills."
    )
    parser.add_argument(
        "target",
        nargs="?",
        default=None,
        help="Arquivo ou diretório de skills para verificar (padrão: diretório skills/ do repositório)",
    )
    parser.add_argument(
        "-w",
        "--workers",
        type=int,
        default=20,
        help="Número de threads simultâneas para requisições HTTP (padrão: 20)",
    )
    args = parser.parse_args()

    if args.target:
        target_path = os.path.abspath(args.target)
    else:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        candidate = os.path.abspath(os.path.join(script_dir, "..", ".."))
        if os.path.isdir(os.path.join(candidate, "skills")):
            target_path = os.path.join(candidate, "skills")
        else:
            target_path = os.path.abspath(os.path.join(script_dir, ".."))

    if not os.path.exists(target_path):
        print(f"{RED}❌ Alvo não encontrado: {target_path}{NC}", file=sys.stderr)
        sys.exit(1)

    print(f"{BLUE}{BOLD}🔎 Verificador de Links para Portable AI Skills{NC}")
    print(f"{CYAN}Alvo de inspeção:{NC} {target_path}")
    files_to_scan = []
    if os.path.isfile(target_path):
        if target_path.endswith(".md"):
            files_to_scan.append(target_path)
    else:
        for root, _, files in os.walk(target_path):
            for f in files:
                if f.endswith(".md"):
                    files_to_scan.append(os.path.join(root, f))

    if not files_to_scan:
        print(f"{YELLOW}Nenhum arquivo markdown (.md) encontrado para análise.{NC}")
        sys.exit(0)

    url_to_files = {}
    for fp in files_to_scan:
        urls = extract_urls(fp)
        for u in urls:
            url_to_files.setdefault(u, set()).add(fp)

    total_urls = len(url_to_files)
    print(f"{CYAN}Arquivos verificados:{NC} {len(files_to_scan)}")
    print(f"{CYAN}URLs únicas encontradas:{NC} {total_urls}\n")

    if total_urls == 0:
        print(f"{GREEN}Nenhuma URL externa encontrada.{NC}")
        sys.exit(0)

    print(f"{BLUE}Verificando status de conectividade em paralelo ({args.workers} threads)...{NC}")

    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = [executor.submit(check_url, item) for item in url_to_files.items()]
        for f in as_completed(futures):
            results.append(f.result())

    ok_list = []
    waf_list = []
    failed_list = []

    for url, status, err, files in sorted(results, key=lambda x: x[0]):
        rel_files = [os.path.basename(os.path.dirname(p)) + "/" + os.path.basename(p) for p in files]
        files_str = ", ".join(rel_files)

        if status in (200, 301, 302, 307, 308):
            ok_list.append((url, status))
            print(f"  {GREEN}✅ [{status}]{NC} {url}")
        elif status in (401, 403, 429):
            waf_list.append((url, status, files_str))
            print(f"  {YELLOW}🔒 [{status}]{NC} {url} {YELLOW}(Protegido por WAF/Anti-bot){NC} -> [{files_str}]")
        else:
            failed_list.append((url, status or err, files_str))
            print(f"  {RED}❌ [{status or err}]{NC} {url} -> [{files_str}]")

    print(f"\n{BOLD}{'=' * 60}{NC}")
    print(
        f"{BOLD}RESUMO:{NC} "
        f"{GREEN}{len(ok_list)} OK{NC} | "
        f"{YELLOW}{len(waf_list)} Protegidos{NC} | "
        f"{RED}{len(failed_list)} Falhas{NC}"
    )

    if failed_list:
        print(f"\n{RED}{BOLD}🚨 LINKS COM FALHA / INACESSÍVEIS DETECTADOS:{NC}")
        for url, err, f_str in failed_list:
            print(f"  • {url} ({err}) em [{f_str}]")
        print(f"\n{YELLOW}💡 Diretriz Canônica:{NC}")
        print("  1. Substitua o link quebrado pela página oficial correta e atualizada.")
        print("  2. Se a tecnologia não possuir link público ou for privada, mencione apenas seu nome em texto negrito sem hyperlink.")
        sys.exit(1)

    print(f"{GREEN}{BOLD}✨ Todos os links verificados são válidos e acessíveis!{NC}\n")
    sys.exit(0)


if __name__ == "__main__":
    main()
