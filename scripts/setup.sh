#!/bin/bash

# Aborta em caso de erro ou de falha em qualquer parte de um pipeline
set -eo pipefail

# ============================================================================
# CONFIGURAÇÃO — edite estas variáveis para escolher as versões instaladas
# ============================================================================
# Apache Spark: veja as versões em https://spark.apache.org/downloads.html
#   • 4.2.0  -> última versão (Spark 4.x, Scala 2.13)
#   • 4.0.4  -> Spark 4.x estável (padrão)
#   • 3.5.9  -> última manutenção da linha LTS 3.5 (máxima compatibilidade)
SPARK_VERSION="${SPARK_VERSION:-4.0.4}"

# JDK (Temurin/Adoptium). O Spark 4.x suporta Java 17 e 21 — use 21 (LTS).
JDK_FEATURE="${JDK_FEATURE:-21}"

# Marcadores do bloco gerenciado no ~/.bashrc (não altere após instalar)
BASHRC_MARK_BEGIN="# >>> wsl-devkit >>>"
BASHRC_MARK_END="# <<< wsl-devkit <<<"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${CYAN}

██╗    ██╗███████╗██╗         ███████╗███████╗████████╗██╗   ██╗██████╗ 
██║    ██║██╔════╝██║         ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
██║ █╗ ██║███████╗██║         ███████╗█████╗     ██║   ██║   ██║██████╔╝
██║███╗██║╚════██║██║         ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
╚███╔███╔╝███████║███████╗    ███████║███████╗   ██║   ╚██████╔╝██║     
 ╚══╝╚══╝ ╚══════╝╚══════╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                                                          
${NC}"

echo -e "${BOLD}🛠️  WSL Setup Script: Git + Python + Java + PySpark + Docker${NC}\n"

# ============================================================================
# FUNÇÃO: Verificar se Docker Desktop está instalado no Windows
# ============================================================================
check_docker_desktop() {
    echo -e "${BLUE}🐳 Verificando Docker e Docker Compose (via Docker Desktop)...${NC}"

    # O 'docker' e o 'docker compose' são fornecidos pela integração do Docker Desktop
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        DOCKER_VERSION="$(docker --version 2>/dev/null | sed 's/,.*//')"
        echo -e "${GREEN}✅ ${DOCKER_VERSION} detectado e funcionando!${NC}"

        # Docker Compose v2 (plugin) acompanha o Docker Desktop
        if docker compose version &> /dev/null; then
            COMPOSE_VERSION="$(docker compose version --short 2>/dev/null || true)"
            echo -e "${GREEN}✅ Docker Compose v${COMPOSE_VERSION} disponível!${NC}\n"
        else
            echo -e "${YELLOW}⚠️  Docker OK, mas o 'docker compose' (v2) não respondeu.${NC}"
            echo -e "${YELLOW}   Atualize o Docker Desktop para habilitar o Compose v2.${NC}\n"
        fi
        return 0
    fi

    # Docker não está disponível
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                    ⚠️  DOCKER DESKTOP NÃO ENCONTRADO                 ║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║                                                                      ║${NC}"
    echo -e "${RED}║  Para utilizar este ambiente WSL, você precisa ter o Docker         ║${NC}"
    echo -e "${RED}║  Desktop instalado no Windows com a integração WSL habilitada.      ║${NC}"
    echo -e "${RED}║                                                                      ║${NC}"
    echo -e "${RED}║  📥 Download: https://www.docker.com/products/docker-desktop        ║${NC}"
    echo -e "${RED}║                                                                      ║${NC}"
    echo -e "${RED}║  Após instalar:                                                     ║${NC}"
    echo -e "${RED}║  1. Abra o Docker Desktop                                           ║${NC}"
    echo -e "${RED}║  2. Vá em Settings > Resources > WSL Integration                    ║${NC}"
    echo -e "${RED}║  3. Habilite a integração com sua distribuição Ubuntu               ║${NC}"
    echo -e "${RED}║  4. Clique em 'Apply & Restart'                                     ║${NC}"
    echo -e "${RED}║  5. Execute este script novamente                                   ║${NC}"
    echo -e "${RED}║                                                                      ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}❌ Setup encerrado. Instale o Docker Desktop e tente novamente.${NC}"
    exit 1
}

# ============================================================================
# VERIFICAÇÃO INICIAL: Docker Desktop
# ============================================================================
check_docker_desktop

echo -e "${GREEN}🚀 Iniciando a configuração do ambiente WSL...${NC}\n"

