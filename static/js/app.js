// Arquivo principal de JavaScript para funcionalidades comuns

// Função para mostrar notificações
function showNotification(message, type = 'info') {
    // Verificar se o contêiner de notificações existe
    let notificationsContainer = document.getElementById('notificationsContainer');
    
    if (!notificationsContainer) {
        // Criar contêiner se não existir
        notificationsContainer = document.createElement('div');
        notificationsContainer.id = 'notificationsContainer';
        notificationsContainer.style.position = 'fixed';
        notificationsContainer.style.top = '20px';
        notificationsContainer.style.right = '20px';
        notificationsContainer.style.zIndex = '9999';
        document.body.appendChild(notificationsContainer);
    }
    
    // Criar notificação
    const notification = document.createElement('div');
    notification.className = `alert alert-${type} alert-dismissible fade show`;
    notification.role = 'alert';
    notification.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Fechar"></button>
    `;
    
    // Adicionar ao contêiner
    notificationsContainer.appendChild(notification);
    
    // Remover automaticamente após 5 segundos
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notificationsContainer.removeChild(notification);
        }, 150);
    }, 5000);
}

// Função para formatar data
function formatDate(dateString) {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR');
}

// Função para formatar moeda
function formatCurrency(value) {
    if (value === null || value === undefined) return 'R$ 0,00';
    
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
    }).format(value);
}

// Configuração do botão de configurações
document.addEventListener('DOMContentLoaded', function() {
    const btnConfig = document.getElementById('btnConfig');
    
    if (btnConfig) {
        btnConfig.addEventListener('click', function() {
            showNotification('Configurações em breve!', 'primary');
        });
    }
});

// Função para verificar status do servidor
async function checkServerStatus() {
    try {
        const response = await fetch('/api/status');
        const data = await response.json();
        
        if (data.status === 'online') {
            console.log('Servidor online:', data.version);
        } else {
            console.warn('Servidor com status desconhecido:', data.status);
        }
    } catch (error) {
        console.error('Erro ao verificar status do servidor:', error);
    }
}

// Verificar status do servidor ao carregar
checkServerStatus();
