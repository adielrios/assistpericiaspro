// Dashboard de Perícias

document.addEventListener('DOMContentLoaded', function() {
    // Inicializar seletores de data
    flatpickr(".datepicker", {
        locale: "pt",
        dateFormat: "d/m/Y",
        allowInput: true
    });
    
    // Elementos do DOM
    const tabelaPericias = document.getElementById('tabelaPericias');
    const btnNovaPericia = document.getElementById('btnNovaPericia');
    const btnSalvarPericia = document.getElementById('btnSalvarPericia');
    const modalPericia = new bootstrap.Modal(document.getElementById('modalPericia'));
    const modalConfirmacao = new bootstrap.Modal(document.getElementById('modalConfirmacao'));
    const btnConfirmarAcao = document.getElementById('btnConfirmarAcao');
    const searchPericia = document.getElementById('searchPericia');
    const btnBackup = document.getElementById('btnBackup');
    
    // Contadores no dashboard
    const totalPericias = document.getElementById('totalPericias');
    const totalPendentes = document.getElementById('totalPendentes');
    const totalConcluidas = document.getElementById('totalConcluidas');
    
    // Estado atual
    let pericias = [];
    let periciaAtual = null;
    let filtroAtual = 'all';
    let acaoConfirmacao = null;
    
    // Carregar as perícias
    carregarPericias();
    
    // Event listeners
    btnNovaPericia.addEventListener('click', abrirModalNovaPericia);
    btnSalvarPericia.addEventListener('click', salvarPericia);
    searchPericia.addEventListener('input', filtrarPericias);
    btnBackup.addEventListener('click', realizarBackup);
    
    // Adicionar event listeners para os filtros
    document.querySelectorAll('[data-filter]').forEach(el => {
        el.addEventListener('click', (e) => {
            e.preventDefault();
            filtroAtual = e.target.dataset.filter;
            filtrarPericias();
        });
    });
    
    // Função para carregar todas as perícias
    async function carregarPericias() {
        try {
            const response = await fetch('/api/pericias');
            
            if (!response.ok) {
                throw new Error('Erro ao carregar perícias');
            }
            
            pericias = await response.json();
            
            // Atualizar contadores
            atualizarContadores();
            
            // Mostrar perícias na tabela
            renderizarPericias();
        } catch (error) {
            console.error('Erro:', error);
            showNotification('Erro ao carregar perícias: ' + error.message, 'danger');
        }
    }
    
    // Função para atualizar contadores
    function atualizarContadores() {
        if (!pericias) return;
        
        totalPericias.textContent = pericias.length;
        totalPendentes.textContent = pericias.filter(p => p.status === 'pendente' || p.status === 'em_andamento').length;
        totalConcluidas.textContent = pericias.filter(p => p.status === 'concluida').length;
    }
    
    // Função para renderizar perícias na tabela
    function renderizarPericias() {
        if (!pericias || !tabelaPericias) return;
        
        // Aplicar filtro atual
        let periciasFiltradas = pericias;
        
        // Aplicar filtro de busca
        const termoBusca = searchPericia.value.toLowerCase();
        if (termoBusca) {
            periciasFiltradas = periciasFiltradas.filter(p => 
                (p.numeroProcesso && p.numeroProcesso.toLowerCase().includes(termoBusca)) ||
                (p.vara && p.vara.toLowerCase().includes(termoBusca)) ||
                (p.requerente && p.requerente.toLowerCase().includes(termoBusca)) ||
                (p.requerido && p.requerido.toLowerCase().includes(termoBusca))
            );
        }
        
        // Aplicar filtro de status
        if (filtroAtual === 'pendente') {
            periciasFiltradas = periciasFiltradas.filter(p => p.status === 'pendente' || p.status === 'em_andamento');
        } else if (filtroAtual === 'concluida') {
            periciasFiltradas = periciasFiltradas.filter(p => p.status === 'concluida');
        }
        
        // Aplicar ordenação
        if (filtroAtual === 'newest') {
            periciasFiltradas.sort((a, b) => new Date(b.dataNomeacao) - new Date(a.dataNomeacao));
        } else if (filtroAtual === 'oldest') {
            periciasFiltradas.sort((a, b) => new Date(a.dataNomeacao) - new Date(b.dataNomeacao));
        }
        
        if (periciasFiltradas.length === 0) {
            tabelaPericias.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center">
                        <p class="my-3">Nenhuma perícia encontrada.</p>
                    </td>
                </tr>
            `;
            return;
        }
        
        // Criar linhas da tabela
        tabelaPericias.innerHTML = periciasFiltradas.map(pericia => {
            // Determinar classe de status
            let statusClass = '';
            let statusText = '';
            
            switch(pericia.status) {
                case 'pendente':
                    statusClass = 'warning';
                    statusText = 'Pendente';
                    break;
                case 'em_andamento':
                    statusClass = 'info';
                    statusText = 'Em andamento';
                    break;
                case 'concluida':
                    statusClass = 'success';
                    statusText = 'Concluída';
                    break;
                case 'cancelada':
                    statusClass = 'secondary';
                    statusText = 'Cancelada';
                    break;
                default:
                    statusClass = 'secondary';
                    statusText = pericia.status || 'Desconhecido';
            }
            
            return `
                <tr>
                    <td>${pericia.numeroProcesso || ''}</td>
                    <td>${pericia.vara || ''}</td>
                    <td>${formatDate(pericia.dataNomeacao)}</td>
                    <td>${formatDate(pericia.prazo)}</td>
                    <td><span class="badge bg-${statusClass}">${statusText}</span></td>
                    <td>
                        <button class="btn btn-sm btn-primary btn-editar" data-id="${pericia.id}">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-danger btn-excluir" data-id="${pericia.id}">
                            <i class="bi bi-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
        }).join('');
        
        // Adicionar event listeners para botões de edição e exclusão
        document.querySelectorAll('.btn-editar').forEach(btn => {
            btn.addEventListener('click', () => {
                const id = parseInt(btn.dataset.id);
                const pericia = pericias.find(p => p.id === id);
                if (pericia) {
                    abrirModalEditarPericia(pericia);
                }
            });
        });
        
        document.querySelectorAll('.btn-excluir').forEach(btn => {
            btn.addEventListener('click', () => {
                const id = parseInt(btn.dataset.id);
                const pericia = pericias.find(p => p.id === id);
                if (pericia) {
                    confirmarExclusao(pericia);
                }
            });
        });
    }
    
    // Função para abrir modal de nova perícia
    function abrirModalNovaPericia() {
        periciaAtual = null;
        
        // Limpar formulário
        document.getElementById('formPericia').reset();
        document.getElementById('periciaId').value = '';
        document.getElementById('modalPericiaTitle').textContent = 'Nova Perícia';
        
        // Definir data atual
        const hoje = new Date();
        const dataFormatada = `${hoje.getDate().toString().padStart(2, '0')}/${(hoje.getMonth() + 1).toString().padStart(2, '0')}/${hoje.getFullYear()}`;
        document.getElementById('dataNomeacao').value = dataFormatada;
        
        // Abrir modal
        modalPericia.show();
    }
    
    // Função para abrir modal de edição de perícia
    function abrirModalEditarPericia(pericia) {
        periciaAtual = pericia;
        
        // Preencher formulário
        document.getElementById('periciaId').value = pericia.id;
        document.getElementById('numeroProcesso').value = pericia.numeroProcesso || '';
        document.getElementById('vara').value = pericia.vara || '';
        document.getElementById('requerente').value = pericia.requerente || '';
        document.getElementById('requerido').value = pericia.requerido || '';
        document.getElementById('status').value = pericia.status || 'pendente';
        document.getElementById('honorarios').value = pericia.honorarios || '';
        document.getElementById('observacoes').value = pericia.observacoes || '';
        
        // Formatar datas
        if (pericia.dataNomeacao) {
            const dataNomeacao = new Date(pericia.dataNomeacao);
            document.getElementById('dataNomeacao').value = `${dataNomeacao.getDate().toString().padStart(2, '0')}/${(dataNomeacao.getMonth() + 1).toString().padStart(2, '0')}/${dataNomeacao.getFullYear()}`;
        }
        
        if (pericia.prazo) {
            const prazo = new Date(pericia.prazo);
            document.getElementById('prazo').value = `${prazo.getDate().toString().padStart(2, '0')}/${(prazo.getMonth() + 1).toString().padStart(2, '0')}/${prazo.getFullYear()}`;
        }
        
        // Atualizar título
        document.getElementById('modalPericiaTitle').textContent = 'Editar Perícia';
        
        // Abrir modal
        modalPericia.show();
    }
    
    // Função para salvar perícia (nova ou edição)
    async function salvarPericia() {
        // Validar formulário
        const form = document.getElementById('formPericia');
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }
        
        // Coletar dados do formulário
        const id = document.getElementById('periciaId').value;
        const numeroProcesso = document.getElementById('numeroProcesso').value;
        const vara = document.getElementById('vara').value;
        const dataNomeacaoStr = document.getElementById('dataNomeacao').value;
        const prazoStr = document.getElementById('prazo').value;
        const requerente = document.getElementById('requerente').value;
        const requerido = document.getElementById('requerido').value;
        const status = document.getElementById('status').value;
        const honorarios = document.getElementById('honorarios').value ? parseFloat(document.getElementById('honorarios').value) : null;
        const observacoes = document.getElementById('observacoes').value;
        
        // Converter datas
        const dataNomeacaoParts = dataNomeacaoStr.split('/');
        const dataNomeacao = new Date(
            parseInt(dataNomeacaoParts[2]), 
            parseInt(dataNomeacaoParts[1]) - 1, 
            parseInt(dataNomeacaoParts[0])
        ).toISOString();
        
        const prazoParts = prazoStr.split('/');
        const prazo = new Date(
            parseInt(prazoParts[2]), 
            parseInt(prazoParts[1]) - 1, 
            parseInt(prazoParts[0])
        ).toISOString();
        
        // Criar objeto da perícia
        const pericia = {
            numeroProcesso,
            vara,
            dataNomeacao,
            prazo,
            requerente,
            requerido,
            status,
            honorarios,
            observacoes
        };
        
        try {
            let response;
            
            if (id) {
                // Atualizar perícia existente
                pericia.id = parseInt(id);
                response = await fetch(`/api/pericias/${pericia.id}`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(pericia)
                });
            } else {
                // Criar nova perícia
                response = await fetch('/api/pericias', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(pericia)
                });
            }
            
            if (!response.ok) {
                throw new Error('Erro ao salvar perícia');
            }
            
            const data = await response.json();
            
            // Fechar modal
            modalPericia.hide();
            
            // Recarregar perícias
            await carregarPericias();
            
            // Mostrar notificação
            showNotification(id ? 'Perícia atualizada com sucesso!' : 'Perícia adicionada com sucesso!', 'success');
        } catch (error) {
            console.error('Erro:', error);
            showNotification('Erro ao salvar perícia: ' + error.message, 'danger');
        }
    }
    
    // Função para confirmar exclusão
    function confirmarExclusao(pericia) {
        document.getElementById('mensagemConfirmacao').textContent = `Tem certeza que deseja excluir a perícia do processo ${pericia.numeroProcesso}?`;
        
        acaoConfirmacao = async () => {
            try {
                const response = await fetch(`/api/pericias/${pericia.id}`, {
                    method: 'DELETE'
                });
                
                if (!response.ok) {
                    throw new Error('Erro ao excluir perícia');
                }
                
                const data = await response.json();
                
                // Fechar modal
                modalConfirmacao.hide();
                
                // Recarregar perícias
                await carregarPericias();
                
                // Mostrar notificação
                showNotification('Perícia excluída com sucesso!', 'success');
            } catch (error) {
                console.error('Erro:', error);
                showNotification('Erro ao excluir perícia: ' + error.message, 'danger');
            }
        };
        
        // Configurar botão de confirmação
        btnConfirmarAcao.onclick = acaoConfirmacao;
        
        // Abrir modal
        modalConfirmacao.show();
    }
    
    // Função para filtrar perícias
    function filtrarPericias() {
        renderizarPericias();
    }
    
    // Função para realizar backup
    async function realizarBackup() {
        try {
            // Obter token de API do localStorage (em uma aplicação real, seria melhor ter autenticação)
            const token = localStorage.getItem('api_token') || '12345';
            
            const response = await fetch('/api/backup', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ timestamp: new Date().toISOString() })
            });
            
            if (!response.ok) {
                throw new Error('Erro ao realizar backup');
            }
            
            const data = await response.json();
            
            // Mostrar notificação
            showNotification('Backup realizado com sucesso!', 'success');
        } catch (error) {
            console.error('Erro:', error);
            showNotification('Erro ao realizar backup: ' + error.message, 'danger');
        }
    }
});
