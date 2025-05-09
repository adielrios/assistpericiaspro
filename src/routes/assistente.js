const express = require('express');
const router = express.Router();

// Rota para processar perguntas
router.post('/pergunta', (req, res) => {
  const { pergunta } = req.body;
  
  // Em modo de desenvolvimento, retornar resposta simples
  let resposta = "Desculpe, não entendi sua pergunta. Posso ajudar com 
informações sobre perícias, laudos, processos ou agendamentos.";
  
  // Respostas simples para keywords
  if (pergunta.toLowerCase().includes("olá") || 
pergunta.toLowerCase().includes("oi")) {
    resposta = "Olá! Como posso ajudar você hoje?";
  } else if (pergunta.toLowerCase().includes("perícia") || 
pergunta.toLowerCase().includes("pericia")) {
    resposta = "As perícias são agendadas através do menu 'Perícias'. 
Posso ajudar você a navegar por lá se desejar.";
  } else if (pergunta.toLowerCase().includes("laudo")) {
    resposta = "Os laudos podem ser gerados após a realização da perícia. 
Acesse o menu 'Laudos' para criar ou visualizar laudos existentes.";
  } else if (pergunta.toLowerCase().includes("processo")) {
    resposta = "Você pode acompanhar todos os processos judiciais através 
do menu 'Processos', incluindo verificar novas movimentações.";
  } else if (pergunta.toLowerCase().includes("ajuda") || 
pergunta.toLowerCase().includes("help")) {
    resposta = "Posso ajudar com diversas tarefas: <br>- Consultar 
informações sobre perícias<br>- Verificar status de processos<br>- 
Auxiliar na geração de laudos<br>- Verificar agenda e compromissos<br>- 
Buscar documentos e modelos de relatórios";
  }
  
  // Em produção, aqui usaria um serviço de IA mais avançado
  
  return res.json({ resposta });
});

module.exports = router;
