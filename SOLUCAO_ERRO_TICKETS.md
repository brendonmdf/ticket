# 🔧 SOLUÇÃO PARA O ERRO DE CRIAÇÃO DE TICKETS

## ❌ Problemas Identificados

### 1. **Colunas Faltantes:**
O erro `"Could not find the 'requester_email' column of 'tickets' in the schema cache"` ocorre porque a tabela `tickets` não possui as colunas necessárias para o formulário externo.

### 2. **Constraints Problemáticas:**
- **`tickets_category_check`** - Não aceita o valor `'geral'`
- **`tickets_status_check`** - Não aceita o valor `'open'`
- **`tickets_priority_check`** - Pode ter restrições similares

### 3. **🚨 NOVO PROBLEMA: Recursão Infinita na Policy:**
- **`"infinite recursion detected in policy for relation 'users'"`** - Policy da tabela `users` causando recursão infinita

## 🔍 Análise dos Problemas

### Colunas Faltantes na Tabela `tickets`:
- `requester_email` - Email do solicitante
- `requester_name` - Nome do solicitante  
- `requester_phone` - Telefone do solicitante
- `unit_name` - Nome da unidade/loja
- `source` - Origem do ticket (ex: external_form)
- `category` - Categoria do ticket

### Problemas de Constraints:
As colunas `status`, `priority` e `category` têm constraints `CHECK` que só aceitam valores específicos, mas não aceitam os valores usados pelo formulário externo:
- **Status**: Aceita `'new'`, `'in_progress'`, `'resolved'`, `'closed'`, `'cancelled'` mas não `'open'`
- **Category**: Aceita `'hardware'`, `'software'`, `'network'`, `'access'`, `'other'` mas não `'geral'`
- **Priority**: Pode ter restrições similares

### Problema de Policy de Recursão:
A tabela `users` tem uma política RLS que está causando recursão infinita, provavelmente tentando acessar a própria tabela `users` de forma recursiva durante a inserção de tickets.

## ✅ Solução

### 🚨 **IMPORTANTE: Execute os scripts na ordem correta!**

Devido aos múltiplos problemas, você precisa executar **DOIS scripts** na sequência correta:

### Passo 1: Corrigir Colunas e Constraints
Execute o arquivo `adicionar_colunas_tickets_corrigido.sql` no **SQL Editor do Supabase**:

1. Acesse o painel do Supabase
2. Vá para **SQL Editor**
3. Cole o conteúdo do arquivo `adicionar_colunas_tickets_corrigido.sql`
4. Clique em **Run** para executar

### Passo 2: Corrigir Policy de Recursão
Execute o arquivo `corrigir_policy_recursao_users.sql` no **SQL Editor do Supabase**:

1. Ainda no **SQL Editor**
2. Cole o conteúdo do arquivo `corrigir_policy_recursao_users.sql`
3. Clique em **Run** para executar

### Passo 3: O que os Scripts Fazem

#### Script 1 - `adicionar_colunas_tickets_corrigido.sql`:
1. **Verifica** a estrutura atual da tabela
2. **Remove** e **recria** constraints problemáticas
3. **Adiciona** todas as colunas faltantes
4. **Testa** a inserção de um ticket

#### Script 2 - `corrigir_policy_recursao_users.sql`:
1. **Identifica** policies problemáticas na tabela `users`
2. **Remove** policies que causam recursão infinita
3. **Cria** novas policies simples e seguras
4. **Configura** policies para tickets (internos e externos)
5. **Testa** inserção de ticket com as novas policies

### Passo 4: Verificar a Execução
Após executar AMBOS os scripts, você deve ver:
- Mensagens sobre constraints sendo corrigidas
- Mensagens sobre policies sendo removidas e recriadas
- Mensagens de sucesso para cada coluna adicionada
- Estrutura atualizada da tabela
- Tickets de teste inseridos com sucesso

### Passo 5: Testar o Sistema
Após executar AMBOS os scripts:
1. Volte para a aplicação
2. Tente criar um novo chamado
3. Os erros devem estar resolvidos

## 📋 Estrutura Final da Tabela `tickets`

