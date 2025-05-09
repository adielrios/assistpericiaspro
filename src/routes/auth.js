const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const fs = require('fs');
const path = require('path');
const router = express.Router();
const logger = require('../utils/logger');

// Rota de login
router.post('/login', (req, res) => {
  const { token } = req.body;
  
  // Em modo de desenvolvimento, verificar token simples
  if (process.env.NODE_ENV === 'development' && token === '12345') {
    try {
      // Verificar se existe o token no diretório de tokens
      const tokenPath = path.join(__dirname, 
'../../data/tokens/12345.json');
      
      if (fs.existsSync(tokenPath)) {
        const tokenData = JSON.parse(fs.readFileSync(tokenPath, 'utf8'));
        const now = Date.now();
        
        if (now > tokenData.expiresAt) {
          return res.status(401).json({ error: 'Token expirado' });
        }
        
        // Gerar JWT
        const jwtToken = jwt.sign(
          { 
            id: tokenData.user.id,
            nome: tokenData.user.nome,
            email: tokenData.user.email,
            role: tokenData.user.role
          },
          process.env.JWT_SECRET,
          { expiresIn: process.env.JWT_EXPIRATION }
        );
        
        return res.json({ token: jwtToken });
      }
    } catch (err) {
      logger.error('Erro ao verificar token de desenvolvimento:', err);
    }
  }
  
  // Em produção, verificar no banco de dados
  // (Não implementado nesta versão simplificada)
  
  return res.status(401).json({ error: 'Token inválido' });
});

// Rota para verificar validade do token
router.post('/verify', (req, res) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    return res.json({ valid: false });
  }
  
  const parts = authHeader.split(' ');
  
  if (parts.length !== 2) {
    return res.json({ valid: false });
  }
  
  const [scheme, token] = parts;
  
  if (!/^Bearer$/i.test(scheme)) {
    return res.json({ valid: false });
  }
  
  // Em modo de desenvolvimento, verificar token simples
  if (process.env.NODE_ENV === 'development' && token === '12345') {
    try {
      // Verificar se existe o token no diretório de tokens
      const tokenPath = path.join(__dirname, 
'../../data/tokens/12345.json');
      
      if (fs.existsSync(tokenPath)) {
        const tokenData = JSON.parse(fs.readFileSync(tokenPath, 'utf8'));
        const now = Date.now();
        
        if (now > tokenData.expiresAt) {
          return res.json({ valid: false });
        }
        
        return res.json({ valid: true });
      }
    } catch (err) {
      logger.error('Erro ao verificar token de desenvolvimento:', err);
    }
  }
  
  // Verificar JWT
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.json({ valid: false });
    }
    
    return res.json({ valid: true });
  });
});

module.exports = router;
