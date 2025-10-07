# 🔐 Configuração de Autenticação - Supabase

## 📋 Visão Geral

Este documento explica como configurar a autenticação 100% pelo Supabase para o sistema de gestão de TI.

## 🚀 Passo a Passo

### 1. Configurar Variáveis de Ambiente

Crie um arquivo `.env.local` na raiz do projeto com:

```env
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_chave_anonima_aqui
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

**Onde encontrar essas informações:**
- Acesse o [Supabase Dashboard](https://supabase.com/dashboard)
- Selecione seu projeto
- Vá para **Settings** → **API**
- Copie a **Project URL** e **anon public** key

### 2. Configurar Autenticação no Supabase

#### 2.1 Habilitar Auth
- Vá para **Authentication** → **Settings**
- Em **Site URL**, adicione: `http://localhost:3000`
- Em **Redirect URLs**, adicione: `http://localhost:3000/**`

#### 2.2 Configurar Provedores
- **Email**: Habilitado por padrão
- **Google** (opcional): Configure OAuth se desejar
- **Outros provedores**: Configure conforme necessário

#### 2.3 Configurar Email
- Vá para **Authentication** → **Email Templates**
- Personalize os templates de confirmação e reset de senha
- Configure o serviço de email (SendGrid, SMTP, etc.)

### 3. Configurar Políticas de Segurança (RLS)

As políticas já estão configuradas no script SQL, mas você pode ajustar:

```sql
-- Exemplo: Permitir que usuários vejam apenas seus próprios dados
CREATE POLICY "Users can view own data" ON public.users
    FOR SELECT USING (auth.uid() = id);
```

### 4. Testar a Autenticação

#### 4.1 Criar Usuário de Teste
1. Execute o script `sample_data.sql` no Supabase
2. Use as credenciais:
   - **Admin**: `admin@empresa.com` / `senha123`
   - **Gerente**: `gerente@empresa.com` / `senha123`
   - **Técnico**: `tecnico@empresa.com` / `senha123`

#### 4.2 Testar Login
1. Acesse `http://localhost:3000`
2. Use as credenciais de teste
3. Verifique se redireciona para `/dashboard`

## 🔧 Configurações Avançadas

### 1. Customizar Redirecionamentos

```typescript
// lib/supabase.ts
export const supabase = createClient(url, key, {
  auth: {
    redirectTo: process.env.NEXT_PUBLIC_SITE_URL + '/dashboard',
    // Outras configurações...
  }
})
```

### 2. Configurar Middleware (Opcional)

Crie `middleware.ts` na raiz para proteção de rotas:

```typescript
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })

  const {
    data: { session },
  } = await supabase.auth.getSession()

  // Proteger rotas que requerem autenticação
  if (!session && req.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/', req.url))
  }

  return res
}

export const config = {
  matcher: ['/dashboard/:path*', '/chamados/:path*', '/inventario/:path*', '/rede/:path*']
}
```

### 3. Configurar Refresh Token

```typescript
// lib/supabase.ts
export const supabase = createClient(url, key, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    flowType: 'pkce', // Mais seguro
  }
})
```

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. Erro "Invalid login credentials"
- Verifique se o usuário existe na tabela `auth.users`
- Confirme se a senha está correta
- Verifique se o email foi confirmado

#### 2. Erro de redirecionamento
- Verifique as URLs em **Authentication** → **Settings**
- Confirme se `NEXT_PUBLIC_SITE_URL` está correto
- Teste com `http://localhost:3000` e `https://seudominio.com`

#### 3. Usuário não aparece na tabela `users`
- Execute o script `sample_data.sql`
- Verifique se as políticas RLS estão funcionando
- Confirme se o trigger está criando o perfil automaticamente

#### 4. Erro de CORS
- Verifique se o domínio está na lista de **Site URLs**
- Adicione `localhost:3000` para desenvolvimento
- Configure corretamente para produção

### Logs e Debug

```typescript
// Habilitar logs detalhados
const supabase = createClient(url, key, {
  auth: {
    debug: true, // Apenas em desenvolvimento
  }
})

// Verificar sessão atual
const { data: { session } } = await supabase.auth.getSession()
console.log('Sessão atual:', session)

// Verificar usuário
const { data: { user } } = await supabase.auth.getUser()
console.log('Usuário atual:', user)
```

## 📱 Uso nos Componentes

### 1. Hook de Autenticação

```typescript
import { useAuth } from '@/hooks/useAuth'

function MyComponent() {
  const { user, signIn, signOut, loading } = useAuth()
  
  if (loading) return <div>Carregando...</div>
  if (!user) return <div>Faça login</div>
  
  return (
    <div>
      <p>Olá, {user.full_name}!</p>
      <button onClick={signOut}>Sair</button>
    </div>
  )
}
```

### 2. Proteção de Rotas

```typescript
import { AuthGuard } from '@/components/auth-guard'

function DashboardPage() {
  return (
    <AuthGuard>
      <div>Conteúdo protegido</div>
    </AuthGuard>
  )
}

// Com roles específicos
function AdminPage() {
  return (
    <AuthGuard requiredRoles={['admin']}>
      <div>Página apenas para admins</div>
    </AuthGuard>
  )
}
```

### 3. Verificação de Permissões

```typescript
import { useAuth } from '@/hooks/useAuth'

function ConditionalComponent() {
  const { hasRole, hasAnyRole } = useAuth()
  
  return (
    <div>
      {hasRole('admin') && <AdminPanel />}
      {hasAnyRole(['admin', 'manager']) && <ManagerTools />}
    </div>
  )
}
```

## 🔒 Segurança

### 1. Políticas RLS
- Todas as tabelas têm RLS habilitado
- Políticas baseadas em roles de usuário
- Acesso restrito por unidade/loja

### 2. Tokens
- Refresh tokens automáticos
- Sessões persistentes
- Logout automático em inatividade

### 3. Validação
- Verificação de email obrigatória
- Senhas com requisitos mínimos
- Rate limiting para tentativas de login

## 📈 Próximos Passos

### 1. Produção
- Configure domínio real em **Site URLs**
- Use HTTPS em produção
- Configure backup de autenticação

### 2. Recursos Adicionais
- Implementar 2FA (autenticação de dois fatores)
- Adicionar login social (Google, GitHub)
- Configurar notificações por email

### 3. Monitoramento
- Configure logs de autenticação
- Monitore tentativas de login falhadas
- Implemente alertas de segurança

---

## ✅ Checklist de Configuração

- [ ] Variáveis de ambiente configuradas
- [ ] Supabase Auth habilitado
- [ ] URLs de redirecionamento configuradas
- [ ] Templates de email personalizados
- [ ] Políticas RLS funcionando
- [ ] Usuários de teste criados
- [ ] Login funcionando
- [ ] Logout funcionando
- [ ] Proteção de rotas funcionando
- [ ] Verificação de roles funcionando

---

**🎉 Sua autenticação está configurada e funcionando!**
