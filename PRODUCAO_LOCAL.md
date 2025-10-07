# 🚀 GUIA PARA PRODUÇÃO LOCAL

## 📋 **Pré-requisitos**

### **1. Node.js e npm**
```bash
# Verificar versões
node --version  # Deve ser 18+ ou 20+
npm --version   # Deve ser 9+
```

### **2. Supabase Configurado**
- ✅ Projeto criado no Supabase
- ✅ Tabelas criadas e funcionando
- ✅ RLS configurado (se necessário)

## 🔧 **Passo a Passo**

### **1. Preparar Variáveis de Ambiente**

**✅ Você já tem o arquivo `.env.local` configurado!**

Seu arquivo `.env.local` existente já contém as variáveis necessárias:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

**Não é necessário criar um novo arquivo.** O script usará automaticamente o `.env.local` existente.

### **2. Instalar Dependências de Produção**

```bash
# Remover node_modules e package-lock.json
rm -rf node_modules package-lock.json

# Instalar apenas dependências de produção
npm ci --only=production

# Ou se preferir yarn
yarn install --production
```

### **3. Build da Aplicação**

```bash
# Build para produção
npm run build

# Verificar se o build foi bem-sucedido
ls -la .next/
```

### **4. Testar Build Localmente**

```bash
# Rodar em modo produção
npm start

# A aplicação estará disponível em:
# http://localhost:3000
```

### **5. Verificar Performance**

```bash
# Analisar bundle
npm run analyze

# Verificar tamanho dos arquivos
du -sh .next/
```

## 🐳 **Docker (Opcional)**

### **1. Dockerfile**

```dockerfile
FROM node:18-alpine AS base

# Dependencies
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --only=production

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
```

### **2. Docker Compose**

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL}
      - NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY}
    restart: unless-stopped
```

### **3. Comandos Docker**

```bash
# Build da imagem
docker build -t kyndo-app .

# Rodar container
docker run -p 3000:3000 --env-file .env.local kyndo-app

# Ou com docker-compose
docker-compose up --build
```

## 📊 **Monitoramento e Logs**

### **1. Logs de Produção**

```bash
# Ver logs em tempo real
npm start 2>&1 | tee production.log

# Ou com PM2
npm install -g pm2
pm2 start npm --name "kyndo-app" -- start
pm2 logs kyndo-app
```

### **2. Métricas de Performance**

```bash
# Verificar uso de memória
ps aux | grep node

# Verificar portas em uso
netstat -tulpn | grep :3000

# Verificar logs do Next.js
tail -f .next/server.log
```

## 🔒 **Segurança para Produção**

### **1. Headers de Segurança**

Adicione ao `next.config.js`:

```javascript
const nextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ]
  },
}
```

### **2. Variáveis de Ambiente Seguras**

```bash
# NUNCA commitar estas variáveis
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# Variáveis sensíveis (não expostas ao cliente)
SUPABASE_SERVICE_ROLE_KEY=
DATABASE_URL=
```

## 🚀 **Comandos Rápidos**

### **1. Build e Deploy**

```bash
# Build completo
npm run build

# Testar produção localmente
npm start

# Build e start em um comando
npm run build && npm start
```

### **2. Verificação de Status**

```bash
# Verificar se está rodando
curl http://localhost:3000

# Verificar health check
curl http://localhost:3000/api/health

# Verificar métricas
curl http://localhost:3000/api/metrics
```

## 📝 **Checklist de Produção**

- [ ] Variáveis de ambiente configuradas
- [ ] Dependências de produção instaladas
- [ ] Build executado com sucesso
- [ ] Aplicação rodando em modo produção
- [ ] Logs configurados
- [ ] Monitoramento ativo
- [ ] Segurança configurada
- [ ] Performance otimizada

## 🆘 **Troubleshooting**

### **1. Erro de Build**

```bash
# Limpar cache
rm -rf .next/
npm run build
```

### **2. Erro de Porta**

```bash
# Verificar portas em uso
lsof -i :3000

# Matar processo se necessário
kill -9 <PID>
```

### **3. Erro de Memória**

```bash
# Aumentar limite de memória
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build
```

## 🎯 **Resultado Esperado**

Após seguir todos os passos:

- ✅ **Aplicação rodando** em modo produção
- ✅ **Performance otimizada** para produção
- ✅ **Logs estruturados** e monitorados
- ✅ **Segurança configurada** adequadamente
- ✅ **Acesso via** http://localhost:3000

**Sua aplicação Kyndo estará rodando em modo produção localmente!** 🚀
