#!/bin/bash

# Verificar se a porta está em uso
PORT=${1:-3000}
echo "Verificando se a porta $PORT está em uso..."

if command -v lsof &> /dev/null; then
  PORTA_EM_USO=$(lsof -i :$PORT -n -P | grep LISTEN)
  
  if [ -n "$PORTA_EM_USO" ]; then
    echo "Porta $PORT está em uso:"
    echo "$PORTA_EM_USO"
    
    read -p "Deseja encerrar o processo? [s/n]: " RESPOSTA
    if [[ $RESPOSTA =~ ^[Ss]$ ]]; then
      PID=$(echo "$PORTA_EM_USO" | awk '{print $2}' | head -n1)
      echo "Encerrando processo $PID..."
      kill -9 $PID
      sleep 2
      
      # Verificar novamente
      if lsof -i :$PORT -n -P | grep LISTEN &> /dev/null; then
        echo "Não foi possível liberar a porta $PORT."
        exit 1
      else
        echo "Porta $PORT liberada com sucesso."
      fi
    else
      echo "Operação cancelada."
      exit 1
    fi
  else
    echo "Porta $PORT está disponível."
  fi
else
  echo "Comando 'lsof' não encontrado. Não é possível verificar a porta."
  echo "Assumindo que a porta $PORT está disponível."
fi

exit 0
