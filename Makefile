# =============================================================================
# Makefile — BST RISC-V + gem5
# =============================================================================

GEM5        := $(HOME)/gem5/build/RISCV/gem5.opt
#MODELS 		:= $(HOME)/Trabalho_org_gem5/gem5models
MODELS 		:= $(HOME)/OoO-deviations/models
BINARY      := $(HOME)/OoO-deviations/bst/bst_bin
SRC_DIR     := $(HOME)/OoO-deviations/bst
RESULTS_DIR := $(HOME)/OoO-deviations/resultados
TESTES_DIR  := $(HOME)/OoO-deviations/testes

SRCS := $(SRC_DIR)/menu_gcc_libc.s $(SRC_DIR)/bst_gcc_libc.s
CC   := riscv64-linux-gnu-gcc
CFLAGS := -static -g

SCRIPT_INORDER  := $(MODELS)/inorder.py
SCRIPT_OUTORDER := $(MODELS)/outorder.py


# trocar os tamanhos como achar necessário, pode colocar todos os tamanhos aqui
# múltiplos de 2, simulação provalvemente durará horas...
SIZES    := 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576

BP_TYPES := LocalBP BiModeBP

GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
RESET  := \033[0m

# =============================================================================
.PHONY: all build gerar-testes run-all run-outorder run-inorder \
        run-outorder-local run-outorder-bimode \
        run-inorder-local run-inorder-bimode \
        stats clean help

all: build

# --- Compilação ---------------------------------------------------------------
build:
	@echo "$(BLUE)Compilando $(BINARY)...$(RESET)"
	@mkdir -p $(SRC_DIR)
	$(CC) $(CFLAGS) -o $(BINARY) $(SRCS)
	@echo "$(GREEN)Build concluído!$(RESET)"

# --- Geração de testes --------------------------------------------------------
gerar-testes:
	@echo "$(BLUE)Gerando casos de teste...$(RESET)"
	python3 $(HOME)/OoO-deviations/gerador.py \
		--output-dir $(TESTES_DIR) \
		--sizes $(SIZES)
	@echo "$(GREEN)Casos gerados em $(TESTES_DIR)$(RESET)"

# --- Simulações OutOfOrder ----------------------------------------------------
run-outorder-local: build gerar-testes
	@echo "$(YELLOW)OutOfOrder + LocalBP$(RESET)"
	@$(foreach n,$(SIZES), \
		mkdir -p $(RESULTS_DIR)/outorder_LocalBP_n$(n); \
		echo "  n=$(n)..."; \
		$(GEM5) --outdir=$(RESULTS_DIR)/outorder_LocalBP_n$(n) \
			$(SCRIPT_OUTORDER) \
			--binary $(BINARY) \
			--input $(TESTES_DIR)/caso_$(n).txt \
			--bp-type LocalBP; \
	)
	@echo "$(GREEN)OutOfOrder LocalBP concluído!$(RESET)"

run-outorder-bimode: build gerar-testes
	@echo "$(YELLOW)OutOfOrder + BiModeBP$(RESET)"
	@$(foreach n,$(SIZES), \
		mkdir -p $(RESULTS_DIR)/outorder_BiModeBP_n$(n); \
		echo "  n=$(n)..."; \
		$(GEM5) --outdir=$(RESULTS_DIR)/outorder_BiModeBP_n$(n) \
			$(SCRIPT_OUTORDER) \
			--binary $(BINARY) \
			--input $(TESTES_DIR)/caso_$(n).txt \
			--bp-type BiModeBP; \
	)
	@echo "$(GREEN)OutOfOrder BiModeBP concluído!$(RESET)"

run-outorder: run-outorder-local run-outorder-bimode

# --- Simulações InOrder -------------------------------------------------------
run-inorder-local: build gerar-testes
	@echo "$(YELLOW)InOrder + LocalBP$(RESET)"
	@$(foreach n,$(SIZES), \
		mkdir -p $(RESULTS_DIR)/inorder_LocalBP_n$(n); \
		echo "  n=$(n)..."; \
		$(GEM5) --outdir=$(RESULTS_DIR)/inorder_LocalBP_n$(n) \
			$(SCRIPT_INORDER) \
			--binary $(BINARY) \
			--input $(TESTES_DIR)/caso_$(n).txt \
			--bp-type LocalBP; \
	)
	@echo "$(GREEN)InOrder LocalBP concluído!$(RESET)"

run-inorder-bimode: build gerar-testes
	@echo "$(YELLOW)InOrder + BiModeBP$(RESET)"
	@$(foreach n,$(SIZES), \
		mkdir -p $(RESULTS_DIR)/inorder_BiModeBP_n$(n); \
		echo "  n=$(n)..."; \
		$(GEM5) --outdir=$(RESULTS_DIR)/inorder_BiModeBP_n$(n) \
			$(SCRIPT_INORDER) \
			--binary $(BINARY) \
			--input $(TESTES_DIR)/caso_$(n).txt \
			--bp-type BiModeBP; \
	)
	@echo "$(GREEN)InOrder BiModeBP concluído!$(RESET)"

run-inorder: run-inorder-local run-inorder-bimode

# --- Roda tudo ----------------------------------------------------------------
run-all: run-outorder run-inorder
	@echo "$(GREEN)=== Todas as simulações concluídas! ===$(RESET)"
	@echo "Resultados em: $(RESULTS_DIR)"

# --- Métricas -----------------------------------------------------------------
stats:
	@echo "$(BLUE)Métricas extraídas dos stats.txt:$(RESET)"
	@for dir in $(RESULTS_DIR)/*/; do \
		if [ -f "$$dir/stats.txt" ]; then \
			echo ""; \
			echo "$(YELLOW)>>> $$(basename $$dir)$(RESET)"; \
			grep -E "sim_ticks|system.cpu.ipc|branchPred.lookups|branchPred.condIncorrect|committedInsts|squashedInsts" \
				"$$dir/stats.txt" 2>/dev/null || true; \
		fi; \
	done

# --- Limpeza ------------------------------------------------------------------
clean:
	rm -f $(BINARY)
	rm -rf $(RESULTS_DIR) $(TESTES_DIR)
	rm -f $(BINARY)
	rm -rf $(RESULTS_DIR)
	@echo "$(GREEN)Limpo!$(RESET)"	

# --- Ajuda --------------------------------------------------------------------
help:
	@echo "$(BLUE)Comandos disponíveis:$(RESET)"
	@echo "  make build               — compila o binário RISC-V"
	@echo "  make gerar-testes        — gera casos de teste (n=8,16,32,64)"
	@echo "  make run-outorder-local  — OoO + LocalBP para todos os casos"
	@echo "  make run-outorder-bimode — OoO + BiModeBP para todos os casos"
	@echo "  make run-outorder        — OoO com LocalBP e BiModeBP"
	@echo "  make run-inorder         — InOrder com LocalBP e BiModeBP"
	@echo "  make run-all             — todos os modelos e preditores"
	@echo "  make stats               — exibe métricas de todos os resultados"
	@echo "  make clean               — remove binário, testes e resultados"
	@echo "  make help                — exibe esta mensagem"
