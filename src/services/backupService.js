const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');

// Função para criar backup
function createBackup() {
  try {
    const date = new Date();
    const timestamp = date.toISOString().replace(/[:.]/g, '-');
    const backupDir = path.join(__dirname, '../../backups');
    
    // Criar diretório de backup se não existir
    if (!fs.existsSync(backupDir)) {
      fs.mkdirSync(backupDir, { recursive: true });
    }
    
    // Backup do banco de dados
    const dbPath = path.join(__dirname, 
'../../data/assistpericias.sqlite');
    const dbBackupPath = path.join(backupDir, 
`assistpericias_${timestamp}.sqlite`);
    
    if (fs.existsSync(dbPath)) {
      fs.copyFileSync(dbPath, dbBackupPath);
      logger.info(`Backup do banco de dados criado: ${dbBackupPath}`);
    }
    
    // Backup de tokens
    const tokensDir = path.join(__dirname, '../../data/tokens');
    const tokensBackupDir = path.join(backupDir, `tokens_${timestamp}`);
    
    if (fs.existsSync(tokensDir)) {
      fs.mkdirSync(tokensBackupDir, { recursive: true });
      
      const tokenFiles = fs.readdirSync(tokensDir);
      
      tokenFiles.forEach(file => {
        const srcPath = path.join(tokensDir, file);
        const destPath = path.join(tokensBackupDir, file);
        
        fs.copyFileSync(srcPath, destPath);
      });
      
      logger.info(`Backup de tokens criado: ${tokensBackupDir}`);
    }
    
    // Limpar backups antigos (manter apenas os últimos 10)
    cleanOldBackups();
    
    return true;
  } catch (err) {
    logger.error('Erro ao criar backup:', err);
    return false;
  }
}

// Função para limpar backups antigos
function cleanOldBackups() {
  try {
    const backupDir = path.join(__dirname, '../../backups');
    
    if (!fs.existsSync(backupDir)) {
      return;
    }
    
    // Listar arquivos de backup do banco de dados
    const dbBackups = fs.readdirSync(backupDir)
      .filter(file => file.endsWith('.sqlite'))
      .map(file => ({
        name: file,
        path: path.join(backupDir, file),
        time: fs.statSync(path.join(backupDir, file)).mtime.getTime()
      }))
      .sort((a, b) => b.time - a.time);
    
    // Manter apenas os 10 mais recentes
    if (dbBackups.length > 10) {
      for (let i = 10; i < dbBackups.length; i++) {
        fs.unlinkSync(dbBackups[i].path);
        logger.info(`Backup antigo removido: ${dbBackups[i].name}`);
      }
    }
    
    // Fazer o mesmo para os diretórios de tokens
    const tokenDirs = fs.readdirSync(backupDir)
      .filter(dir => dir.startsWith('tokens_'))
      .map(dir => ({
        name: dir,
        path: path.join(backupDir, dir),
        time: fs.statSync(path.join(backupDir, dir)).mtime.getTime()
      }))
      .sort((a, b) => b.time - a.time);
    
    // Manter apenas os 10 mais recentes
    if (tokenDirs.length > 10) {
      for (let i = 10; i < tokenDirs.length; i++) {
        fs.rmSync(tokenDirs[i].path, { recursive: true, force: true });
        logger.info(`Backup antigo de tokens removido: 
${tokenDirs[i].name}`);
      }
    }
  } catch (err) {
    logger.error('Erro ao limpar backups antigos:', err);
  }
}

module.exports = {
  createBackup,
  cleanOldBackups
};
