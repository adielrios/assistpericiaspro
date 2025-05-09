#!/bin/bash

# Script de correção para o AssistPericias
echo "===== Diagnosticando e corrigindo o AssistPericias ====="

# Diretório base
BASE_DIR="$HOME/assistpericias"
cd "$BASE_DIR"

# Verificar estrutura de diretórios
echo "Verificando estrutura de diretórios..."

# Lista de diretórios necessários
directories=(
  "src"
  "src/controllers"
  "src/models"
  "src/services"
  "src/routes"
  "src/middleware"
  "src/utils"
  "src/integrations"
  "src/ai"
  "data"
  "data/tokens"
  "data/pericias"
  "data/processos"
  "data/laudos"
  "data/backups"
  "config"
  "config/db"
  "config/api"
  "config/security"
  "config/templates"
  "logs"
  "logs/system"
  "logs/access"
  "logs/errors"
  "public"
  "public/img"
  "public/css"
  "public/js"
  "public/templates"
  "docs"
)

# Criar diretórios ausentes
for dir in "${directories[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "Criando diretório ausente: $dir"
    mkdir -p "$dir"
  fi
done

# Verificar arquivo principal do servidor
echo "Verificando arquivo principal do servidor..."

if [ ! -f "src/server.js" ]; then
  echo "O arquivo src/server.js não foi encontrado. Criando..."
  
  # Criar arquivo do servidor
  cat > src/server.js << 'EOL'
require('dotenv').config();
const express = require('express');
const path = require('path');
const fs = require('fs');

// Inicializar a aplicação Express
const app = express();
const port = process.env.PORT || 3000;

// Configurar middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '..', 'public')));

// Rota principal - página de login
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));
});

// Rota dashboard
app.get('/dashboard', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'dashboard.html'));
});

// Iniciar o servidor
app.listen(port, '0.0.0.0', () => {
  console.log(`Sistema AssistPericias iniciado na porta ${port}`);
  console.log(`Acesse http://localhost:${port}`);
});
EOL
fi

# Verificar arquivo package.json
echo "Verificando package.json..."

if [ ! -f "package.json" ]; then
  echo "O arquivo package.json não foi encontrado. Criando..."
  
  # Criar package.json
  cat > package.json << 'EOL'
{
  "name": "assistpericias",
  "version": "3.0.0",
  "description": "Sistema avançado de gerenciamento de perícias médicas",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js"
  },
  "author": "Dr. Adiel Carneiro Rios",
  "license": "UNLICENSED",
  "dependencies": {
    "express": "^4.18.2",
    "dotenv": "^16.3.1"
  }
}
EOL
fi

# Instalar dependências básicas
echo "Instalando dependências básicas..."
npm install express dotenv

# Verificar arquivos HTML essenciais
echo "Verificando arquivos HTML essenciais..."

if [ ! -f "public/index.html" ]; then
  echo "O arquivo public/index.html não foi encontrado. Criando..."
  
  # Criar index.html
  cat > public/index.html << 'EOL'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AssistPericias - Login</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f5f5f5;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .login-container {
      background-color: white;
      padding: 30px;
      border-radius: 5px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      width: 90%;
      max-width: 400px;
    }
    h1 {
      text-align: center;
      color: #333;
    }
    input {
      width: 100%;
      padding: 10px;
      margin: 10px 0;
      border: 1px solid #ddd;
      border-radius: 4px;
      box-sizing: border-box;
    }
    button {
      width: 100%;
      padding: 10px;
      background-color: #4CAF50;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 16px;
    }
    button:hover {
      background-color: #45a049;
    }
    .error {
      color: red;
      text-align: center;
      margin-top: 10px;
    }
    .version {
      text-align: center;
      font-size: 12px;
      color: #999;
      margin-top: 20px;
    }
  </style>
</head>
<body>
  <div class="login-container">
    <div class="logo">
      <h1>AssistPericias</h1>
    </div>
    <form id="loginForm">
      <input type="text" id="token" placeholder="Insira seu token de 
acesso" required>
      <button type="submit">Entrar</button>
      <div id="errorMessage" class="error"></div>
    </form>
    <div class="version">Versão 3.0 - Maio 2025</div>
  </div>
  <script>
    document.getElementById('loginForm').addEventListener('submit', (e) => 
{
      e.preventDefault();
      const token = document.getElementById('token').value.trim();
      
      if (token === '12345') {
        localStorage.setItem('token', token);
        window.location.href = '/dashboard';
      } else {
        document.getElementById('errorMessage').textContent = 'Token 
inválido';
      }
    });
  </script>