```sql
CREATE TABLE public.tickets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ticket_number TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'new',
    priority TEXT DEFAULT 'medium',
    category TEXT DEFAULT 'geral',
    
    -- Campos para usuários internos
    requester_id UUID REFERENCES public.users(id),
    assignee_id UUID REFERENCES public.users(id),
    unit_id UUID REFERENCES public.units(id),
    
    -- Campos para usuários externos (NOVOS)
    requester_name TEXT,
    requester_email TEXT,
    requester_phone TEXT,
    unit_name TEXT,
    source TEXT DEFAULT 'internal',
    
    -- Campos existentes
    asset_id UUID REFERENCES public.assets(id),
    estimated_hours INTEGER,
    actual_hours INTEGER,
    due_date TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Novas constraints flexíveis
ALTER TABLE public.tickets ADD CONSTRAINT tickets_category_check 
CHECK (category IN ('hardware', 'software', 'network', 'access', 'other', 'geral', 'internet', 'equipamento', 'sistema'));

ALTER TABLE public.tickets ADD CONSTRAINT tickets_status_check 
CHECK (status IN ('new', 'open', 'in_progress', 'resolved', 'closed', 'cancelled', 'pending'));

ALTER TABLE public.tickets ADD CONSTRAINT tickets_priority_check 
CHECK (priority IN ('low', 'medium', 'high', 'critical', 'urgent'));

-- Novas policies seguras
CREATE POLICY "tickets_insert_auth" ON public.tickets
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL
        OR
        (requester_email IS NOT NULL AND source = 'external_form')
    );

CREATE POLICY "tickets_select_auth" ON public.tickets
    FOR SELECT USING (
        auth.uid() IS NOT NULL
        OR
        (requester_email IS NOT NULL AND source = 'external_form')
    );
```

## 🚀 Como Funciona

### Para Usuários Internos:
- Usam `requester_id`, `assignee_id`, `unit_id`
- Dados são vinculados às tabelas `users` e `units`
- Policies baseadas em `auth.uid()`

### Para Usuários Externos:
- Usam `requester_name`, `requester_email`, `requester_phone`, `unit_name`
- Dados são armazenados diretamente na tabela `tickets`
- Campo `source` identifica a origem como 'external_form'
- Policies permitem inserção sem autenticação

## 🔒 Políticas de Segurança (RLS)

Os scripts configuram policies RLS seguras para:
- **Tabela `users`**: Usuários só acessam seus próprios dados
- **Tabela `tickets`**: Inserção permitida para usuários autenticados E formulários externos
- **Sem recursão infinita**: Policies simples e diretas

## 📝 Notas Importantes

1. **Backup**: Faça backup do banco antes de executar alterações
2. **Ordem dos Scripts**: Execute primeiro o de colunas, depois o de policies
3. **Constraints**: O primeiro script corrige automaticamente todas as constraints problemáticas
4. **Policies**: O segundo script remove policies problemáticas e cria novas seguras
5. **Teste**: Sempre teste em ambiente de desenvolvimento primeiro
6. **Monitoramento**: Monitore os logs após a aplicação das mudanças

## 🆘 Em Caso de Problemas

Se encontrar algum erro durante a execução:

1. **Verifique se tem permissões de administrador** no Supabase
2. **Confirme se as tabelas existem** (`tickets` e `users`)
3. **Execute os scripts na ordem correta** (colunas primeiro, policies depois)
4. **Verifique os logs de erro** no console do Supabase
5. **Execute os scripts em partes menores** se necessário

## ✅ Verificação Final

Após executar AMBOS os scripts, você deve ver:
- Mensagens sobre constraints sendo corrigidas
- Mensagens sobre policies sendo removidas e recriadas
- Mensagens de sucesso para cada coluna adicionada
- Estrutura atualizada da tabela
- Tickets de teste inseridos com sucesso
- Aplicação funcionando sem erros

## 🔍 Scripts Disponíveis (ORDEM DE EXECUÇÃO)

1. **`adicionar_colunas_tickets_corrigido.sql`** - **PRIMEIRO** (corrige colunas e constraints)
2. **`corrigir_policy_recursao_users.sql`** - **SEGUNDO** (corrige policies de recursão)
3. **`diagnostico_completo_constraints.sql`** - Para diagnóstico (OPCIONAL)
4. **`verificar_constraints_category.sql`** - Para diagnóstico específico (OPCIONAL)

---

**Status**: ✅ Solução Completa e Atualizada  
**Arquivos Principais**: 
1. `adicionar_colunas_tickets_corrigido.sql` (PRIMEIRO)
2. `corrigir_policy_recursao_users.sql` (SEGUNDO)  
**Última Atualização**: 26/08/2025 19:40  
**Problemas Resolvidos**: Colunas faltantes + Constraints + Policies de recursão infinita
