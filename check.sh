#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Contadores
PASSED=0
FAILED=0
WARNINGS=0

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║          🔍 WSL ENVIRONMENT CHECK - Verificação do Ambiente          ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Função para verificar e reportar status
check_status() {
    local name="$1"
    local status="$2"
    local version="$3"
    
    if [ "$status" = "ok" ]; then
        echo -e "  ${GREEN}✅${NC} $name ${CYAN}($version)${NC}"
        ((PASSED++))
    elif [ "$status" = "warning" ]; then
        echo -e "  ${YELLOW}⚠️${NC}  $name ${YELLOW}($version)${NC}"
        ((WARNINGS++))
    else
        echo -e "  ${RED}❌${NC} $name ${RED}(não encontrado)${NC}"
        ((FAILED++))
    fi
}

# ============================================================================
# VERIFICAÇÃO: Git
# ============================================================================
echo -e "\n${BLUE}📦 Verificando Git...${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version 2>/dev/null | cut -d' ' -f3)
    GIT_NAME=$(git config --global user.name 2>/dev/null)
    GIT_EMAIL=$(git config --global user.email 2>/dev/null)
    check_status "Git" "ok" "v$GIT_VERSION"
    
    if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then
        echo -e "      └─ Usuário: ${CYAN}$GIT_NAME <$GIT_EMAIL>${NC}"
    else
        echo -e "      └─ ${YELLOW}⚠️  Git não configurado (user.name/user.email)${NC}"
        ((WARNINGS++))
    fi
else
    check_status "Git" "fail" ""
fi

# ============================================================================
# VERIFICAÇÃO: Python
# ============================================================================
echo -e "\n${BLUE}🐍 Verificando Python...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>/dev/null | cut -d' ' -f2)
    check_status "Python" "ok" "v$PYTHON_VERSION"
else
    check_status "Python" "fail" ""
fi

# Verificar pip
if command -v pip3 &> /dev/null; then
    PIP_VERSION=$(pip3 --version 2>/dev/null | cut -d' ' -f2)
    check_status "pip" "ok" "v$PIP_VERSION"
else
    check_status "pip" "fail" ""
fi

# Verificar venv
if python3 -c "import venv" 2>/dev/null; then
    check_status "venv module" "ok" "instalado"
else
    check_status "venv module" "fail" ""
fi