# ============================================================================
# ETAPA 1: Atualizando pacotes e instalando essenciais (incluindo Git)
# ============================================================================
echo -e "${BLUE}📦 [1/7] Atualizando pacotes e instalando essenciais...${NC}"
sudo apt update && sudo apt install -y wget curl tar unzip git coreutils python-is-python3 python3-pip python3-venv
echo -e "${GREEN}✅ Pacotes essenciais instalados!${NC}\n"

# ============================================================================
# ETAPA 2: Configuração de DNS (opcional)
# ============================================================================
echo -e "${BLUE}🌐 [2/7] Configuração de DNS (opcional)...${NC}"
echo -e "${YELLOW}O WSL 2 moderno normalmente gerencia o DNS automaticamente.${NC}"
echo -e "${YELLOW}Fixar o DNS e torná-lo imutável (chattr +i) pode quebrar a conexão${NC}"
echo -e "${YELLOW}em redes com VPN ou proxy corporativo.${NC}"
read -p "$(echo -e ${CYAN}"Deseja fixar o DNS em 8.8.8.8 mesmo assim? [s/N]: "${NC})" SET_DNS || true
if [[ "${SET_DNS:-}" =~ ^[Ss]$ ]]; then
    sudo rm -f /etc/resolv.conf
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
    printf '[network]\ngenerateResolvConf = false\n' | sudo tee /etc/wsl.conf > /dev/null
    sudo chattr +i /etc/resolv.conf 2>/dev/null || true
    echo -e "${GREEN}✅ DNS fixado em 8.8.8.8!${NC}\n"
else
    echo -e "${GREEN}✅ DNS gerenciado automaticamente pelo WSL (recomendado).${NC}\n"
fi

# ============================================================================
# ETAPA 3: Instalando Java (Temurin JDK)
# ============================================================================
echo -e "${BLUE}☕ [3/7] Instalando Java (Temurin JDK ${JDK_FEATURE})...${NC}"
JAVA_HOME_PATH="$HOME/java/jdk-${JDK_FEATURE}"
if [ ! -x "$JAVA_HOME_PATH/bin/java" ]; then
    mkdir -p "$JAVA_HOME_PATH"
    JDK_URL="https://api.adoptium.net/v3/binary/latest/${JDK_FEATURE}/ga/linux/x64/jdk/hotspot/normal/eclipse"
    TMP_JDK="$(mktemp --suffix=.tar.gz)"
    echo -e "${CYAN}⬇️  Baixando o Temurin JDK ${JDK_FEATURE} (última atualização GA)...${NC}"
    if ! wget -q --show-progress -O "$TMP_JDK" "$JDK_URL"; then
        echo -e "${RED}❌ Falha ao baixar o JDK. Verifique sua conexão e tente novamente.${NC}"
        rm -f "$TMP_JDK"
        exit 1
    fi
    tar -xf "$TMP_JDK" -C "$JAVA_HOME_PATH" --strip-components=1
    rm -f "$TMP_JDK"
    echo -e "${GREEN}✅ Java (Temurin JDK ${JDK_FEATURE}) instalado em $JAVA_HOME_PATH!${NC}\n"
else
    echo -e "${YELLOW}⚠️  Java JDK ${JDK_FEATURE} já está instalado, pulando...${NC}\n"
fi

# ============================================================================
# ETAPA 4: Instalando Apache Spark (com PySpark)
# ============================================================================
echo -e "${BLUE}⚡ [4/7] Instalando Apache Spark ${SPARK_VERSION} (PySpark)...${NC}"
SPARK_HOME_PATH="$HOME/apache/spark-${SPARK_VERSION}"
SPARK_TGZ="spark-${SPARK_VERSION}-bin-hadoop3.tgz"
if [ ! -d "$SPARK_HOME_PATH" ]; then
    mkdir -p "$HOME/apache"
    TMP_SPARK="$(mktemp --suffix=.tgz)"
    echo -e "${CYAN}⬇️  Baixando ${SPARK_TGZ}...${NC}"
    # Versões atuais ficam no mirror; versões antigas migram para o archive da Apache
    if ! wget -q --show-progress -O "$TMP_SPARK" "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_TGZ}"; then
        echo -e "${YELLOW}↪️  Mirror principal indisponível. Tentando o archive da Apache...${NC}"
        if ! wget -q --show-progress -O "$TMP_SPARK" "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_TGZ}"; then
            echo -e "${RED}❌ Falha ao baixar o Apache Spark ${SPARK_VERSION}.${NC}"
            echo -e "${RED}   Verifique se a versão existe em https://spark.apache.org/downloads.html${NC}"
            rm -f "$TMP_SPARK"
            exit 1
        fi
    fi
    tar -xf "$TMP_SPARK" -C "$HOME/apache"
    mv "$HOME/apache/spark-${SPARK_VERSION}-bin-hadoop3" "$SPARK_HOME_PATH"
    rm -f "$TMP_SPARK"
    echo -e "${GREEN}✅ Apache Spark ${SPARK_VERSION} instalado em $SPARK_HOME_PATH!${NC}\n"
