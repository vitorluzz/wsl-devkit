# ⚙️ wsl-for-data

Um script completo para configurar rapidamente um ambiente de desenvolvimento no **WSL 2 (Windows Subsystem for Linux)** com foco em **Data Engineering** e **Data Science**.

---

## 🚀 O que será instalado?

| Ferramenta | Descrição |
|------------|-----------|
| **Git** | Controle de versão com configuração de usuário |
| **Python 3** | Linguagem de programação + pip + venv |
| **Java JDK 21** | Runtime para Apache Spark |
| **Apache Spark 3.5.5** | Framework de processamento distribuído (PySpark) |
| **Docker** | Containerização (via Docker Desktop no Windows) |
| **Virtual Environment** | Ambiente virtual Python global configurável |

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter:

### 1. Docker Desktop no Windows (OBRIGATÓRIO)

> ⚠️ **IMPORTANTE**: O Docker Desktop deve estar instalado **ANTES** de executar o setup!

1. Baixe e instale o [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Abra o Docker Desktop
3. Vá em **Settings** > **Resources** > **WSL Integration**
4. Habilite a integração com sua distribuição Ubuntu
5. Clique em **Apply & Restart**

### 2. WSL 2 com Ubuntu

O script foi desenvolvido para **Ubuntu** no WSL 2.

### 3. VS Code com Extensão WSL (OBRIGATÓRIO)

Para desenvolver dentro do ambiente WSL usando o VS Code, você **precisa** instalar a extensão WSL:

1. Abra o **VS Code** no Windows
2. Vá em **Extensions** (Ctrl+Shift+X)
3. Pesquise por **"WSL"** ou **"Remote - WSL"**
4. Instale a extensão da **Microsoft**
5. Após instalada, você poderá abrir pastas do WSL diretamente no VS Code

> 💡 **Dica**: Dentro do terminal Ubuntu, use `code .` para abrir a pasta atual no VS Code!

---

## 🐧 Instalação Passo a Passo

### Passo 1: Instalar WSL 2 e Ubuntu

Abra o **PowerShell como Administrador** e execute:

```powershell
# Instalar WSL com Ubuntu (padrão)
wsl --install

# Ou especificamente o Ubuntu
wsl --install -d Ubuntu
```

Reinicie o computador se solicitado.

### Passo 2: Acessar o Ubuntu

```powershell
wsl -d Ubuntu
```

Crie seu usuário e senha quando solicitado.

### Passo 3: Clonar e Executar o Setup

Dentro do terminal Ubuntu, execute:

```bash
# Atualizar pacotes básicos e instalar git
sudo apt update && sudo apt install -y git

# Clonar o repositório no diretório home
cd ~
git clone https://github.com/vitorluzz/wsl-for-data.git

# Acessar a pasta do projeto
cd wsl-for-data

# Dar permissão de execução
chmod +x setup.sh check.sh

# Executar o setup
./setup.sh
```

### Passo 4: Aplicar as Configurações

Após o setup, execute:

```bash
source ~/.bashrc
```

### Passo 5: Instalar Extensão WSL no VS Code

Para desenvolver dentro do ambiente WSL usando o VS Code:

1. Abra o **VS Code** no Windows
2. Vá em **Extensions** (Ctrl+Shift+X)
3. Pesquise por **"WSL"**
4. Instale a extensão **WSL** da Microsoft

![WSL Extension](https://code.visualstudio.com/assets/docs/remote/wsl/remote-wsl-extension.png)

Após instalada, você pode abrir o VS Code diretamente do terminal Ubuntu:

```bash
# Dentro do WSL, na pasta do seu projeto
code .
```

> 💡 **Dica**: O VS Code irá detectar automaticamente que você está no WSL e usar a extensão!

---

## 🔍 Verificando a Instalação

Para verificar se tudo foi instalado corretamente, execute:

```bash
./check.sh
```

O script irá:
- ✅ Verificar todas as ferramentas instaladas
- ✅ Mostrar as versões de cada componente
- ✅ Identificar problemas de configuração
- ✅ Oferecer executar o `setup.sh` automaticamente se algo estiver faltando

---

## 🐍 Ambiente Virtual Python

Durante o setup, você poderá configurar o nome do seu ambiente virtual:

```
📝 Nome da venv [pressione ENTER para '.venv' ou digite outro]: 
```

- Pressione **ENTER** para usar o padrão (`.venv`)
- Ou digite um nome personalizado (ex: `data`, `dev`)

O ambiente será criado em `~/.venv` (ou `~/.nome_escolhido`).

### Ativando o Ambiente Virtual

Após o setup, use o alias configurado:

```bash
activate
```

Ou manualmente:

```bash
source ~/.venv/bin/activate
```

---

## 📁 Estrutura Final do Ambiente

```
~/
├── java/
│   └── jdk-21.0.2/          # Java JDK
├── apache/
│   └── spark-3.5.5/         # Apache Spark
├── .venv/                   # Ambiente virtual Python (ou nome personalizado)
└── wsl-for-data/            # Este repositório
    ├── setup.sh             # Script de instalação
    ├── check.sh             # Script de verificação
    └── README.md            # Documentação
```

---

## 🔧 Variáveis de Ambiente Configuradas

O setup adiciona automaticamente ao `~/.bashrc`:

```bash
# JAVA
export JAVA_HOME=$HOME/java/jdk-21.0.2
export PATH=$PATH:$JAVA_HOME/bin

# SPARK
export SPARK_HOME=$HOME/apache/spark-3.5.5
export SPARK_LOCAL_IP=127.0.0.1
export HADOOP_HOME=$SPARK_HOME
export PYTHONPATH=$SPARK_HOME/python
export PATH=$PATH:$SPARK_HOME/bin

# Alias para ativar venv
alias activate="source ~/.venv/bin/activate"
```

---

## 💡 Comandos Úteis

| Comando | Descrição |
|---------|-----------|
| `activate` | Ativa o ambiente virtual Python |
| `java -version` | Verifica versão do Java |
| `spark-submit --version` | Verifica versão do Spark |
| `docker --version` | Verifica versão do Docker |
| `python --version` | Verifica versão do Python |
| `./check.sh` | Verifica todo o ambiente |

---

## ❓ Troubleshooting

### Docker não encontrado

```
⚠️ DOCKER DESKTOP NÃO ENCONTRADO
```

**Solução**: Instale o Docker Desktop no Windows e habilite a integração WSL.

### Variáveis de ambiente não funcionam

**Solução**: Execute `source ~/.bashrc` ou reinicie o terminal.

### Permissão negada ao executar scripts

**Solução**: 
```bash
chmod +x setup.sh check.sh
```

---

## 📝 Licença

Este projeto está sob a licença MIT. Sinta-se livre para usar e modificar!
