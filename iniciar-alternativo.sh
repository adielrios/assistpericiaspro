#!/bin/bash

# Iniciar o sistema AssistPericias - Versão com porta alternativa
echo "Iniciando o sistema AssistPericias..."

# Verificar se o Node.js está instalado
if ! command -v node &> /dev/null; then
  echo "Node.js não encontrado. Por favor, instale o Node.js."
  exit 1
fi

# Mostrar o diretório atual
CURRENT_DIR=$(pwd)
echo "Diretório atual: $CURRENT_DIR"

# Verificar arquivo .env para porta personalizada
if [ -f ".env" ]; then
  PORT=$(grep "PORT=" .env | cut -d'=' -f2)
  if [ -n "$PORT" ]; then
    echo "Usando porta configurada: $PORT"
  else
    PORT=3000
    echo "Porta não configurada no .env, usando porta padrão: $PORT"
  fi
else
  PORT=3000
  echo "Arquivo .env não encontrado, usando porta padrão: $PORT"
fi

# Verificar se o arquivo server.js existe
if [ ! -f "src/server.js" ]; then
  echo "ERRO: O arquivo src/server.js não existe!"
  exit 1
fi

# Iniciar o servidor com a porta específica
echo "Iniciando servidor na porta $PORT..."
PORT=$PORT node "$CURRENT_DIR/src/server.js"
