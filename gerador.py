#!/usr/bin/env python3
"""
Gerador de casos de teste para BST RISC-V + gem5
Gera arquivos de entrada simulando as opções do menu interativo
"""

import random
import os
import argparse

def gerar_caso(n, seed=42):
    """
    Gera um caso de teste com n inserções, buscas e deleções.
    Retorna a string de entrada para o programa.
    """
    random.seed(seed)
    valores = random.sample(range(-99, 100000), n)
    linhas = []

    # inserções
    for v in valores:
        linhas.append("1")   # opção insert
        linhas.append(str(v))

    # busca que existe (hit)
    busca_hit = random.choice(valores)
    linhas.append("3")
    linhas.append(str(busca_hit))

    # busca que não existe (miss)
    linhas.append("3")
    linhas.append("999")

    # inorder
    linhas.append("5")

    # preorder
    linhas.append("4")

    # postorder
    linhas.append("6")

    # max e min
    linhas.append("8")
    linhas.append("9")

    # deleção de um nó folha (menor valor)
    menor = min(valores)
    linhas.append("2")
    linhas.append(str(menor))

    # inorder após deleção
    linhas.append("5")

    # sair
    linhas.append("0")

    return "\n".join(linhas) + "\n"


def main():
    sizes = [4, 8, 16, 32]
    parser = argparse.ArgumentParser(description="Gerador de casos de teste para BST")
    parser.add_argument("--output-dir", default="testes", help="Diretório de saída")
    parser.add_argument("--sizes", nargs="+", type=int, default=sizes,
                        help="Tamanhos dos casos de teste")
    parser.add_argument("--seed", type=int, default=42, help="Seed base para geração")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    for n in args.sizes:
        filename = os.path.join(args.output_dir, f"caso_{n}.txt")
        conteudo = gerar_caso(n, seed=args.seed + n)
        with open(filename, "w") as f:
            f.write(conteudo)
        print(f"Gerado: {filename} ({n} inserções + buscas + deleção)")

    print(f"\nTotal: {len(args.sizes)} casos em '{args.output_dir}/'")


if __name__ == "__main__":
    main()
