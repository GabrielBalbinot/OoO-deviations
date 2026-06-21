#!/usr/bin/env python3
"""
Gerador de gráficos para análise de Branch Prediction em BST RISC-V
Lê o stats.csv gerado pelo extrair_metricas.py e gera gráficos comparativos
"""

import csv
import os
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

# ============================================================
# Configuração visual
# ============================================================
CORES = {
    "LocalBP":  "#E74C3C",   # vermelho
    "BiModeBP": "#2E86C1",   # azul
    "inorder":  "#27AE60",   # verde
    "outorder": "#8E44AD",   # roxo
}

MARKERS = {
    "LocalBP":  "o",
    "BiModeBP": "s",
}

plt.rcParams.update({
    "figure.facecolor": "white",
    "axes.facecolor":   "white",
    "axes.grid":        True,
    "grid.alpha":       0.3,
    "font.size":        11,
    "axes.titlesize":   13,
    "axes.labelsize":   11,
    "legend.fontsize":  10,
    "lines.linewidth":  2,
    "lines.markersize": 7,
})

OUTPUT_DIR = "./graficos"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ============================================================
# Leitura do CSV
# ============================================================
def ler_csv(path="stats.csv"):
    dados = []
    with open(path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            # converte numéricos
            for k, v in row.items():
                try:
                    row[k] = float(v) if v not in ("", "None") else None
                except ValueError:
                    pass
            dados.append(row)
    return dados

def filtrar(dados, modelo=None, preditor=None):
    resultado = dados
    if modelo:
        resultado = [d for d in resultado if d["modelo"] == modelo]
    if preditor:
        resultado = [d for d in resultado if d["preditor"] == preditor]
    return sorted(resultado, key=lambda x: x["n"] or 0)

def xs_ys(dados, campo):
    xs = [d["n"] for d in dados if d.get(campo) is not None]
    ys = [d[campo] for d in dados if d.get(campo) is not None]
    return xs, ys

# ============================================================
# Gráfico 1 — Miss Rate: LocalBP vs BiModeBP (OutOfOrder)
# ============================================================
def grafico_miss_rate(dados):
    fig, ax = plt.subplots(figsize=(9, 5))

    for bp in ["LocalBP", "BiModeBP"]:
        subset = filtrar(dados, modelo="outorder", preditor=bp)
        xs, ys = xs_ys(subset, "miss_rate")
        ax.plot(xs, ys, label=bp, color=CORES[bp],
                marker=MARKERS[bp], linestyle="-")

    ax.set_title("Taxa de Erro de Predição — OutOfOrder\nLocalBP vs BiModeBP")
    ax.set_xlabel("Tamanho da entrada (n)")
    ax.set_ylabel("Miss Rate (%)")
    ax.set_xscale("log", base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.legend()
    fig.tight_layout()
    path = os.path.join(OUTPUT_DIR, "1_miss_rate_LocalBP_vs_BiModeBP.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    print(f"Salvo: {path}")

# ============================================================
# Gráfico 2 — Squashed Instructions: LocalBP vs BiModeBP
# ============================================================
def grafico_squashed(dados):
    fig, ax = plt.subplots(figsize=(9, 5))

    for bp in ["LocalBP", "BiModeBP"]:
        subset = filtrar(dados, modelo="outorder", preditor=bp)
        xs, ys = xs_ys(subset, "squashed_issued")
        ax.plot(xs, ys, label=bp, color=CORES[bp],
                marker=MARKERS[bp], linestyle="-")

    ax.set_title("Instruções Descartadas (Squash) — OutOfOrder\nLocalBP vs BiModeBP")
    ax.set_xlabel("Tamanho da entrada (n)")
    ax.set_ylabel("Instruções descartadas")
    ax.set_xscale("log", base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.legend()
    fig.tight_layout()
    path = os.path.join(OUTPUT_DIR, "2_squashed_LocalBP_vs_BiModeBP.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    print(f"Salvo: {path}")

# ============================================================
# Gráfico 3 — IPC: LocalBP vs BiModeBP
# ============================================================
def grafico_ipc(dados):
    fig, ax = plt.subplots(figsize=(9, 5))

    for bp in ["LocalBP", "BiModeBP"]:
        subset = filtrar(dados, modelo="outorder", preditor=bp)
        xs, ys = xs_ys(subset, "ipc")
        ax.plot(xs, ys, label=bp, color=CORES[bp],
                marker=MARKERS[bp], linestyle="-")

    ax.set_title("IPC — OutOfOrder\nLocalBP vs BiModeBP")
    ax.set_xlabel("Tamanho da entrada (n)")
    ax.set_ylabel("IPC (instruções por ciclo)")
    ax.set_xscale("log", base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.legend()
    fig.tight_layout()
    path = os.path.join(OUTPUT_DIR, "3_ipc_LocalBP_vs_BiModeBP.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    print(f"Salvo: {path}")

# ============================================================
# Gráfico 4 — sim_ticks: LocalBP vs BiModeBP
# ============================================================
def grafico_ticks(dados):
    fig, ax = plt.subplots(figsize=(9, 5))

    for bp in ["LocalBP", "BiModeBP"]:
        subset = filtrar(dados, modelo="outorder", preditor=bp)
        xs, ys = xs_ys(subset, "sim_ticks")
        ax.plot(xs, ys, label=bp, color=CORES[bp],
                marker=MARKERS[bp], linestyle="-")

    ax.set_title("Tempo de Simulação (ticks) — OutOfOrder\nLocalBP vs BiModeBP")
    ax.set_xlabel("Tamanho da entrada (n)")
    ax.set_ylabel("sim_ticks")
    ax.set_xscale("log", base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.legend()
    fig.tight_layout()
    path = os.path.join(OUTPUT_DIR, "4_sim_ticks_LocalBP_vs_BiModeBP.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    print(f"Salvo: {path}")

# ============================================================
# Gráfico 5 — condIncorrect absoluto: LocalBP vs BiModeBP
# ============================================================
def grafico_cond_incorrect(dados):
    fig, ax = plt.subplots(figsize=(9, 5))

    for bp in ["LocalBP", "BiModeBP"]:
        subset = filtrar(dados, modelo="outorder", preditor=bp)
        xs, ys = xs_ys(subset, "cond_incorrect")
        ax.plot(xs, ys, label=bp, color=CORES[bp],
                marker=MARKERS[bp], linestyle="-")

    ax.set_title("Erros de Predição Absolutos — OutOfOrder\nLocalBP vs BiModeBP")
    ax.set_xlabel("Tamanho da entrada (n)")
    ax.set_ylabel("Desvios mal previstos")
    ax.set_xscale("log", base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.legend()
    fig.tight_layout()
    path = os.path.join(OUTPUT_DIR, "5_cond_incorrect_LocalBP_vs_BiModeBP.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    print(f"Salvo: {path}")

# ============================================================
# Gráfico 6 — Miss Rate: InOrder vs OutOfOrder (BiModeBP)
# ============================================================
def grafico_inorder_vs_outorder(dados):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # miss rate (igual nos dois — esperado)
    for modelo in ["inorder", "outorder"]:
        subset = filtrar(dados, modelo=modelo, preditor="BiModeBP")
        xs, ys = xs_ys(subset, "miss_rate")
        ax1.plot(xs, ys, label=modelo, color=CORES[modelo], marker="o")
    ax1.set_title("Miss Rate — InOrder vs OutOfOrder")
    ax1.set_xlabel("n")
    ax1.set_ylabel("Miss Rate (%)")
    ax1.set_xscale("log", base=2)
    ax1.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax1.legend()

    # squashed — aqui aparece a diferença real
    for modelo in ["inorder", "outorder"]:
        subset = filtrar(dados, modelo=modelo, preditor="BiModeBP")
        xs, ys = xs_ys(subset, "squashed_issued")
        ax2.plot(xs, ys, label=modelo, color=CORES[modelo], marker="o")
    ax2.set_title("Instruções Descartadas — InOrder vs OutOfOrder")
    ax2.set_xlabel("n")
    ax2.set_ylabel("squashed_issued")
    ax2.set_xscale("log", base=2)
    ax2.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax2.legend()

    fig.suptitle("Impacto do Modelo de Execução (BiModeBP)", fontsize=13)
    fig.tight_layout()
    path = os.path.join(OUTPUT_DIR, "6_inorder_vs_outorder.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    print(f"Salvo: {path}")

# ============================================================
# Main
# ============================================================
def main():
    csv_path = "stats.csv"
    if not os.path.exists(csv_path):
        print(f"Arquivo não encontrado: {csv_path}")
        return

    dados = ler_csv(csv_path)
    print(f"Carregados {len(dados)} registros do CSV\n")

    grafico_miss_rate(dados)
    grafico_squashed(dados)
    grafico_ipc(dados)
    grafico_ticks(dados)
    grafico_cond_incorrect(dados)
    grafico_inorder_vs_outorder(dados)

    print(f"\nTodos os gráficos salvos em: {OUTPUT_DIR}/")

if __name__ == "__main__":
    main()