else
    echo -e "${YELLOW}⚠️  Apache Spark ${SPARK_VERSION} já está instalado, pulando...${NC}\n"
fi

# ============================================================================
# ETAPA 5: Configurando Git
# ============================================================================
echo -e "${BLUE}🔧 [5/7] Configurando Git...${NC}"
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                    📝 CONFIGURAÇÃO DO GIT                          ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verifica se já está configurado
CURRENT_NAME=$(git config --global user.name 2>/dev/null)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_EMAIL" ]; then
    echo -e "${YELLOW}Git já está configurado:${NC}"
    echo -e "  Nome:  ${GREEN}$CURRENT_NAME${NC}"
    echo -e "  Email: ${GREEN}$CURRENT_EMAIL${NC}"
    echo ""
    read -p "$(echo -e ${CYAN}"Deseja reconfigurar? [s/N]: "${NC})" RECONFIG
    if [[ ! "$RECONFIG" =~ ^[Ss]$ ]]; then
        echo -e "${GREEN}✅ Mantendo configuração atual do Git!${NC}\n"
    else
        read -p "$(echo -e ${CYAN}"Digite seu nome completo: "${NC})" GIT_NAME
        read -p "$(echo -e ${CYAN}"Digite seu email: "${NC})" GIT_EMAIL
        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"
        echo -e "${GREEN}✅ Git reconfigurado!${NC}\n"
    fi
else
    read -p "$(echo -e ${CYAN}"Digite seu nome completo: "${NC})" GIT_NAME
    read -p "$(echo -e ${CYAN}"Digite seu email: "${NC})" GIT_EMAIL
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    echo -e "${GREEN}✅ Git configurado!${NC}\n"
fi

# ============================================================================
# ETAPA 6: Criando Virtual Environment Global
# ============================================================================
echo -e "${BLUE}🐍 [6/7] Criando Virtual Environment Python...${NC}"
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║              🐍 CONFIGURAÇÃO DO AMBIENTE VIRTUAL                   ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

DEFAULT_VENV_NAME=".venv"
echo -e "${YELLOW}O ambiente virtual será criado em: ${BOLD}~/${DEFAULT_VENV_NAME}${NC}"
echo ""
read -p "$(echo -e ${CYAN}"📝 Nome da venv [pressione ENTER para '${DEFAULT_VENV_NAME}' ou digite outro]: "${NC})" VENV_NAME

# Se vazio, usa o padrão
if [ -z "$VENV_NAME" ]; then
    VENV_NAME="$DEFAULT_VENV_NAME"
fi

# Garante que começa com ponto se o usuário não colocou
if [[ ! "$VENV_NAME" == .* ]]; then
    VENV_NAME=".$VENV_NAME"
fi

VENV_PATH="$HOME/$VENV_NAME"

if [ -d "$VENV_PATH" ]; then
    echo -e "${YELLOW}⚠️  Ambiente virtual '$VENV_NAME' já existe em $VENV_PATH${NC}"
    read -p "$(echo -e ${CYAN}"Deseja recriar? [s/N]: "${NC})" RECREATE
    if [[ "$RECREATE" =~ ^[Ss]$ ]]; then
        rm -rf "$VENV_PATH"
        python3 -m venv "$VENV_PATH"
        echo -e "${GREEN}✅ Ambiente virtual recriado em: $VENV_PATH${NC}\n"
    else
        echo -e "${GREEN}✅ Mantendo ambiente virtual existente!${NC}\n"
    fi
else
    python3 -m venv "$VENV_PATH"
    echo -e "${GREEN}✅ Ambiente virtual criado em: $VENV_PATH${NC}\n"
fi

# ============================================================================
# ETAPA 7: Criando diretório de projetos
# ============================================================================
echo -e "${BLUE}📂 [7/7] Criando diretório de projetos...${NC}"
PROJECTS_DIR="$HOME/projects"
if [ -d "$PROJECTS_DIR" ]; then
    echo -e "${YELLOW}⚠️  Diretório '$PROJECTS_DIR' já existe, mantendo.${NC}\n"
