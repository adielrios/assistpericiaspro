const express = require('express');
const router = express.Router();

// Rota para obter sumário do dashboard
router.get('/sumario', (req, res) => {
  // Em produção, obter dados do banco de dados
  
  // Em desenvolvimento, retornar dados fictícios
  return res.json({
    pericias_pendentes: 3,
    processos_ativos: 12,
    laudos_emitidos: 8,
    alertas_count: 2
  });
});

module.exports = router;
