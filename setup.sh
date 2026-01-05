#!/bin/bash

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
    echo -e "${BLUE}🐳 Verificando Docker Desktop no Windows...${NC}"
    
    # Verifica se o comando docker existe (integração WSL com Docker Desktop)
    if command -v docker &> /dev/null; then
        # Tenta executar docker info para verificar se está funcionando
        if docker info &> /dev/null; then
            echo -e "${GREEN}✅ Docker Desktop detectado e funcionando!${NC}\n"
            return 0
        fi
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
echo -e "${BLUE}📦 [1/6] Atualizando pacotes e instalando essenciais...${NC}"
sudo apt update && sudo apt install -y wget curl tar unzip git coreutils python-is-python3 python3-pip python3-venv
echo -e "${GREEN}✅ Pacotes essenciais instalados!${NC}\n"

# ============================================================================
# ETAPA 2: Configurando DNS fixo para WSL
# ============================================================================
echo -e "${BLUE}🌐 [2/6] Configurando DNS...${NC}"
sudo rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
echo "[network]" | sudo tee /etc/wsl.conf > /dev/null
echo "generateResolvConf = false" | sudo tee -a /etc/wsl.conf > /dev/null
sudo chattr +i /etc/resolv.conf 2>/dev/null || true
echo -e "${GREEN}✅ DNS configurado!${NC}\n"

# ============================================================================
# ETAPA 3: Instalando Java JDK 21
# ============================================================================
echo -e "${BLUE}☕ [3/6] Instalando Java JDK 21...${NC}"
mkdir -p ~/java && cd ~/java
if [ ! -d "$HOME/java/jdk-21.0.2" ]; then
    wget -q --show-progress https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz
    tar -xf openjdk-21.0.2_linux-x64_bin.tar.gz
    rm -f openjdk-21.0.2_linux-x64_bin.tar.gz
    echo -e "${GREEN}✅ Java JDK 21 instalado!${NC}\n"
else
    echo -e "${YELLOW}⚠️  Java JDK 21 já está instalado, pulando...${NC}\n"
fi

# Adicionando variáveis do Java ao bashrc (se não existirem)
if ! grep -q "JAVA_HOME" ~/.bashrc; then
    echo -e "${CYAN}📄 Adicionando variáveis do Java ao bashrc...${NC}"
    cat <<'EOF' >> ~/.bashrc

# JAVA
export JAVA_HOME=$HOME/java/jdk-21.0.2
export PATH=$PATH:$JAVA_HOME/bin
EOF
fi

# ============================================================================
# ETAPA 4: Instalando Apache Spark 3.5.5 (com PySpark)
# ============================================================================
echo -e "${BLUE}⚡ [4/6] Instalando Apache Spark 3.5.5 (PySpark)...${NC}"
mkdir -p ~/apache && cd ~/apache
if [ ! -d "$HOME/apache/spark-3.5.5" ]; then
    wget -q --show-progress https://dlcdn.apache.org/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz
    tar -xf spark-3.5.5-bin-hadoop3.tgz
    rm -f spark-3.5.5-bin-hadoop3.tgz
    mv spark-3.5.5-bin-hadoop3 spark-3.5.5
    echo -e "${GREEN}✅ Apache Spark 3.5.5 instalado!${NC}\n"
else
    echo -e "${YELLOW}⚠️  Apache Spark já está instalado, pulando...${NC}\n"
fi

# Adicionando variáveis do Spark ao bashrc (se não existirem)
if ! grep -q "SPARK_HOME" ~/.bashrc; then
    echo -e "${CYAN}📄 Adicionando variáveis do Spark ao bashrc...${NC}"
    cat <<'EOF' >> ~/.bashrc

# SPARK
export SPARK_HOME=$HOME/apache/spark-3.5.5
export SPARK_LOCAL_IP=127.0.0.1
export HADOOP_HOME=$SPARK_HOME
export PYTHONPATH=$SPARK_HOME/python
export PATH=$PATH:$SPARK_HOME/bin
EOF
fi

# ============================================================================
# ETAPA 5: Configurando Git
# ============================================================================
echo -e "${BLUE}🔧 [5/6] Configurando Git...${NC}"
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
echo -e "${BLUE}🐍 [6/6] Criando Virtual Environment Python...${NC}"
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

# Adiciona alias para ativar a venv ao bashrc (se não existir)
if ! grep -q "alias activate=" ~/.bashrc; then
    cat <<EOF >> ~/.bashrc

# Alias para ativar venv global
alias activate="source $VENV_PATH/bin/activate"
EOF
    echo -e "${CYAN}📄 Alias 'activate' adicionado ao bashrc para ativar a venv${NC}"
fi

# ============================================================================
# ETAPA FINAL: Recarregando variáveis de ambiente
# ============================================================================
echo -e "${BLUE}🔄 Recarregando variáveis de ambiente...${NC}"
export JAVA_HOME=$HOME/java/jdk-21.0.2
export PATH=$PATH:$JAVA_HOME/bin
export SPARK_HOME=$HOME/apache/spark-3.5.5
export PATH=$PATH:$SPARK_HOME/bin
export PYTHONPATH=$SPARK_HOME/python

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           🎉 AMBIENTE WSL CONFIGURADO COM SUCESSO! 🎉                ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║                                                                      ║${NC}"
echo -e "${GREEN}║  ✅ Git configurado                                                  ║${NC}"
echo -e "${GREEN}║  ✅ Python + pip + venv                                              ║${NC}"
echo -e "${GREEN}║  ✅ Java JDK 21                                                      ║${NC}"
echo -e "${GREEN}║  ✅ Apache Spark 3.5.5 (PySpark)                                     ║${NC}"
echo -e "${GREEN}║  ✅ Docker (via Docker Desktop)                                      ║${NC}"
echo -e "${GREEN}║  ✅ Ambiente virtual em: ~/$VENV_NAME                                ${NC}"
echo -e "${GREEN}║                                                                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  Para aplicar todas as configurações, execute:${NC}"
echo -e "${BOLD}   source ~/.bashrc${NC}"
echo ""
echo -e "${CYAN}💡 Dicas:${NC}"
echo -e "   • Use ${BOLD}activate${NC} para ativar o ambiente virtual"
echo -e "   • Use ${BOLD}./check.sh${NC} para verificar se tudo está funcionando"
echo ""

