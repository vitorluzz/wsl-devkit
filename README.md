# 🧰 wsl-devkit

Um kit de scripts para montar rapidamente um **ambiente de desenvolvimento completo no WSL 2 (Ubuntu)** — pensado para quem trabalha com **dados, IA/ML e desenvolvimento em geral**.

Com um único comando (`./main.sh`) você instala e pré-configura **Git, Python, Java, Apache Spark (PySpark), Docker** e um **ambiente virtual Python**, tudo pronto para usar.

---

## ⚡ Início rápido

> **Pré-requisito:** ter o **Docker Desktop** instalado no Windows com a integração WSL ativa (detalhes na seção **Pré-requisitos**, abaixo).

```bash
# 1. Instalar o WSL 2 + Ubuntu (PowerShell como Administrador — apenas na 1ª vez)
wsl --install -d Ubuntu

# 2. Já dentro do Ubuntu, instalar o git e clonar o projeto
sudo apt update && sudo apt install -y git
git clone https://github.com/vitorluzz/wsl-devkit.git
cd wsl-devkit

# 3. Rodar o instalador (abre um menu interativo)
chmod +x main.sh
./main.sh

# 4. Recarregar o shell e ativar o ambiente virtual
source ~/.bashrc
activate
```

Prefere ir direto ao ponto? Use `./main.sh setup` para instalar sem menu e `./main.sh check` para verificar o ambiente.

---

## 🚀 O que será instalado?

| Ferramenta | Descrição |
|------------|-----------|
| **Git** | Controle de versão com configuração de usuário |
| **Python 3** | Linguagem de programação + pip + venv |
| **Java JDK 21 (Temurin LTS)** | Runtime para Apache Spark |
| **Apache Spark 4.0.4** | Framework de processamento distribuído (PySpark) — versão configurável |
| **Docker + Docker Compose** | Containerização (via Docker Desktop no Windows) |
| **Virtual Environment** | Ambiente virtual Python global configurável |
| **Diretório `~/projects`** | Pasta criada na home para organizar seus repositórios |

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter:

### 1. Docker Desktop no Windows (OBRIGATÓRIO)

> ⚠️ **IMPORTANTE**: O Docker Desktop deve estar instalado **ANTES** de executar o setup!

O **Docker** e o **Docker Compose** dentro do WSL são fornecidos pela integração do Docker Desktop — não é preciso instalá-los manualmente no Ubuntu. Sem o Docker Desktop, o `docker` não funcionará no WSL. O `setup.sh` verifica isso e, se não encontrar, interrompe com instruções.

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
git clone https://github.com/vitorluzz/wsl-devkit.git

# Acessar a pasta do projeto
cd wsl-devkit

# Dar permissão de execução ao script principal
chmod +x main.sh

# Executar o setup (ou apenas './main.sh' para abrir o menu interativo)
./main.sh setup
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

## 🚦 Como usar o `main.sh`

O `main.sh`, na raiz do projeto, é o **ponto de entrada único**. Ele localiza e executa os scripts da pasta `scripts/` automaticamente (e já ajusta as permissões deles).

| Comando | O que faz |
|---------|-----------|
| `./main.sh` | Abre o **menu interativo** (escolher entre instalar ou verificar) |
| `./main.sh setup` | Instala e configura todo o ambiente |
| `./main.sh check` | Verifica o que está instalado e aponta o que falta |
| `./main.sh help` | Mostra a ajuda com os comandos disponíveis |

> 💡 As variáveis de versão funcionam junto com o comando, ex.: `SPARK_VERSION=4.2.0 ./main.sh setup` (veja a seção **Configurando as versões**).

### 👣 Primeiros passos depois do setup

```bash
# 1. Aplicar as variáveis de ambiente na sessão atual
source ~/.bashrc

# 2. Ativar o ambiente virtual Python
activate

# 3. (Opcional) Testar o PySpark rapidamente
python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('local[*]').getOrCreate(); spark.range(5).show(); spark.stop()"
```

Se o último comando imprimir uma tabela de 0 a 4, seu Spark + PySpark estão funcionando. 🎉

