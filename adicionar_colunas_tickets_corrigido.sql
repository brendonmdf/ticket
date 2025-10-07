-- =====================================================
-- SCRIPT CORRIGIDO PARA ADICIONAR COLUNAS FALTANTES
-- =====================================================
-- 
-- Execute este script no SQL Editor do Supabase para resolver
-- o erro "Could not find the 'requester_email' column of 'tickets'"
-- =====================================================

-- 1. VERIFICAR ESTRUTURA ATUAL DA TABELA
SELECT 'Verificando estrutura atual da tabela tickets...' as etapa;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tickets' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. VERIFICAR CONSTRAINTS EXISTENTES
SELECT 'Verificando constraints existentes...' as etapa;

SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.tickets'::regclass
ORDER BY conname;

-- 3. CORRIGIR CONSTRAINTS PROBLEMÁTICAS
DO $$
BEGIN
    -- Verificar e corrigir constraint de category
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conrelid = 'public.tickets'::regclass 
        AND conname = 'tickets_category_check'
    ) THEN
        ALTER TABLE public.tickets DROP CONSTRAINT tickets_category_check;
        RAISE NOTICE 'Constraint tickets_category_check removida';
    END IF;
    
    -- Verificar e corrigir constraint de status
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conrelid = 'public.tickets'::regclass 
        AND conname = 'tickets_status_check'
    ) THEN
        ALTER TABLE public.tickets DROP CONSTRAINT tickets_status_check;
        RAISE NOTICE 'Constraint tickets_status_check removida';
    END IF;
    
    -- Verificar e corrigir constraint de priority
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conrelid = 'public.tickets'::regclass 
        AND conname = 'tickets_priority_check'
    ) THEN
        ALTER TABLE public.tickets DROP CONSTRAINT tickets_priority_check;
        RAISE NOTICE 'Constraint tickets_priority_check removida';
    END IF;
    
    -- Adicionar nova constraint de category mais flexível
    ALTER TABLE public.tickets ADD CONSTRAINT tickets_category_check 
    CHECK (category IN ('hardware', 'software', 'network', 'access', 'other', 'geral', 'internet', 'equipamento', 'sistema'));
    RAISE NOTICE 'Nova constraint de category adicionada com valores expandidos';
    
    -- Adicionar nova constraint de status mais flexível
    ALTER TABLE public.tickets ADD CONSTRAINT tickets_status_check 
    CHECK (status IN ('new', 'open', 'in_progress', 'resolved', 'closed', 'cancelled', 'pending'));
    RAISE NOTICE 'Nova constraint de status adicionada com valores expandidos';
    
    -- Adicionar nova constraint de priority mais flexível
    ALTER TABLE public.tickets ADD CONSTRAINT tickets_priority_check 
    CHECK (priority IN ('low', 'medium', 'high', 'critical', 'urgent'));
    RAISE NOTICE 'Nova constraint de priority adicionada com valores expandidos';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao ajustar constraints: %', SQLERRM;
END $$;

-- 4. ADICIONAR COLUNAS FALTANTES
DO $$
BEGIN
    -- Adicionar coluna requester_name se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'requester_name') THEN
        ALTER TABLE public.tickets ADD COLUMN requester_name TEXT;
        RAISE NOTICE 'Coluna requester_name adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna requester_name já existe';
    END IF;
    
    -- Adicionar coluna requester_email se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'requester_email') THEN
        ALTER TABLE public.tickets ADD COLUMN requester_email TEXT;
        RAISE NOTICE 'Coluna requester_email adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna requester_email já existe';
    END IF;
    
    -- Adicionar coluna requester_phone se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'requester_phone') THEN
        ALTER TABLE public.tickets ADD COLUMN requester_phone TEXT;
        RAISE NOTICE 'Coluna requester_phone adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna requester_phone já existe';
    END IF;
    
    -- Adicionar coluna unit_name se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'unit_name') THEN
        ALTER TABLE public.tickets ADD COLUMN unit_name TEXT;
        RAISE NOTICE 'Coluna unit_name adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna unit_name já existe';
    END IF;
    
    -- Adicionar coluna source se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'source') THEN
        ALTER TABLE public.tickets ADD COLUMN source TEXT DEFAULT 'internal';
        RAISE NOTICE 'Coluna source adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna source já existe';
    END IF;
    
    -- Verificar se a coluna category existe e ajustar se necessário
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'category') THEN
        ALTER TABLE public.tickets ADD COLUMN category TEXT DEFAULT 'geral';
        RAISE NOTICE 'Coluna category adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna category já existe';
    END IF;
END $$;

-- 5. VERIFICAR ESTRUTURA FINAL
SELECT 'Verificando estrutura final da tabela tickets...' as etapa;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tickets' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 6. VERIFICAR CONSTRAINTS FINAIS
SELECT 'Verificando constraints finais...' as etapa;

SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.tickets'::regclass
ORDER BY conname;

-- 7. TESTAR INSERÇÃO
SELECT 'Testando inserção de ticket...' as etapa;

-- Inserir ticket de teste
INSERT INTO public.tickets (
    ticket_number,
    title,
    description,
    priority,
    status,
    category,
    requester_name,
    requester_email,
    requester_phone,
    unit_name,
    source
) VALUES (
    'TKT-TEST-' || EXTRACT(EPOCH FROM NOW())::TEXT,
    'Teste de Ticket',
    'Este é um ticket de teste para verificar as colunas',
    'medium',
    'open',
    'geral',
    'Usuário Teste',
    'teste@exemplo.com',
    '(11) 99999-9999',
    'Unidade Teste',
    'external_form'
);

-- Verificar se foi inserido
SELECT 
    ticket_number,
    title,
    requester_name,
    requester_email,
    requester_phone,
    unit_name,
    source,
    category,
    status,
    priority
FROM public.tickets 
WHERE ticket_number LIKE 'TKT-TEST-%'
ORDER BY created_at DESC
LIMIT 1;

-- 8. LIMPAR DADOS DE TESTE (OPCIONAL)
-- DELETE FROM public.tickets WHERE ticket_number LIKE 'TKT-TEST-%';

SELECT 'Script executado com sucesso! As colunas foram adicionadas à tabela tickets.' as resultado;
