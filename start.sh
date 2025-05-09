#!/bin/bash

# Cores para visualização
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Iniciando AssistPericias Pro - Ambiente de Desenvolvimento  ${NC}"
echo -e "${BLUE}=================================================${NC}"

# Verificar se o ambiente virtual está ativado
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${YELLOW}Ambiente virtual não está ativado. Ativando...${NC}"
    source venv/bin/activate
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Falha ao ativar o ambiente virtual.${NC}"
        echo "Você pode ativá-lo manualmente com: source venv/bin/activate"
        echo "Em seguida, execute este script novamente."
        exit 1
    fi
fi

# Verificar dependências
echo -e "${YELLOW}Verificando dependências...${NC}"
pip install -r requirements.txt

# Criar diretórios necessários se não existirem
mkdir -p data/backups
mkdir -p static/images

# Verificar se existem imagens de avatar
if [ ! -s static/images/avatar.jpg ]; then
    echo -e "${YELLOW}⚠️ Imagem de avatar placeholder será usada.${NC}"
    echo "Por favor, substitua o arquivo static/images/avatar.jpg por sua imagem real."
fi

if [ ! -s static/images/user.png ]; then
    echo -e "${YELLOW}⚠️ Imagem de usuário placeholder será usada.${NC}"
    echo "Por favor, substitua o arquivo static/images/user.png por sua imagem real."
fi

# Configurar variáveis de ambiente
export FLASK_ENV=development
export FLASK_APP=app.py
export PORT=8080
export API_KEY=12345

echo -e "${GREEN}Servidor iniciando em http://localhost:8080${NC}"
echo -e "${YELLOW}Pressione Ctrl+C para encerrar o servidor${NC}"

# Iniciar o servidor Flask
python app.py
