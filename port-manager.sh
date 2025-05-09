#!/bin/bash

# Script para gerenciar a porta do AssistPericias
echo "===== Gerenciador de Porta do AssistPericias ====="

# Verificar processos usando a porta 3000
echo "Verificando processos usando a porta 3000..."

# Para macOS/Linux
if command -v lsof &> /dev/null; then
  PROCESS_INFO=$(lsof -i :3000 -n -P | grep LISTEN)
  if [ -n "$PROCESS_INFO" ]; then
    echo "Processos encontrados usando a porta 3000:"
    echo "$PROCESS_INFO"
    
    # Extrair PID
    PID=$(echo "$PROCESS_INFO" | awk '{print $2}' | head -n1)
    
    echo "O processo com PID $PID está usando a porta 3000."
    
    read -p "Deseja encerrar este processo? (s/n): " resposta
    if [ "$resposta" == "s" ] || [ "$resposta" == "S" ]; then
      echo "Encerrando processo $PID..."
      kill -9 $PID
      echo "Processo encerrado."
    else
      echo "Processo não encerrado. Vamos configurar o AssistPericias para 
usar outra porta."
      
      # Alterar a porta no .env
      PORTA_NOVA=3001
      
      # Verificar se a nova porta também está em uso
      while [ -n "$(lsof -i :$PORTA_NOVA -n -P | grep LISTEN)" ]; do
        PORTA_NOVA=$((PORTA_NOVA + 1))
      done
      
      echo "Nova porta disponível: $PORTA_NOVA"
      
      # Atualizar .env
      if [ -f ".env" ]; then
        sed -i.bak "s/PORT=3000/PORT=$PORTA_NOVA/" .env
        echo "Arquivo .env atualizado para usar a porta $PORTA_NOVA."
      else
        echo "PORT=$PORTA_NOVA" > .env
        echo "Arquivo .env criado com a porta $PORTA_NOVA."
      fi
      
      echo "O sistema AssistPericias agora usará a porta $PORTA_NOVA."
      echo "Acesse: http://localhost:$PORTA_NOVA"
    fi
  else
    echo "Nenhum processo encontrado usando a porta 3000."
    echo "Pode haver um problema temporário. Tente novamente em alguns 
segundos."
  fi
else
  echo "Comando 'lsof' não encontrado. Não foi possível verificar 
processos."
  
  # Alternativamente, podemos simplesmente mudar a porta
  PORTA_NOVA=3001
  echo "Configurando AssistPericias para usar a porta $PORTA_NOVA."
  
  # Atualizar .env
  if [ -f ".env" ]; then
    sed -i.bak "s/PORT=3000/PORT=$PORTA_NOVA/" .env
    echo "Arquivo .env atualizado para usar a porta $PORTA_NOVA."
  else
    echo "PORT=$PORTA_NOVA" > .env
    echo "Arquivo .env criado com a porta $PORTA_NOVA."
  fi
  
  echo "O sistema AssistPericias agora usará a porta $PORTA_NOVA."
  echo "Acesse: http://localhost:$PORTA_NOVA"
fi

# Criar iniciar-alternativo.sh
echo "Criando script de inicialização alternativo..."

cat > iniciar-alternativo.sh << 'EOL'
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
EOL

# Tornar o script executável
chmod +x iniciar-alternativo.sh

echo "===== Gerenciamento de Porta Concluído! ====="
echo "Use o comando './iniciar-alternativo.sh' para iniciar o sistema."
