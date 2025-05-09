#!/bin/bash

# Cores para melhorar a visualização
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Implantação Automatizada no Digital Ocean  ${NC}"
echo -e "${BLUE}=================================================${NC}"

# Verificar se o Digital Ocean CLI está instalado
if ! command -v doctl &> /dev/null; then
    echo -e "${RED}❌ Digital Ocean CLI (doctl) não encontrado.${NC}"
    echo "Para instalar no macOS:"
    echo "  brew install doctl"
    echo ""
    echo "Para outras opções de instalação, visite:"
    echo "  https://github.com/digitalocean/doctl#installing-doctl"
    
    read -p "Deseja continuar sem o doctl? (Configuração manual será necessária) (s/n): " CONTINUE_WITHOUT_DOCTL
    
    if [[ "$CONTINUE_WITHOUT_DOCTL" != "s" ]]; then
        exit 1
    fi
    
    # Flag para indicar que devemos dar instruções manuais
    MANUAL_INSTRUCTIONS=1
fi

# Verificar se Git está instalado
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git não encontrado. Por favor, instale o Git.${NC}"
    exit 1
fi

# Verificar se tem alterações não commitadas
if ! git diff --quiet || git status --porcelain | grep -q "??"; then
    echo -e "${YELLOW}⚠️ Existem alterações não commitadas.${NC}"
    read -p "Deseja fazer commit dessas alterações antes de continuar? (s/n): " COMMIT_CHANGES
    
    if [[ "$COMMIT_CHANGES" == "s" ]]; then
        git add .
        read -p "Mensagem de commit: " COMMIT_MSG
        COMMIT_MSG=${COMMIT_MSG:-"Atualização para deploy"}
        git commit -m "$COMMIT_MSG"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Falha ao fazer commit. Verifique suas configurações do Git.${NC}"
            exit 1
        fi
    fi
fi

# Criar o app.yaml para configuração do Digital Ocean App Platform
cat > app.yaml << 'EOF'
name: assistpericias
region: nyc
services:
- name: web
  environment_slug: python
  github:
    branch: main
    deploy_on_push: true
    repo: seu-usuario/assistpericias
  build_command: pip install -r requirements.txt
  run_command: gunicorn app:app
  source_dir: /
  envs:
  - key: PORT
    value: "8080"
  - key: FLASK_ENV
    value: "production"
  - key: API_KEY
    scope: RUN_TIME
    type: SECRET
    value: "12345"
  http_port: 8080
  instance_count: 1
  instance_size_slug: basic-xxs
  routes:
  - path: /
