#!/bin/bash
# ============================================================================
# wsl-devkit — ponto de entrada principal
# ----------------------------------------------------------------------------
# Chama os scripts que ficam na pasta scripts/:
#   • scripts/setup.sh  -> instala e configura o ambiente
#   • scripts/check.sh  -> verifica o ambiente
#
# Uso:
#   ./main.sh          # abre o menu interativo
#   ./main.sh setup    # roda a instalação
#   ./main.sh check    # roda a verificação
#   ./main.sh help     # mostra a ajuda
# ============================================================================

set -eo pipefail

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Diretório onde este script está (resolve a partir de qualquer CWD)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/scripts/setup.sh"
CHECK_SCRIPT="$SCRIPT_DIR/scripts/check.sh"

# Garante que os scripts existem
for s in "$SETUP_SCRIPT" "$CHECK_SCRIPT"; do
    if [ ! -f "$s" ]; then
        echo -e "${RED}❌ Script não encontrado: $s${NC}"
        echo -e "${YELLOW}   Confirme que a pasta 'scripts/' está ao lado do main.sh.${NC}"
        exit 1
    fi
done

# Garante permissão de execução dos scripts
chmod +x "$SETUP_SCRIPT" "$CHECK_SCRIPT" 2>/dev/null || true

run_setup() {
    echo -e "${BLUE}▶️  Iniciando a instalação (scripts/setup.sh)...${NC}\n"
    "$SETUP_SCRIPT"
}

run_check() {
    echo -e "${BLUE}▶️  Iniciando a verificação (scripts/check.sh)...${NC}\n"
    "$CHECK_SCRIPT"
}

usage() {
    echo -e "${BOLD}🧰 wsl-devkit${NC}"
    echo ""
    echo -e "${BOLD}Uso:${NC} ./main.sh [comando]"
    echo ""
    echo -e "${BOLD}Comandos:${NC}"
    echo -e "  ${GREEN}setup${NC}   Instala e configura o ambiente WSL"
    echo -e "  ${GREEN}check${NC}   Verifica o ambiente instalado"
    echo -e "  ${GREEN}help${NC}    Mostra esta ajuda"
    echo ""
    echo -e "Sem argumentos, abre o menu interativo."
}

menu() {
    echo -e "${CYAN}${BOLD}🧰 wsl-devkit — setup do ambiente WSL${NC}\n"
    echo -e "  ${GREEN}1)${NC} Instalar / configurar o ambiente (setup)"
    echo -e "  ${GREEN}2)${NC} Verificar o ambiente (check)"
    echo -e "  ${GREEN}3)${NC} Sair"
    echo ""
    read -p "$(echo -e "${CYAN}Escolha uma opção [1-3]: ${NC}")" OPT || true
    echo ""
    case "${OPT:-}" in
        1) run_setup ;;
        2) run_check ;;
        3) echo -e "${YELLOW}Até mais! 👋${NC}" ;;
        *) echo -e "${RED}❌ Opção inválida: '${OPT:-}'${NC}"; exit 1 ;;
    esac
}

# Dispatcher: usa o 1º argumento como comando; sem argumento, abre o menu
case "${1:-}" in
    setup)          run_setup ;;
    check)          run_check ;;
    -h|--help|help) usage ;;
    "")             menu ;;
    *)              echo -e "${RED}❌ Comando desconhecido: '$1'${NC}\n"; usage; exit 1 ;;
esac
