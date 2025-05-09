document.addEventListener('DOMContentLoaded', () => {
  // Verificar se já está autenticado
  const token = localStorage.getItem('token');
  if (token) {
    // Verificar validade do token
    fetch('/api/auth/verify', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.valid) {
        window.location.href = '/dashboard.html';
      } else {
        localStorage.removeItem('token');
      }
    })
    .catch(err => {
      console.error('Erro ao verificar token:', err);
      localStorage.removeItem('token');
    });
  }
  
  // Configurar form de login
  const loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const token = document.getElementById('token').value.trim();
      
      // Em modo de desenvolvimento, permitir login com token simples
      if (token === '12345') {
        localStorage.setItem('token', token);
        window.location.href = '/dashboard.html';
        return;
      }
      
      // Em produção, fazer autenticação via API
      fetch('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ token })
      })
      .then(response => response.json())
      .then(data => {
        if (data.token) {
          localStorage.setItem('token', data.token);
          window.location.href = '/dashboard.html';
        } else {
          document.getElementById('errorMessage').textContent = data.error 
|| 'Token inválido';
        }
      })
      .catch(err => {
        console.error('Erro no login:', err);
        document.getElementById('errorMessage').textContent = 'Erro no 
servidor. Tente novamente.';
      });
    });
  }
});
