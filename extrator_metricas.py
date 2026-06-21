#!/usr/bin/env python3
"""
Extrator de métricas dos stats.txt gerados pelo gem5
Percorre recursivamente a pasta resultados buscando stats.txt
"""

import os
import re
import csv

METRICAS = {
    "sim_ticks":         r"^simTicks\s+(\d+)",
    "sim_insts":         r"^simInsts\s+(\d+)",
    "ipc":               r"board\.processor\.cores\.core\.ipc\s+([\d.]+)",
    "lookups_total":     r"board\.processor\.cores\.core\.branchPred\.lookups_0::total\s+(\d+)",
    "cond_incorrect":    r"board\.processor\.cores\.core\.branchPred\.condIncorrect\s+(\d+)",
    "direct_cond":       r"board\.processor\.cores\.core\.branchPred\.lookups_0::DirectCond\s+(\d+)",
    "squashed_issued":   r"board\.processor\.cores\.core\.squashedInstsIssued\s+(\d+)",
    "squashed_examined": r"board\.processor\.cores\.core\.squashedInstsExamined\s+(\d+)",
    "decode_squashed":   r"board\.processor\.cores\.core\.decode\.squashedInsts\s+(\d+)",
    "clk_ticks":         r"board\.clk_domain\.clock\s+(\d+)",
    "l1d_misses":        r"board\.cache_hierarchy\.l1d-cache-0\.demandMisses::total\s+(\d+)",
    "l1d_miss_rate":     r"board\.cache_hierarchy\.l1d-cache-0\.demandMissRate::total\s+([\d.]+)",
}

def parse_dirname(dirname):
    """Extrai modelo, preditor e n do nome do diretório."""
    m = re.match(r"(inorder|outorder)_(\w+)_n(\d+)", dirname)
    if m:
        return m.group(1), m.group(2), int(m.group(3))
    return None, None, None

def extrair_metricas(stats_path):
    """Lê um stats.txt e extrai as métricas definidas."""
    valores = {k: None for k in METRICAS}

    try:
        with open(stats_path, "r") as f:
            conteudo = f.read()
    except Exception as e:
        print(f"    Erro ao ler {stats_path}: {e}")
        return valores

    for nome, padrao in METRICAS.items():
        m = re.search(padrao, conteudo, re.MULTILINE)
        if m:
            try:
                valores[nome] = float(m.group(1))
            except ValueError:
                valores[nome] = m.group(1)

    # calcula miss_rate
    cond = valores.get("cond_incorrect")
    direct = valores.get("direct_cond")
    if cond is not None and direct is not None and direct > 0:
        valores["miss_rate"] = round(cond / direct * 100, 4)
    else:
        valores["miss_rate"] = None

    # converte ticks para GHz
    clk = valores.get("clk_ticks")
    if clk is not None and clk > 0:
        valores["clk_ghz"] = round(1000 / clk, 2)
    else:
        valores["clk_ghz"] = None

    return valores

def main():
    base = "./resultados"
    resultados = []

    # percorre recursivamente buscando stats.txt
    for root, dirs, files in os.walk(base):
        if "stats.txt" in files:
            stats_path = os.path.join(root, "stats.txt")
            dirname = os.path.basename(root)

            modelo, preditor, n = parse_dirname(dirname)
            if modelo is None:
                print(f"  Ignorando (nome não reconhecido): {dirname}")
                continue

            metricas = extrair_metricas(stats_path)

            entrada = {
                "diretorio": dirname,
                "modelo":    modelo,
                "preditor":  preditor,
                "n":         n,
                **metricas
            }

            resultados.append(entrada)
            print(f"  OK: {dirname} | miss_rate={metricas.get('miss_rate')}% | "
                  f"cond_incorrect={metricas.get('cond_incorrect')} | "
                  f"squashed={metricas.get('squashed_issued')}")

    if not resultados:
        print("Nenhum resultado encontrado.")
        return

    # ordena por modelo, preditor e n
    resultados.sort(key=lambda x: (x["modelo"], x["preditor"], x["n"] or 0))

    # salva CSV
    csv_path = "stats.csv"
    colunas = ["diretorio", "modelo", "preditor", "n"] + list(METRICAS.keys()) + ["miss_rate", "clk_ghz"]
    with open(csv_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=colunas)
        writer.writeheader()
        writer.writerows(resultados)

    print(f"\nCSV salvo: {csv_path}")
    print(f"Total: {len(resultados)} simulações processadas")

if __name__ == "__main__":
    main()