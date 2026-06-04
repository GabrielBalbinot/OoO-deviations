# -*- coding: utf-8 -*-
import os
import m5
from m5.objects import *

from gem5.components.boards.simple_board import SimpleBoard
from gem5.components.cachehierarchies.classic.private_l1_private_l2_cache_hierarchy import PrivateL1PrivateL2CacheHierarchy
from gem5.components.memory.single_channel import SingleChannelDDR3_1600
from gem5.components.processors.cpu_types import CPUTypes
from gem5.components.processors.simple_processor import SimpleProcessor
from gem5.resources.resource import BinaryResource, FileResource
from gem5.simulate.simulator import Simulator
from gem5.isas import ISA

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--binary", type=str, required=True, help="Caminho para binario RISC-V")
parser.add_argument("--input",  type=str, default=None,  help="Arquivo de entrada (stdin)")
parser.add_argument("--bp-type", type=str, default="LocalBP",
                    choices=["LocalBP", "BiModeBP"],
                    help="Tipo de branch predictor (LocalBP ou BiModeBP)")
args = parser.parse_args()

binary_path = os.path.abspath(args.binary)

# CPU InOrder (MinorCPU)
processor = SimpleProcessor(cpu_type=CPUTypes.MINOR, num_cores=1, isa=ISA.RISCV)

cache_hierarchy = PrivateL1PrivateL2CacheHierarchy(
    l1d_size="32kB", l1i_size="32kB", l2_size="256kB"
)
memory = SingleChannelDDR3_1600("512MB")

board = SimpleBoard(
    clk_freq="3GHz",
    processor=processor,
    memory=memory,
    cache_hierarchy=cache_hierarchy,
)

binary = BinaryResource(local_path=binary_path)

if args.input:
    stdin = FileResource(local_path=os.path.abspath(args.input))
    board.set_se_binary_workload(binary, stdin_file=stdin)
else:
    board.set_se_binary_workload(binary)

simulator = Simulator(board=board)
print(f"Iniciando simulacao InOrder ({args.bp_type}) RISC-V...")
simulator.run()
print(f"Simulacao finalizada no tick {simulator.get_current_tick()}")
