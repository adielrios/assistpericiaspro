// Variáveis globais
let assistantVisible = false;

document.addEventListener('DOMContentLoaded', () => {
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
  messages.innerHTML += `<div class="message 
message-user">${question}</div>`;
  
  // Em modo de desenvolvimento, simular resposta
  if (localStorage.getItem('token') === '12345') {
    setTimeout(() => {
      let response = "Desculpe, não entendi sua pergunta. Posso ajudar com 
informações sobre perícias, laudos, processos ou agendamentos.";
      
      // Respostas simples para keywords
      if (question.toLowerCase().includes("olá") || 
question.toLowerCase().includes("oi")) {
        response = "Olá! Como posso ajudar você hoje?";
      } else if (question.toLowerCase().includes("perícia") || 
question.toLowerCase().includes("pericia")) {
        response = "As perícias são agendadas através do menu 'Perícias'. 
Posso ajudar você a navegar por lá se desejar.";
      } else if (question.toLowerCase().includes("laudo")) {
        response = "Os laudos podem ser gerados após a realização da 
perícia. Acesse o menu 'Laudos' para criar ou visualizar laudos 
existentes.";
      } else if (question.toLowerCase().includes("processo")) {
        response = "Você pode acompanhar todos os processos judiciais 
através do menu 'Processos', incluindo verificar novas movimentações.";
      } else if (question.toLowerCase().includes("ajuda") || 
question.toLowerCase().includes("help")) {
        response = "Posso ajudar com diversas tarefas: <br>- Consultar 
informações sobre perícias<br>- Verificar status de processos<br>- 
Auxiliar na geração de laudos<br>- Verificar agenda e compromissos<br>- 
Buscar documentos e modelos de relatórios";
      }
      
      messages.innerHTML += `<div class="message 
message-assistant">${response}</div>`;
      
      // Rolagem automática para o final
      messages.scrollTop = messages.scrollHeight;
    }, 500);
    
    // Rolagem automática para o final
    messages.scrollTop = messages.scrollHeight;
    return;
  }
  
  // Em produção, enviar para API
  fetch('/api/assistente/pergunta', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem('token')}`
    },
    body: JSON.stringify({ pergunta: question })
  })
  .then(response => response.json())
  .then(data => {
    messages.innerHTML += `<div class="message 
message-assistant">${data.resposta}</div>`;
    
    // Rolagem automática para o final
    messages.scrollTop = messages.scrollHeight;
  })
  .catch(err => {
    console.error('Erro ao enviar pergunta:', err);
    messages.innerHTML += `<div class="message 
message-assistant">Desculpe, ocorreu um erro ao processar sua pergunta. 
Tente novamente mais tarde.</div>`;
    
    // Rolagem automática para o final
    messages.scrollTop = messages.scrollHeight;
  });
}
