# Configuração do Supabase para o Sistema de TI

## Problema Identificado
Os erros 404 que você está vendo indicam que as variáveis de ambiente do Supabase não estão configuradas corretamente.

## Solução

### 1. Criar arquivo .env.local
Na raiz do seu projeto, crie um arquivo chamado `.env.local` com o seguinte conteúdo:

```bash
# URL do seu projeto Supabase
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co

# Chave anônima do Supabase (pública, segura para o frontend)
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_chave_anonima_aqui
```

### 2. Obter as credenciais do Supabase
1. Acesse o [Dashboard do Supabase](https://supabase.com/dashboard)
2. Selecione seu projeto
3. Vá para **Settings** → **API**
4. Copie:
   - **Project URL** (para NEXT_PUBLIC_SUPABASE_URL)
   - **anon public** (para NEXT_PUBLIC_SUPABASE_ANON_KEY)

### 3. Reiniciar o servidor
Após criar o arquivo `.env.local`, reinicie o servidor Next.js:

```bash
npm run dev
```

### 4. Verificar no console
Abra o console do navegador e verifique se aparecem os logs:
- "Supabase URL: [sua-url]"
- "Supabase Key: Configurada"

## Estrutura da Tabela
A tabela `network_monitoring` tem a seguinte estrutura:
- `id` (UUID, Primary Key)
- `unit_id` (UUID, Foreign Key para units)
- `ip_address` (INET)
- `hostname` (TEXT)
- `status` (TEXT: 'online', 'offline', 'warning', 'unknown')
- `uptime_percentage` (DECIMAL)
- `last_ping_ms` (INTEGER)
- `vpn_status` (TEXT: 'connected', 'disconnected', 'unknown')
- `services` (JSONB)
- `last_check` (TIMESTAMP)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## Campos Removidos
Os seguintes campos foram removidos do formulário pois não existem na tabela:
- `name`
- `unit_name`
- `device_type`
- `notes`

## Teste
Após a configuração, tente adicionar um dispositivo com apenas:
- Endereço IP (obrigatório)
- Hostname (opcional)

O sistema deve funcionar corretamente.
