#!/usr/bin/env node

/**
 * Script para iniciar a aplicação em modo de produção local na porta 3005
 * 
 * Uso:
 * node start-prod-local.js
 * 
 * ou
 * 
 * npm run start:prod
 */

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Iniciando aplicação em modo de produção local...');
console.log('📍 Porta: 3005');
console.log('🌐 URL: http://localhost:3005');
console.log('');

// Verificar se o build existe
const fs = require('fs');
const buildPath = path.join(__dirname, '.next');

if (!fs.existsSync(buildPath)) {
  console.error('❌ Build não encontrado! Execute "npm run build" primeiro.');
  process.exit(1);
}

// Iniciar o servidor Next.js na porta 3005
const nextStart = spawn('npx', ['next', 'start', '-p', '3005'], {
  stdio: 'inherit',
  shell: true
});

nextStart.on('close', (code) => {
  console.log(`\n🛑 Servidor finalizado com código: ${code}`);
});

nextStart.on('error', (err) => {
  console.error('❌ Erro ao iniciar o servidor:', err);
  process.exit(1);
});

// Capturar Ctrl+C para finalizar graciosamente
process.on('SIGINT', () => {
  console.log('\n🛑 Finalizando servidor...');
  nextStart.kill('SIGINT');
});
