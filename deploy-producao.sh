#!/bin/bash

# =====================================================
# SCRIPT DE DEPLOY PARA PRODUÇÃO LOCAL
# =====================================================

set -e  # Parar em caso de erro

echo "🚀 Iniciando deploy para produção local..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    error "Este script deve ser executado na raiz do projeto Next.js"
    exit 1
fi

# Verificar Node.js
step "Verificando versão do Node.js..."
if ! command -v node &> /dev/null; then
    error "Node.js não está instalado"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    error "Node.js 18+ é necessário. Versão atual: $(node --version)"
    exit 1
fi

log "Node.js $(node --version) ✓"

# Verificar npm
step "Verificando versão do npm..."
if ! command -v npm &> /dev/null; then
    error "npm não está instalado"
    exit 1
fi

log "npm $(npm --version) ✓"

# Verificar variáveis de ambiente
step "Verificando variáveis de ambiente..."
if [ ! -f ".env.local" ]; then
    error "Arquivo .env.local não encontrado"
    error "Crie o arquivo .env.local com suas credenciais do Supabase"
    exit 1
fi

# Verificar se as variáveis essenciais estão configuradas
if ! grep -q "NEXT_PUBLIC_SUPABASE_URL" .env.local || ! grep -q "NEXT_PUBLIC_SUPABASE_ANON_KEY" .env.local; then
    error "Configure NEXT_PUBLIC_SUPABASE_URL e NEXT_PUBLIC_SUPABASE_ANON_KEY no arquivo .env.local"
    
    exit 1
fi

log "Variáveis de ambiente configuradas ✓"

# Limpar instalações anteriores
step "Limpando instalações anteriores..."
if [ -d "node_modules" ]; then
    log "Removendo node_modules..."
    rm -rf node_modules
fi

if [ -f "package-lock.json" ]; then
    log "Removendo package-lock.json..."
    rm -f package-lock.json
fi

if [ -d ".next" ]; then
    log "Removendo build anterior..."
    rm -rf .next
fi

# Instalar dependências
step "Instalando dependências..."
log "Instalando dependências de produção..."
npm ci --only=production

if [ $? -eq 0 ]; then
    log "Dependências instaladas com sucesso ✓"
else
    error "Falha ao instalar dependências"
    exit 1
fi

# Build da aplicação
step "Executando build para produção..."
log "Iniciando build..."
npm run build

if [ $? -eq 0 ]; then
    log "Build executado com sucesso ✓"
else
    error "Falha no build"
    exit 1
fi

# Verificar build
step "Verificando build..."
if [ -d ".next" ]; then
    BUILD_SIZE=$(du -sh .next/ | cut -f1)
    log "Build criado: .next/ ($BUILD_SIZE) ✓"
else
    error "Diretório .next/ não foi criado"
    exit 1
fi

# Verificar arquivos essenciais
if [ -f ".next/server.js" ] || [ -d ".next/standalone" ]; then
    log "Arquivos de produção criados ✓"
else
    warn "Build não está em modo standalone"
fi

# Testar aplicação
step "Testando aplicação..."
log "Iniciando aplicação em modo produção..."
log "A aplicação estará disponível em: http://localhost:3000"
log "Pressione Ctrl+C para parar"

# Iniciar aplicação
npm start

echo ""
log "🎉 Deploy para produção local concluído com sucesso!"
log "A aplicação Kyndo está rodando em modo produção"
log "Acesse: http://localhost:3000"
