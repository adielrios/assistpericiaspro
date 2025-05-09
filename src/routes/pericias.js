const express = require('express');
const router = express.Router();
const db = require('../models/db').db;

// Rota para obter próximas perícias
router.get('/proximas', (req, res) => {
  // Em produção, obter dados do banco de dados
  
  // Em desenvolvimento, retornar dados fictícios
  return res.json([
    {
      id: 1,
      paciente: 'João Silva',
      processo: '0001234-56.2025.8.26.0100',
      data: '2025-05-10',
      hora: '14:00',
      status: 'Agendada'
    },
    {
      id: 2,
      paciente: 'Maria Oliveira',
      processo: '0002345-67.2025.8.26.0100',
      data: '2025-05-15',
      hora: '10:30',
      status: 'Confirmada'
    },
    {
      id: 3,
      paciente: 'Pedro Santos',
      processo: '0003456-78.2025.8.26.0100',
      data: '2025-05-20',
      hora: '15:45',
      status: 'Pendente'
    }
  ]);
});

module.exports = router;