# ============================================================================
# VERIFICAÇÃO: Java
# ============================================================================
echo -e "\n${BLUE}☕ Verificando Java...${NC}"
if [ -d "$HOME/java/jdk-21.0.2" ]; then
    if [ -n "$JAVA_HOME" ]; then
        JAVA_VERSION=$($JAVA_HOME/bin/java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        check_status "Java JDK" "ok" "v$JAVA_VERSION"
        echo -e "      └─ JAVA_HOME: ${CYAN}$JAVA_HOME${NC}"
    else
        # Tenta usar diretamente
        JAVA_VERSION=$($HOME/java/jdk-21.0.2/bin/java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        check_status "Java JDK" "warning" "v$JAVA_VERSION - JAVA_HOME não definido"
        echo -e "      └─ ${YELLOW}Execute: source ~/.bashrc${NC}"
    fi
elif command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    check_status "Java (sistema)" "ok" "v$JAVA_VERSION"
else
    check_status "Java JDK" "fail" ""
fi

# ============================================================================
# VERIFICAÇÃO: Apache Spark / PySpark
# ============================================================================
echo -e "\n${BLUE}⚡ Verificando Apache Spark (PySpark)...${NC}"
if [ -d "$HOME/apache/spark-3.5.5" ]; then
    if [ -n "$SPARK_HOME" ]; then
        SPARK_VERSION=$($SPARK_HOME/bin/spark-submit --version 2>&1 | grep -oP 'version \K[0-9.]+' | head -1)
        if [ -z "$SPARK_VERSION" ]; then
            SPARK_VERSION="3.5.5"
        fi
        check_status "Apache Spark" "ok" "v$SPARK_VERSION"
        echo -e "      └─ SPARK_HOME: ${CYAN}$SPARK_HOME${NC}"
    else
        check_status "Apache Spark" "warning" "v3.5.5 - SPARK_HOME não definido"
        echo -e "      └─ ${YELLOW}Execute: source ~/.bashrc${NC}"
    fi
else
    check_status "Apache Spark" "fail" ""
fi

# Verificar PySpark (módulo Python)
if [ -n "$PYTHONPATH" ] && [ -d "$HOME/apache/spark-3.5.5/python" ]; then
    check_status "PySpark (PYTHONPATH)" "ok" "configurado"
else
    if [ -d "$HOME/apache/spark-3.5.5/python" ]; then
        check_status "PySpark (PYTHONPATH)" "warning" "não configurado - execute source ~/.bashrc"
    else
        check_status "PySpark" "fail" ""
    fi
fi

# ============================================================================
# VERIFICAÇÃO: Docker
# ============================================================================
echo -e "\n${BLUE}🐳 Verificando Docker...${NC}"
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
        check_status "Docker" "ok" "v$DOCKER_VERSION"
        
        # Verificar Docker Compose
        if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
            COMPOSE_VERSION=$(docker compose version 2>/dev/null | cut -d' ' -f4 || docker-compose --version 2>/dev/null | cut -d' ' -f3)
            check_status "Docker Compose" "ok" "v$COMPOSE_VERSION"
        else
            check_status "Docker Compose" "warning" "não encontrado"
        fi
    else
        check_status "Docker" "warning" "instalado mas não está rodando"
        echo -e "      └─ ${YELLOW}Verifique se o Docker Desktop está aberto no Windows${NC}"
    fi
else
    check_status "Docker" "fail" ""
    echo -e "      └─ ${RED}Docker Desktop não instalado ou integração WSL não habilitada${NC}"
fi

# ============================================================================
# VERIFICAÇÃO: Ambiente Virtual (venv)
# ============================================================================
echo -e "\n${BLUE}🔮 Verificando Ambiente Virtual...${NC}"

# Procura por venvs no home
VENV_FOUND=""
for dir in $HOME/.*; do
    if [ -d "$dir" ] && [ -f "$dir/bin/activate" ]; then
        VENV_NAME=$(basename "$dir")
        VENV_FOUND="$dir"
        VENV_PYTHON=$("$dir/bin/python" --version 2>/dev/null | cut -d' ' -f2)
        check_status "Virtual Environment ($VENV_NAME)" "ok" "Python $VENV_PYTHON"
        echo -e "      └─ Caminho: ${CYAN}$dir${NC}"
        break
    fi
done

if [ -z "$VENV_FOUND" ]; then
    check_status "Virtual Environment" "warning" "nenhuma venv encontrada em ~/"
fi

# Verificar alias activate
if grep -q "alias activate=" ~/.bashrc 2>/dev/null; then
    check_status "Alias 'activate'" "ok" "configurado no .bashrc"
else
    check_status "Alias 'activate'" "warning" "não configurado"
fi

# ============================================================================
# VERIFICAÇÃO: Variáveis de Ambiente
# ============================================================================
echo -e "\n${BLUE}🔧 Verificando Variáveis de Ambiente...${NC}"

if grep -q "JAVA_HOME" ~/.bashrc 2>/dev/null; then
    check_status "JAVA_HOME (bashrc)" "ok" "configurado"
else
    check_status "JAVA_HOME (bashrc)" "fail" ""
fi

if grep -q "SPARK_HOME" ~/.bashrc 2>/dev/null; then
    check_status "SPARK_HOME (bashrc)" "ok" "configurado"
else
    check_status "SPARK_HOME (bashrc)" "fail" ""
fi

if grep -q "PYTHONPATH" ~/.bashrc 2>/dev/null; then
    check_status "PYTHONPATH (bashrc)" "ok" "configurado"
else
    check_status "PYTHONPATH (bashrc)" "fail" ""
fi

# ============================================================================
# RESUMO FINAL
# ============================================================================
echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}                           📊 RESUMO${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${GREEN}✅ Passou:${NC}    $PASSED"
echo -e "  ${YELLOW}⚠️  Avisos:${NC}   $WARNINGS"
echo -e "  ${RED}❌ Falhou:${NC}    $FAILED"
echo ""

# Decisão final
if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         🎉 AMBIENTE CONFIGURADO CORRETAMENTE! 🎉                     ║${NC}"
    echo -e "${GREEN}║                                                                      ║${NC}"
    echo -e "${GREEN}║  Seu ambiente WSL está pronto para uso!                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
elif [ $FAILED -eq 0 ]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║         ⚠️  AMBIENTE COM ALGUNS AVISOS                               ║${NC}"
    echo -e "${YELLOW}║                                                                      ║${NC}"
    echo -e "${YELLOW}║  Seu ambiente está funcional, mas verifique os avisos acima.        ║${NC}"
    echo -e "${YELLOW}║                                                                      ║${NC}"
    echo -e "${YELLOW}║  💡 Dica: Execute 'source ~/.bashrc' para carregar as variáveis     ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║         ❌ AMBIENTE INCOMPLETO - SETUP NECESSÁRIO                    ║${NC}"
    echo -e "${RED}║                                                                      ║${NC}"
    echo -e "${RED}║  Algumas ferramentas não foram encontradas.                          ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "$(echo -e ${CYAN}"🔧 Deseja executar o setup.sh agora? [S/n]: "${NC})" RUN_SETUP
    
    if [[ ! "$RUN_SETUP" =~ ^[Nn]$ ]]; then
        echo ""
        echo -e "${GREEN}🚀 Iniciando setup.sh...${NC}"
        echo ""
        
        # Verifica se setup.sh existe e é executável
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [ -f "$SCRIPT_DIR/setup.sh" ]; then
            chmod +x "$SCRIPT_DIR/setup.sh"
            exec "$SCRIPT_DIR/setup.sh"
        else
            echo -e "${RED}❌ Arquivo setup.sh não encontrado em $SCRIPT_DIR${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Setup cancelado. Execute ./setup.sh quando estiver pronto.${NC}"
        exit 1
    fi
fi
