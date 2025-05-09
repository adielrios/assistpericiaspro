const express = require('express');
const router = express.Router();

// Rota a ser implementada
router.get('/', (req, res) => {
  res.json({ message: 'Módulo de configurações em desenvolvimento' });
});

module.exports = router;
