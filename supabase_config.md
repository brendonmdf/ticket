# Configuração do Banco de Dados - Sistema de Gestão de TI

## 📋 Visão Geral

Este documento contém instruções para configurar e usar o banco de dados completo do sistema de gestão de TI no Supabase.

## 🚀 Como Executar o Script

### 1. Acesse o Supabase
- Faça login no [Supabase](https://supabase.com)
- Acesse seu projeto
- Vá para **SQL Editor**

### 2. Execute o Script Principal
- Cole todo o conteúdo do arquivo `supabase_database_setup.sql`
- Clique em **Run** para executar
- Aguarde a conclusão (pode levar alguns minutos)

### 3. Verificação
- O script mostrará mensagens de confirmação
- Verifique se todas as tabelas foram criadas em **Table Editor**

## 🗄️ Estrutura do Banco de Dados

### Tabelas Principais

| Tabela | Descrição | Registros |
|--------|-----------|-----------|
| `users` | Usuários do sistema | Estende auth.users |
| `units` | Unidades/lojas | - |
| `assets` | Ativos do inventário | - |
| `tickets` | Chamados/tickets | - |
| `network_monitoring` | Status da rede | - |

### Relacionamentos

```
users (1) ←→ (N) tickets
users (1) ←→ (N) assets
units (1) ←→ (N) assets
units (1) ←→ (N) tickets
assets (1) ←→ (N) asset_movements
tickets (1) ←→ (N) ticket_comments
```

## 🔐 Configuração de Autenticação

### 1. Habilitar Auth no Supabase
- Vá para **Authentication** → **Settings**
- Configure os provedores desejados (Email, Google, etc.)

### 2. Configurar RLS (Row Level Security)
- Todas as tabelas já têm RLS habilitado
- Políticas de acesso configuradas automaticamente

### 3. Roles de Usuário
- **admin**: Acesso total ao sistema
- **manager**: Gerencia unidades e tickets
- **technician**: Atende tickets e gerencia ativos
- **user**: Cria e visualiza tickets próprios

## 📊 Views e Funções Úteis

### Views Disponíveis
- `dashboard_overview`: Estatísticas gerais
- `tickets_overview`: Tickets com informações completas
- `inventory_overview`: Inventário detalhado
- `network_status_overview`: Status da rede

### Funções Principais
- `search_tickets()`: Busca avançada de tickets
- `get_dashboard_stats()`: Estatísticas do dashboard
- `calculate_average_uptime()`: Uptime médio da rede

## 🔧 Configuração da Aplicação

### 1. Variáveis de Ambiente
```env
NEXT_PUBLIC_SUPABASE_URL=sua_url_do_supabase
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_chave_anonima
```

### 2. Instalar Dependências
```bash
npm install @supabase/supabase-js
```

### 3. Configurar Cliente Supabase
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

## 📱 Exemplos de Uso

### Buscar Tickets
```sql
SELECT * FROM search_tickets(
    p_search := 'impressora',
    p_status := 'new',
    p_priority := 'high'
);
```

### Estatísticas do Dashboard
```sql
SELECT * FROM get_dashboard_stats();
```

### Inventário por Categoria
```sql
SELECT * FROM inventory_overview 
WHERE category_name = 'Computadores';
```

## 🚨 Monitoramento e Manutenção

### 1. Limpeza Automática
- Histórico de rede: 30 dias
- Movimentação de ativos: 1 ano
- Histórico de tickets: 1 ano

### 2. Backup
- Configure backup automático no Supabase
- Recomendado: Diário

### 3. Performance
- Índices criados automaticamente
- Monitorar queries lentas
- Otimizar conforme necessário

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. Erro de Permissão
```sql
-- Verificar políticas RLS
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

#### 2. Tabelas não criadas
```sql
-- Verificar tabelas existentes
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

#### 3. Funções não funcionando
```sql
-- Verificar funções
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public';
```

### Logs e Debug
- Use `RAISE LOG` para debug
- Verifique logs no Supabase
- Monitore performance

## 📈 Próximos Passos

### 1. Dados de Teste
- Crie usuários de teste
- Adicione unidades/lojas
- Cadastre ativos de exemplo
- Crie tickets de teste

### 2. Integração com Frontend
- Implemente autenticação
- Conecte com as tabelas
- Teste todas as funcionalidades

### 3. Personalização
- Ajuste políticas de acesso
- Modifique campos conforme necessário
- Adicione funcionalidades específicas

## 📞 Suporte

### Recursos Úteis
- [Documentação Supabase](https://supabase.com/docs)
- [SQL Reference](https://www.postgresql.org/docs/)
- [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)

### Comunidade
- [Supabase Discord](https://discord.supabase.com)
- [GitHub Issues](https://github.com/supabase/supabase/issues)

---

## ✅ Checklist de Configuração

- [ ] Script SQL executado com sucesso
- [ ] Todas as tabelas criadas
- [ ] RLS habilitado e funcionando
- [ ] Políticas de acesso configuradas
- [ ] Views e funções criadas
- [ ] Dados iniciais inseridos
- [ ] Aplicação conectada ao banco
- [ ] Autenticação funcionando
- [ ] Testes realizados
- [ ] Backup configurado

---

**🎉 Parabéns! Seu banco de dados está configurado e pronto para uso!**
