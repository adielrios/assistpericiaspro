// JavaScript para a página inicial

document.addEventListener('DOMContentLoaded', function() {
    // Carregar próximas perícias
    carregarProximasPericias();
    
    // Função para carregar próximas perícias
    async function carregarProximasPericias() {
        try {
            const response = await fetch('/api/pericias');
            
            if (!response.ok) {
                throw new Error('Erro ao carregar perícias');
            }
            
            const pericias = await response.json();
            
            // Filtrar para mostrar apenas as próximas perícias (não concluídas, ordenadas por prazo)
            const proximasPericias = pericias
                .filter(p => p.status !== 'concluida' && p.status !== 'cancelada')
                .sort((a, b) => new Date(a.prazo) - new Date(b.prazo))
                .slice(0, 3); // Mostrar apenas as 3 primeiras
            
            const containerProximasPericias = document.getElementById('proximasPericias');
            
            if (proximasPericias.length === 0) {
                containerProximasPericias.innerHTML = `
                    <p class="text-center">Nenhuma perícia pendente.</p>
                `;
                return;
            }
            
            // Criar cards para cada perícia
            containerProximasPericias.innerHTML = proximasPericias.map(pericia => {
                // Calcular dias restantes
                const hoje = new Date();
                const prazo = new Date(pericia.prazo);
                const diasRestantes = Math.ceil((prazo - hoje) / (1000 * 60 * 60 * 24));
                
                // Determinar classe para dias restantes
                let diasClass = 'text-success';
                if (diasRestantes < 0) {
                    diasClass = 'text-danger';
                } else if (diasRestantes < 7) {
                    diasClass = 'text-warning';
                }
                
                return `
                    <div class="pericia-item mb-3">
                        <div class="d-flex justify-content-between">
                            <h6>${pericia.numeroProcesso || 'Sem número'}</h6>
                            <span class="${diasClass}">
                                ${diasRestantes < 0 ? 'Atrasado' : diasRestantes === 0 ? 'Hoje' : `${diasRestantes} dia${diasRestantes !== 1 ? 's' : ''}`}
                            </span>
                        </div>
                        <p class="mb-1"><small>${pericia.vara || 'Sem comarca'}</small></p>
                        <div class="progress" style="height: 5px;">
                            <div class="progress-bar 
                                ${diasRestantes < 0 ? 'bg-danger' : diasRestantes < 7 ? 'bg-warning' : 'bg-success'}"
                                role="progressbar" 
                                style="width: ${Math.min(100, Math.max(0, 100 - (diasRestantes * 5)))}%">
                            </div>
                        </div>
                    </div>
                `;
            }).join('');
            
        } catch (error) {
            console.error('Erro:', error);
            const containerProximasPericias = document.getElementById('proximasPericias');
            containerProximasPericias.innerHTML = `
                <p class="text-center text-danger">Erro ao carregar perícias.</p>
            `;
        }
    }
});
