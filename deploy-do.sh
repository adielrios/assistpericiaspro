#!/bin/bash

# Cores para melhor visualização
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Implantação Automatizada no DigitalOcean  ${NC}"
echo -e "${BLUE}=================================================${NC}"

# Verificar dependências
echo -e "\n${YELLOW}Verificando dependências...${NC}"
if ! command -v doctl &> /dev/null; then
    echo -e "${RED}DigitalOcean CLI (doctl) não encontrado. Instalando...${NC}"
    brew install doctl
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}jq não encontrado. Instalando...${NC}"
    brew install jq
fi

# Verificar autenticação no DigitalOcean
echo -e "\n${YELLOW}Verificando autenticação no DigitalOcean...${NC}"
if ! doctl account get &> /dev/null; then
    echo -e "${YELLOW}Você precisa autenticar no DigitalOcean.${NC}"
    echo -e "Acesse https://cloud.digitalocean.com/account/api/tokens e crie um token pessoal."
    read -p "Cole seu token de acesso pessoal: " DO_TOKEN
    
    doctl auth init --access-token $DO_TOKEN
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha na autenticação com DigitalOcean.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Já autenticado no DigitalOcean.${NC}"
fi

# Determinar o diretório do projeto
echo -e "\n${YELLOW}Procurando pelo código do AssistPericias...${NC}"

PROJECT_DIR=""
# Verificar possíveis diretórios
if [ -d "$HOME/AssistPericias" ] && [ -f "$HOME/AssistPericias/app.py" ]; then
    PROJECT_DIR="$HOME/AssistPericias"
elif [ -d "$HOME/assistpericias-temp" ] && [ -f "$HOME/assistpericias-temp/app.py" ]; then
    PROJECT_DIR="$HOME/assistpericias-temp"
else
    echo -e "${YELLOW}Não foi possível encontrar automaticamente o diretório do projeto.${NC}"
    read -p "Por favor, informe o caminho completo para o diretório do seu projeto: " PROJECT_DIR
    
    if [ ! -d "$PROJECT_DIR" ] || [ ! -f "$PROJECT_DIR/app.py" ]; then
        echo -e "${RED}❌ Diretório inválido ou arquivo app.py não encontrado.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Projeto encontrado em: $PROJECT_DIR${NC}"

# Criar arquivo ZIP temporário
echo -e "\n${YELLOW}Criando arquivo ZIP do projeto...${NC}"
ZIP_FILE="$HOME/assistpericias_deploy.zip"

cd "$PROJECT_DIR"

# Verificar arquivos importantes
MISSING_FILES=0
for FILE in "app.py" "requirements.txt" "Procfile"; do
    if [ ! -f "$FILE" ]; then
        echo -e "${RED}❌ Arquivo importante não encontrado: $FILE${NC}"
        MISSING_FILES=1
    fi
done

if [ $MISSING_FILES -eq 1 ]; then
    echo -e "${YELLOW}Criando arquivos faltantes...${NC}"
    
    # Criar app.py se não existir
    if [ ! -f "app.py" ]; then
        echo -e "${YELLOW}Criando app.py básico...${NC}"
        cat > app.py << 'EOFAPP'
from flask import Flask, render_template, jsonify
import os
import json
import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/api/status')
def status():
    return jsonify({
        "status": "online",
        "versao": "1.0.0",
        "nome": "AssistPericias Pro",
        "time": datetime.datetime.now().isoformat()
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
EOFAPP
    fi

    # Criar requirements.txt se não existir
    if [ ! -f "requirements.txt" ]; then
        echo -e "${YELLOW}Criando requirements.txt...${NC}"
        cat > requirements.txt << 'EOFREQ'
flask==2.2.3
gunicorn==20.1.0
EOFREQ
    fi

    # Criar Procfile se não existir
    if [ ! -f "Procfile" ]; then
        echo -e "${YELLOW}Criando Procfile...${NC}"
        echo "web: gunicorn app:app" > Procfile
    fi
fi

# Criar diretórios necessários
mkdir -p templates static/css static/js

# Verificar arquivos de template
if [ ! -f "templates/index.html" ]; then
    echo -e "${YELLOW}Criando templates/index.html básico...${NC}"
    mkdir -p templates
    cat > templates/index.html << 'EOFHTML'
<!DOCTYPE html>
<html>
<head>
    <title>AssistPericias Pro</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-5">
        <div class="card">
            <div class="card-body">
                <h1>AssistPericias Pro</h1>
                <p>Sistema de Gerenciamento de Perícias Médicas</p>
                <a href="/dashboard" class="btn btn-primary">Acessar Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>
EOFHTML
fi

if [ ! -f "templates/dashboard.html" ]; then
    echo -e "${YELLOW}Criando templates/dashboard.html básico...${NC}"
    mkdir -p templates
    cat > templates/dashboard.html << 'EOFHTML2'
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - AssistPericias Pro</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-5">
        <div class="card">
            <div class="card-header">
                <h1>Dashboard</h1>
            </div>
            <div class="card-body">
                <p>Bem-vindo ao Dashboard do AssistPericias Pro.</p>
                <p>Sistema em configuração...</p>
            </div>
        </div>
    </div>
</body>
</html>
EOFHTML2
fi

# Criar o arquivo ZIP
echo -e "${YELLOW}Empacotando o projeto...${NC}"
zip -r "$ZIP_FILE" app.py requirements.txt Procfile templates/ static/ 2>/dev/null

if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}❌ Falha ao criar arquivo ZIP.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Arquivo ZIP criado: $ZIP_FILE${NC}"

# Criar o aplicativo no DigitalOcean
echo -e "\n${YELLOW}Criando aplicativo no DigitalOcean...${NC}"

# Nome do aplicativo
APP_NAME="assistpericias-adiel"

# Verificar se o aplicativo já existe
APP_ID=$(doctl apps list --format ID,Spec.Name --no-header | grep "$APP_NAME" | awk '{print $1}')

if [ -n "$APP_ID" ]; then
    echo -e "${YELLOW}Aplicativo $APP_NAME já existe (ID: $APP_ID).${NC}"
    echo -e "Deseja atualizar o aplicativo existente? (s/n)"
    read -p "> " UPDATE_APP
    
    if [[ "$UPDATE_APP" != "s" ]]; then
        echo -e "${YELLOW}Operação cancelada pelo usuário.${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}Atualizando aplicativo existente...${NC}"
    # A atualização será feita com o upload do código
else
    # Criar um novo aplicativo
    echo -e "${YELLOW}Criando novo aplicativo...${NC}"
    
    # Criar spec básico para o aplicativo
    cat > app_spec.json << EOF
{
  "name": "$APP_NAME",
  "region": "nyc",
  "services": [
    {
      "name": "web",
      "environment_slug": "python",
      "instance_size_slug": "basic-xxs",
      "instance_count": 1,
      "source_dir": "/",
      "http_port": 8080,
      "build_command": "pip install -r requirements.txt",
      "run_command": "gunicorn app:app",
      "envs": [
        {
          "key": "PORT",
          "value": "8080"
        },
        {
          "key": "FLASK_ENV",
          "value": "production"
        },
        {
          "key": "API_KEY",
          "value": "$(openssl rand -hex 16)",
          "scope": "RUN_TIME",
          "type": "SECRET"
        }
      ]
    }
  ]
}