else
    mkdir -p "$PROJECTS_DIR"
    echo -e "${GREEN}✅ Diretório de projetos criado em: $PROJECTS_DIR${NC}\n"
fi

# ============================================================================
# ETAPA FINAL: Gravando variáveis de ambiente no ~/.bashrc
# ============================================================================
echo -e "${BLUE}🔄 Configurando variáveis de ambiente no ~/.bashrc...${NC}"

# Descobre o zip do py4j que acompanha o Spark (o nome varia conforme a versão)
PY4J_ZIP="$(ls "$SPARK_HOME_PATH"/python/lib/py4j-*-src.zip 2>/dev/null | head -1 || true)"
if [ -n "$PY4J_ZIP" ]; then
    PYSPARK_PYTHONPATH="\$SPARK_HOME/python:\$SPARK_HOME/python/lib/$(basename "$PY4J_ZIP"):\$PYTHONPATH"
else
    PYSPARK_PYTHONPATH="\$SPARK_HOME/python:\$PYTHONPATH"
fi

# Remove qualquer bloco gerenciado anterior para manter o ~/.bashrc idempotente
if grep -qF "$BASHRC_MARK_BEGIN" "$HOME/.bashrc" 2>/dev/null; then
    sed -i "\|$BASHRC_MARK_BEGIN|,\|$BASHRC_MARK_END|d" "$HOME/.bashrc"
fi

cat >> "$HOME/.bashrc" <<EOF

$BASHRC_MARK_BEGIN
# Bloco gerado automaticamente pelo wsl-devkit. Não edite entre os marcadores.
# JAVA (Temurin JDK $JDK_FEATURE)
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="\$JAVA_HOME/bin:\$PATH"

# SPARK $SPARK_VERSION (PySpark)
export SPARK_HOME="$SPARK_HOME_PATH"
export SPARK_LOCAL_IP=127.0.0.1
export HADOOP_HOME="\$SPARK_HOME"
export PATH="\$SPARK_HOME/bin:\$PATH"
export PYTHONPATH="$PYSPARK_PYTHONPATH"
export PYSPARK_PYTHON=python3

# Ambiente virtual Python
alias activate="source $VENV_PATH/bin/activate"
$BASHRC_MARK_END
EOF
echo -e "${GREEN}✅ Variáveis adicionadas ao ~/.bashrc${NC}\n"

# Aplica as variáveis também na sessão atual
export JAVA_HOME="$JAVA_HOME_PATH"
export SPARK_HOME="$SPARK_HOME_PATH"
export HADOOP_HOME="$SPARK_HOME"
export SPARK_LOCAL_IP=127.0.0.1
export PATH="$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH"
if [ -n "$PY4J_ZIP" ]; then
    export PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/lib/$(basename "$PY4J_ZIP"):${PYTHONPATH:-}"
else
    export PYTHONPATH="$SPARK_HOME/python:${PYTHONPATH:-}"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           🎉 AMBIENTE WSL CONFIGURADO COM SUCESSO! 🎉                ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║                                                                      ║${NC}"
echo -e "${GREEN}║  ✅ Git configurado                                                  ║${NC}"
echo -e "${GREEN}║  ✅ Python + pip + venv                                              ║${NC}"
echo -e "${GREEN}║  ✅ Java JDK ${JDK_FEATURE}                                                      ║${NC}"
echo -e "${GREEN}║  ✅ Apache Spark ${SPARK_VERSION} (PySpark)                                     ║${NC}"
echo -e "${GREEN}║  ✅ Docker + Docker Compose (Docker Desktop)                         ║${NC}"
echo -e "${GREEN}║  ✅ Ambiente virtual em: ~/$VENV_NAME                                ${NC}"
echo -e "${GREEN}║  ✅ Diretório de projetos: ~/projects                                ║${NC}"
echo -e "${GREEN}║                                                                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  Para aplicar todas as configurações, execute:${NC}"
echo -e "${BOLD}   source ~/.bashrc${NC}"
echo ""
echo -e "${CYAN}💡 Dicas:${NC}"
echo -e "   • Use ${BOLD}activate${NC} para ativar o ambiente virtual"
echo -e "   • Coloque seus projetos em ${BOLD}~/projects${NC}"
echo -e "   • Use ${BOLD}./check.sh${NC} para verificar se tudo está funcionando"
echo ""

