// Servidor AssistPericias simplificado
require('dotenv').config();
const express = require('express');
const path = require('path');

// Inicializar Express
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../public')));

// Rota principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Rota do dashboard
app.get('/dashboard', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/dashboard.html'));
});

// Rota de autenticação simples
app.post('/api/auth/login', (req, res) => {
  const { token } = req.body;
  
  if (token === '12345') {
    return res.json({ 
      success: true,
      token: "token-simulado", 
      user: {
        id: 1,
        nome: "Dr. Adiel Carneiro Rios",
        email: "adiel.rios@abp.org.br",
        role: "admin"
      }
    });
  }
  
  return res.status(401).json({ success: false, error: 'Token inválido' 
});
});

// Iniciar servidor
app.listen(port, '0.0.0.0', () => {
  console.log(`AssistPericias iniciado na porta ${port}`);
  console.log(`Acesse: http://localhost:${port}`);
  console.log(`Use o token de desenvolvimento: 12345`);
});