</body>
</html>
EOL
fi

if [ ! -f "public/dashboard.html" ]; then
  echo "O arquivo public/dashboard.html não foi encontrado. Criando..."
  
  # Criar dashboard.html
  cat > public/dashboard.html << 'EOL'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AssistPericias - Dashboard</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f4f6f9;
    }
    .header {
      background-color: #4CAF50;
      color: white;
      padding: 15px 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .sidebar {
      width: 250px;
      background-color: #343a40;
      color: white;
      height: calc(100vh - 60px);
      position: fixed;
      padding-top: 20px;
    }
    .sidebar-menu {
      list-style: none;
      padding: 0;
    }
    .sidebar-menu li {
      padding: 10px 20px;
      border-left: 3px solid transparent;
      cursor: pointer;
    }
    .sidebar-menu li:hover, .sidebar-menu li.active {
      background-color: #2c3136;
      border-left-color: #4CAF50;
    }
    .content {
      margin-left: 250px;
      padding: 20px;
    }
    .dashboard-card {
      background-color: white;
      border-radius: 5px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      padding: 20px;
      margin-bottom: 20px;
    }
    .btn {
      padding: 8px 16px;
      background-color: #4CAF50;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .stats-container {
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      margin-bottom: 20px;
    }
    .stat-card {
      background-color: white;
      border-radius: 5px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      padding: 20px;
      flex: 1;
      margin: 0 10px;
      text-align: center;
    }
    .stat-number {
      font-size: 24px;
      font-weight: bold;
      margin: 10px 0;
    }
    
    /* Assistente Virtual */
    .assistant-container {
      position: fixed;
      bottom: 20px;
      right: 20px;
      width: 300px;
      background-color: white;
      border-radius: 5px;
      box-shadow: 0 2px 15px rgba(0,0,0,0.1);
      overflow: hidden;
      z-index: 1000;
    }
    .assistant-header {
      background-color: #4CAF50;
      color: white;
      padding: 10px 15px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
    }
    .assistant-body {
      height: 300px;
      display: none;
      flex-direction: column;
    }
    .assistant-messages {
      flex: 1;
      overflow-y: auto;
      padding: 10px;
    }
    .assistant-input {
      border-top: 1px solid #eee;
      padding: 10px;
      display: flex;
    }
    .assistant-input input {
      flex: 1;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
      margin-right: 5px;
    }
    .assistant-input button {
      background-color: #4CAF50;
      color: white;
      border: none;
      padding: 8px 12px;
      border-radius: 4px;
      cursor: pointer;
    }
    .message {
      margin-bottom: 10px;
      max-width: 80%;
    }
    .message-user {
      align-self: flex-end;
      background-color: #e7f7e7;
      padding: 8px 12px;
      border-radius: 15px 15px 0 15px;
      margin-left: auto;
    }
    .message-assistant {
      align-self: flex-start;
      background-color: #f1f1f1;
      padding: 8px 12px;
      border-radius: 15px 15px 15px 0;
    }
  </style>
</head>
<body>
  <div class="header">
    <h2>AssistPericias</h2>
    <div class="user-info">
      <span id="userName">Dr. Adiel Carneiro Rios</span>
      <button class="btn" onclick="logout()" style="margin-left: 
15px;">Sair</button>
    </div>
  </div>
  
  <div class="sidebar">
    <ul class="sidebar-menu">
      <li class="active">Dashboard</li>
      <li onclick="alert('Módulo em desenvolvimento')">Perícias</li>
      <li onclick="alert('Módulo em desenvolvimento')">Processos</li>
      <li onclick="alert('Módulo em desenvolvimento')">Monitoramento</li>
      <li onclick="alert('Módulo em desenvolvimento')">Calendário</li>
      <li onclick="alert('Módulo em desenvolvimento')">Relatórios</li>
      <li onclick="alert('Módulo em desenvolvimento')">Laudos</li>
      <li onclick="alert('Módulo em desenvolvimento')">Configurações</li>
    </ul>
  </div>
  
  <div class="content">
    <h2>Dashboard</h2>
    
    <div class="stats-container">
      <div class="stat-card">
        <h3>Perícias Pendentes</h3>
        <div class="stat-number">3</div>
      </div>
      <div class="stat-card">
        <h3>Processos Ativos</h3>
        <div class="stat-number">12</div>
      </div>
      <div class="stat-card">
        <h3>Laudos Emitidos</h3>
        <div class="stat-number">8</div>
      </div>
      <div class="stat-card">
        <h3>Alertas</h3>
        <div class="stat-number">2</div>
      </div>
    </div>
    
    <div class="dashboard-card">
      <h3 style="margin-top: 0; border-bottom: 1px solid #eee; 
padding-bottom: 10px;">Próximas Perícias</h3>
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr>
            <th style="text-align: left; padding: 8px; border-bottom: 1px 
solid #ddd;">Data</th>
            <th style="text-align: left; padding: 8px; border-bottom: 1px 
solid #ddd;">Paciente</th>
            <th style="text-align: left; padding: 8px; border-bottom: 1px 
solid #ddd;">Processo</th>
            <th style="text-align: left; padding: 8px; border-bottom: 1px 
solid #ddd;">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">10/05/2025</td>
            <td style="padding: 8px; border-bottom: 1px solid #ddd;">João 
Silva</td>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">0001234-56.2025.8.26.0100</td>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">Agendada</td>
          </tr>
          <tr>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">15/05/2025</td>
            <td style="padding: 8px; border-bottom: 1px solid #ddd;">Maria 
Oliveira</td>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">0002345-67.2025.8.26.0100</td>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">Confirmada</td>
          </tr>
          <tr>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">20/05/2025</td>
            <td style="padding: 8px; border-bottom: 1px solid #ddd;">Pedro 
Santos</td>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">0003456-78.2025.8.26.0100</td>
            <td style="padding: 8px; border-bottom: 1px solid 
#ddd;">Pendente</td>
          </tr>
        </tbody>
      </table>
      <div style="margin-top: 15px;">
        <button class="btn" onclick="alert('Módulo em 
desenvolvimento')">Ver Todas</button>
      </div>
    </div>
    
    <div class="dashboard-card">
      <h3 style="margin-top: 0; border-bottom: 1px solid #eee; 
padding-bottom: 10px;">Alertas Recentes</h3>
      <ul style="padding-left: 20px;">
        <li style="margin-bottom: 10px;">Novo processo adicionado: 
0004567-89.2025.8.26.0100</li>
        <li style="margin-bottom: 10px;">Lembrete: Prazo para envio de 
laudo expira em 5 dias</li>
      </ul>
    </div>
  </div>
  
  <!-- Assistente Virtual -->
  <div class="assistant-container" id="assistantContainer">
    <div class="assistant-header" onclick="toggleAssistant()">
      <span>Assistente Oscar</span>
      <span class="assistant-toggle" id="assistantToggle">▼</span>
    </div>
    <div class="assistant-body" id="assistantBody">
      <div class="assistant-messages" id="assistantMessages">
        <div class="message message-assistant">
          Olá, Dr. Adiel! Sou Oscar, seu assistente virtual. Como posso 
ajudar hoje?
        </div>
      </div>
      <div class="assistant-input">
        <input type="text" id="assistantInput" placeholder="Digite sua 
pergunta...">
        <button onclick="sendQuestion()">Enviar</button>
      </div>
    </div>
  </div>
  
  <script>
    // Variáveis globais
    let assistantVisible = false;
    
    document.addEventListener('DOMContentLoaded', () => {
      const token = localStorage.getItem('token');
      if (token !== '12345') {
        window.location.href = '/';
        return;
      }
      
      // Inicializar assistente
      initAssistant();
      
      // Configurar envio de mensagem com Enter
      
document.getElementById('assistantInput').addEventListener('keypress', 
function(e) {
        if (e.key === 'Enter') {
          sendQuestion();
        }
      });
    });
    
    function initAssistant() {
      // Verificar e definir visibilidade do assistente
      const shouldBeVisible = localStorage.getItem('assistantVisible') === 
'true';
      toggleAssistant(shouldBeVisible);
    }
    
    function toggleAssistant(forcedState) {
      const body = document.getElementById('assistantBody');
      const toggle = document.getElementById('assistantToggle');
      
      // Se forcedState for definido, use-o, caso contrário, alterne
      assistantVisible = (forcedState !== undefined) ? forcedState : 
!assistantVisible;
      
      if (assistantVisible) {
        body.style.display = 'flex';
        toggle.textContent = '▼';
      } else {
        body.style.display = 'none';
        toggle.textContent = '▲';
      }
      
      localStorage.setItem('assistantVisible', assistantVisible);
    }
    
    function sendQuestion() {
      const input = document.getElementById('assistantInput');
      const question = input.value.trim();
      
      if (!question) return;
      
      // Limpar input
      input.value = '';
      
      // Adicionar pergunta à conversa
      const messages = document.getElementById('assistantMessages');
      messages.innerHTML += '<div class="message message-user">' + 
question + '</div>';
      
      // Simular resposta do assistente
      setTimeout(() => {
        let response = "Desculpe, não entendi sua pergunta. Posso ajudar 
com informações sobre perícias, laudos, processos ou agendamentos.";
        
        // Respostas simples
        if (question.toLowerCase().includes("olá") || 
question.toLowerCase().includes("oi")) {
          response = "Olá! Como posso ajudar você hoje?";
        } else if (question.toLowerCase().includes("perícia") || 
question.toLowerCase().includes("pericia")) {
          response = "As perícias são agendadas através do menu 
'Perícias'. Posso ajudar você a navegar por lá se desejar.";
        } else if (question.toLowerCase().includes("laudo")) {
          response = "Os laudos podem ser gerados após a realização da 
perícia. Acesse o menu 'Laudos' para criar ou visualizar laudos 
existentes.";
        } else if (question.toLowerCase().includes("processo")) {
          response = "Você pode acompanhar todos os processos judiciais 
através do menu 'Processos', incluindo verificar novas movimentações.";
        }
        
        messages.innerHTML += '<div class="message message-assistant">' + 
response + '</div>';
        
        // Rolagem automática para o final
        messages.scrollTop = messages.scrollHeight;
      }, 500);
      
      // Rolagem automática para o final
      messages.scrollTop = messages.scrollHeight;
    }
    
    function logout() {
      localStorage.removeItem('token');
      window.location.href = '/';
    }
  </script>
</body>
</html>
EOL
fi

# Criar arquivo .env se não existir
if [ ! -f ".env" ]; then
  echo "Criando arquivo .env..."
  
  cat > .env << 'EOL'
# Configurações do ambiente
NODE_ENV=development
PORT=3000

# Dados do usuário
USER_NAME=Dr. Adiel Carneiro Rios
USER_EMAIL=adiel.rios@abp.org.br
USER_CRM=138355
USER_CPF=00688204538
EOL
fi

# Criar token personalizado
mkdir -p data/tokens
if [ ! -f "data/tokens/12345.json" ]; then
  echo "Criando token personalizado..."
  
  cat > data/tokens/12345.json << 'EOL'
{
  "token": "12345",
  "user": {
    "id": 1,
    "nome": "Dr. Adiel Carneiro Rios",
    "email": "adiel.rios@abp.org.br",
    "role": "admin",
    "crm": "138355",
    "cpf": "00688204538"
  },
  "createdAt": 1714742400000,
  "expiresAt": 4070908800000
}
EOL
fi

# Criar ou atualizar o script de inicialização
echo "Atualizando script de inicialização..."

cat > iniciar.sh << 'EOL'
#!/bin/bash

# Iniciar o sistema AssistPericias - Versão Simplificada
echo "Iniciando o sistema AssistPericias..."

# Verificar se o Node.js está instalado
if ! command -v node &> /dev/null; then
  echo "Node.js não encontrado. Por favor, instale o Node.js."
  exit 1
fi

# Mostrar o diretório atual
CURRENT_DIR=$(pwd)
echo "Diretório atual: $CURRENT_DIR"

# Listar arquivos do diretório src
echo "Listando arquivos em src:"
ls -la src/

# Verificar se o arquivo server.js existe
if [ ! -f "src/server.js" ]; then
  echo "ERRO: O arquivo src/server.js não existe!"
  exit 1
fi

# Iniciar o servidor com um caminho absoluto
echo "Iniciando servidor com caminho absoluto..."
node "$CURRENT_DIR/src/server.js"
EOL

# Tornar o script executável
chmod +x iniciar.sh

echo "===== Correção concluída! ====="
echo "Agora você pode executar: ./iniciar.sh"
echo "Se ainda houver problemas, verifique o log para mais detalhes."
