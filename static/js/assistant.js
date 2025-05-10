// Assistente Virtual

document.addEventListener('DOMContentLoaded', function() {
    // Elementos do DOM
    const assistantMessages = document.getElementById('assistantMessages');
    const assistantInput = document.getElementById('assistantInput');
    const assistantSend = document.getElementById('assistantSend');
    
    // Evento para enviar mensagem ao pressionar Enter
    assistantInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            enviarMensagem();
        }
    });
    
    // Evento para enviar mensagem ao clicar no botão
    assistantSend.addEventListener('click', enviarMensagem);
    
    // Função para enviar mensagem
    function enviarMensagem() {
        const mensagem = assistantInput.value.trim();
        
        if (!mensagem) return;
        
        // Adicionar mensagem do usuário
        adicionarMensagem(mensagem, 'user');
        
        // Limpar input
        assistantInput.value = '';
        
        // Simular resposta do assistente (em uma aplicação real, seria uma chamada à API)
        setTimeout(() => {
            const respostas = [
                "Olá Dr. Adiel! Estou aqui para ajudar com suas perícias médicas.",
                "Você tem 3 perícias pendentes para esta semana.",
                "O prazo do processo 1234-56.2025 está próximo do vencimento.",
                "Posso ajudar a preparar seus relatórios periciais.",
                "Entendi! Vou verificar essa informação para você.",
                "Seus honorários deste mês somam R$ 5.200,00."
            ];
            
            // Selecionar uma resposta aleatória
            const resposta = respostas[Math.floor(Math.random() * respostas.length)];
            
            // Adicionar resposta do assistente
            adicionarMensagem(resposta, 'assistant');
        }, 1000);
    }
    
    // Função para adicionar mensagem à conversa
    function adicionarMensagem(texto, tipo) {
        // Criar elemento de mensagem
        const mensagemElement = document.createElement('div');
        mensagemElement.className = `message ${tipo}`;
        
        // Criar avatar
        const avatarElement = document.createElement('div');
        avatarElement.className = 'avatar';
        
        const avatarImg = document.createElement('img');
        avatarImg.src = tipo === 'assistant' ? '/static/images/avatar.jpg' : '/static/images/user.png';
        avatarImg.alt = tipo === 'assistant' ? 'Assistente' : 'Você';
        
        avatarElement.appendChild(avatarImg);
        
        // Criar conteúdo
        const contentElement = document.createElement('div');
        contentElement.className = 'content';
        
        const paragraphElement = document.createElement('p');
        paragraphElement.textContent = texto;
        
        contentElement.appendChild(paragraphElement);
        
        // Montar mensagem
        mensagemElement.appendChild(avatarElement);
        mensagemElement.appendChild(contentElement);
        
        // Adicionar à conversa
        assistantMessages.appendChild(mensagemElement);
        
        // Rolar para o final
        assistantMessages.scrollTop = assistantMessages.scrollHeight;
    }
});