---

## 🔍 Verificando a Instalação

Para verificar se tudo foi instalado corretamente, execute:

```bash
./main.sh check
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
│   └── jdk-21/              # Java JDK (Temurin LTS)
├── apache/
│   └── spark-4.0.4/         # Apache Spark
├── .venv/                   # Ambiente virtual Python (ou nome personalizado)
├── projects/                # Pasta para seus projetos/repositórios
└── wsl-devkit/              # Este repositório
    ├── main.sh              # Ponto de entrada (chama os scripts abaixo)
    ├── scripts/             # Scripts de automação
    │   ├── setup.sh         # Script de instalação
    │   └── check.sh         # Script de verificação
    └── README.md            # Documentação
```

---

## 🔧 Variáveis de Ambiente Configuradas

O setup adiciona automaticamente ao `~/.bashrc` (dentro de um bloco gerenciado, delimitado pelos marcadores `# >>> wsl-devkit >>>` … `# <<< wsl-devkit <<<`, reescrito a cada execução):

```bash
# JAVA (Temurin JDK 21)
export JAVA_HOME="$HOME/java/jdk-21"
export PATH="$JAVA_HOME/bin:$PATH"

# SPARK 4.0.4 (PySpark)
export SPARK_HOME="$HOME/apache/spark-4.0.4"
export SPARK_LOCAL_IP=127.0.0.1
export HADOOP_HOME="$SPARK_HOME"
export PATH="$SPARK_HOME/bin:$PATH"
export PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-<versão>-src.zip:$PYTHONPATH"
export PYSPARK_PYTHON=python3

# Alias para ativar venv
alias activate="source ~/.venv/bin/activate"
```

> 💡 O `PYTHONPATH` inclui o `py4j` que acompanha o Spark, garantindo que `import pyspark` funcione dentro do ambiente virtual.

---

## 🎛️ Configurando as versões

As versões do **Spark** e do **JDK** ficam em variáveis no topo do `setup.sh` e podem ser sobrescritas na hora de executar, sem editar o script:

```bash
# Instala a última versão do Spark 4.x
SPARK_VERSION=4.2.0 ./main.sh setup

# Ou mantém a linha LTS 3.5 (máxima compatibilidade com o ecossistema)
SPARK_VERSION=3.5.9 ./main.sh setup

# Também é possível trocar a versão (feature) do JDK
JDK_FEATURE=21 SPARK_VERSION=4.0.4 ./main.sh setup
```

> ℹ️ O download do Spark tenta primeiro o mirror oficial (`dlcdn.apache.org`) e, se a versão já tiver sido arquivada, cai automaticamente para o `archive.apache.org`. O JDK é sempre a última atualização **GA** do Temurin para a versão escolhida (via API do Adoptium), evitando URLs fixas e desatualizadas.
>
> ⚠️ O Spark 4.x roda em **Java 17 ou 21** — mantenha `JDK_FEATURE=21` (LTS) ao usar o Spark 4.

| Comando | Descrição |
|---------|-----------|
| `activate` | Ativa o ambiente virtual Python |
| `java -version` | Verifica versão do Java |
| `spark-submit --version` | Verifica versão do Spark |
| `docker --version` | Verifica versão do Docker |
| `docker compose version` | Verifica versão do Docker Compose |
| `python --version` | Verifica versão do Python |
| `./main.sh check` | Verifica todo o ambiente |

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
chmod +x main.sh
```

### DNS / rede não funciona após o setup

A fixação de DNS (`8.8.8.8` + `chattr +i`) agora é **opcional** e desativada por padrão, pois pode quebrar a conexão em redes com VPN ou proxy corporativo. Se você a ativou e passou a ter problemas de rede, reverta com:

```bash
sudo chattr -i /etc/resolv.conf
sudo rm -f /etc/resolv.conf
```

Depois reinicie o WSL no PowerShell: `wsl --shutdown`.

---

## 📝 Licença

Este projeto está sob a licença MIT. Sinta-se livre para usar e modificar!
