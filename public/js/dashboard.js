document.addEventListener('DOMContentLoaded', () => {
  // Verificar autenticação
  const token = localStorage.getItem('token');
  if (!token) {
    window.location.href = '/';
    return;
  }
  
  // Configurar Socket.IO
  const socket = io();
  socket.emit('authenticate', token);
  
  socket.on('alerta', (data) => {
    // Atualizar contador de alertas
    const alertasCount = document.getElementById('alertas-count');
    alertasCount.textContent = parseInt(alertasCount.textContent) + 1;
    
    // Adicionar alerta à lista
    const alertasList = document.getElementById('alertas-list');
    const li = document.createElement('li');
    li.textContent = data.titulo;
    alertasList.prepend(li);
    
    // Mostrar notificação
    if (Notification.permission === 'granted') {
      new Notification('AssistPericias - Novo Alerta', {
        body: data.mensagem
      });
    }
  });
  
  // Carregar dados do dashboard
  carregarDadosDashboard();
  
  // Configurar menu de navegação
  const menuItems = document.querySelectorAll('.sidebar-menu li');
  menuItems.forEach(item => {
    item.addEventListener('click', () => {
      const page = item.getAttribute('data-page');
      carregarPagina(page);
    });
  });
  
  // Verificar permissão de notificações
  if (Notification.permission !== 'granted' && Notification.permission !== 
'denied') {
    Notification.requestPermission();
  }
});

// Função para carregar dados do dashboard
function carregarDadosDashboard() {
  const token = localStorage.getItem('token');
  
  // Em modo de desenvolvimento, usar dados fictícios
  if (token === '12345') {
    // Atualizar estatísticas
    document.getElementById('pericias-pendentes').textContent = '3';
    document.getElementById('processos-ativos').textContent = '12';
    document.getElementById('laudos-emitidos').textContent = '8';
    document.getElementById('alertas-count').textContent = '2';
    
    // Carregar dados das perícias
    const periciasTable = 
document.getElementById('pericias-table').querySelector('tbody');
    periciasTable.innerHTML = `
      <tr>
        <td>10/05/2025</td>
        <td>João Silva</td>
        <td>0001234-56.2025.8.26.0100</td>
        <td>Agendada</td>
      </tr>
      <tr>
        <td>15/05/2025</td>
        <td>Maria Oliveira</td>
        <td>0002345-67.2025.8.26.0100</td>
        <td>Confirmada</td>
      </tr>
      <tr>
        <td>20/05/2025</td>
        <td>Pedro Santos</td>
        <td>0003456-78.2025.8.26.0100</td>
        <td>Pendente</td>
      </tr>
    `;
    
    // Carregar alertas
    const alertasList = document.getElementById('alertas-list');
    alertasList.innerHTML = `
      <li>Novo processo adicionado: 0004567-89.2025.8.26.0100</li>
      <li>Lembrete: Prazo para envio de laudo expira em 5 dias</li>
    `;
    
    return;
  }
  
  // Em produção, carregar dados da API
  fetch('/api/dashboard/sumario', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  })
  .then(response => response.json())
  .then(data => {
    document.getElementById('pericias-pendentes').textContent = 
data.pericias_pendentes;
    document.getElementById('processos-ativos').textContent = 
data.processos_ativos;
    document.getElementById('laudos-emitidos').textContent = 
data.laudos_emitidos;
    document.getElementById('alertas-count').textContent = 
data.alertas_count;
  })
  .catch(err => {
    console.error('Erro ao carregar sumário:', err);
  });
  
  // Carregar pericias
  fetch('/api/pericias/proximas', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  })
  .then(response => response.json())
  .then(data => {
    const periciasTable = 
document.getElementById('pericias-table').querySelector('tbody');
    periciasTable.innerHTML = '';
    
    data.forEach(pericia => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${formatarData(pericia.data)}</td>
        <td>${pericia.paciente}</td>
        <td>${pericia.processo}</td>
        <td>${pericia.status}</td>
      `;
      periciasTable.appendChild(tr);
    });
  })
  .catch(err => {
    console.error('Erro ao carregar perícias:', err);
  });
  
  // Carregar alertas
  fetch('/api/alertas/recentes', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  })
  .then(response => response.json())
  .then(data => {
    const alertasList = document.getElementById('alertas-list');
    alertasList.innerHTML = '';
    
    data.forEach(alerta => {
      const li = document.createElement('li');
      li.textContent = alerta.mensagem;
      alertasList.appendChild(li);
    });
  })
  .catch(err => {
    console.error('Erro ao carregar alertas:', err);
  });
}

// Função para carregar páginas de módulos
function carregarPagina(pagina) {
  // Atualizar menu ativo
  const menuItems = document.querySelectorAll('.sidebar-menu li');
  menuItems.forEach(item => {
    if (item.getAttribute('data-page') === pagina) {
      item.classList.add('active');
    } else {
      item.classList.remove('active');
    }
  });
  
  // Esconder todas as páginas
  const pages = document.querySelectorAll('.page');
  pages.forEach(page => {
    page.classList.remove('active');
  });
  
  // Mostrar página selecionada
  const selectedPage = document.getElementById(`${pagina}-page`);
  if (selectedPage) {
    selectedPage.classList.add('active');
    
    // Se a página ainda não foi carregada, carregar conteúdo
    if (selectedPage.innerHTML === '' && pagina !== 'dashboard') {
      // Em modo de desenvolvimento, exibir mensagem
      if (localStorage.getItem('token') === '12345') {
        selectedPage.innerHTML = `
          <h2>${pagina.charAt(0).toUpperCase() + pagina.slice(1)}</h2>
          <div class="dashboard-card">
            <h3>Módulo em Desenvolvimento</h3>
            <p>Este módulo está sendo implementado e estará disponível em 
breve.</p>
          </div>
        `;
        return;
      }
      
      // Em produção, carregar conteúdo da API
      fetch(`/api/${pagina}/conteudo`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      })
      .then(response => response.json())
      .then(data => {
        selectedPage.innerHTML = data.html;
        
        // Executar scripts da página, se houver
        if (data.script) {
          const script = document.createElement('script');
          script.textContent = data.script;
          document.body.appendChild(script);
        }
      })
      .catch(err => {
        console.error(`Erro ao carregar conteúdo de ${pagina}:`, err);
        selectedPage.innerHTML = `
          <h2>${pagina.charAt(0).toUpperCase() + pagina.slice(1)}</h2>
          <div class="dashboard-card">
            <h3>Erro ao Carregar Módulo</h3>
            <p>Não foi possível carregar o conteúdo deste módulo. Tente 
novamente mais tarde.</p>
          </div>
        `;
      });
    }
  }
}

// Função para formatar data
function formatarData(data) {
  const d = new Date(data);
  return d.toLocaleDateString('pt-BR');
}

// Função para logout
function logout() {
  localStorage.removeItem('token');
  window.location.href = '/';
}
