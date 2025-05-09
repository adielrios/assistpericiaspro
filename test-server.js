// Servidor de teste simples
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('<h1>AssistPericias - Servidor de Teste</h1><p>Se você consegue 
ver esta mensagem, o servidor está funcionando!</p>');
});

const port = 3000;
server.listen(port, '0.0.0.0', () => {
  console.log(`Servidor de teste rodando em http://localhost:${port}`);
  console.log('Pressione Ctrl+C para encerrar');
});

// Mostrar quando o servidor for encerrado
process.on('SIGINT', () => {
  console.log('Servidor encerrado');
  process.exit(0);
});
