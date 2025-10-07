-- =====================================================
-- SCRIPT PARA ADICIONAR COLUNAS FALTANTES NA TABELA TICKETS
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

-- 2. ADICIONAR COLUNAS FALTANTES
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
    
    -- Adicionar coluna category se não existir (caso não tenha sido criada)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'category') THEN
        ALTER TABLE public.tickets ADD COLUMN category TEXT DEFAULT 'geral';
        RAISE NOTICE 'Coluna category adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna category já existe';
    END IF;
END $$;

-- 3. VERIFICAR ESTRUTURA FINAL
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

-- 4. TESTAR INSERÇÃO
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
    category
FROM public.tickets 
WHERE ticket_number LIKE 'TKT-TEST-%'
ORDER BY created_at DESC
LIMIT 1;

-- 5. LIMPAR DADOS DE TESTE (OPCIONAL)
-- DELETE FROM public.tickets WHERE ticket_number LIKE 'TKT-TEST-%';

SELECT 'Script executado com sucesso! As colunas foram adicionadas à tabela tickets.' as resultado;
