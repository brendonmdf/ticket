-- =====================================================
-- VERIFICAR CONSTRAINTS DA COLUNA CATEGORY
-- =====================================================
-- 
-- Execute este script para verificar as constraints da coluna category
-- =====================================================

-- 1. VERIFICAR CONSTRAINTS EXISTENTES NA TABELA TICKETS
SELECT 'Verificando constraints da tabela tickets...' as etapa;

SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.tickets'::regclass
ORDER BY conname;

-- 2. VERIFICAR ESPECIFICAMENTE A CONSTRAINT DE CATEGORY
SELECT 'Verificando constraint de category...' as etapa;

SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.tickets'::regclass
AND pg_get_constraintdef(oid) LIKE '%category%';

-- 3. VERIFICAR VALORES PERMITIDOS NA COLUNA CATEGORY
SELECT 'Verificando valores permitidos na coluna category...' as etapa;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'tickets' 
AND table_schema = 'public'
AND column_name = 'category';

-- 4. VERIFICAR SE EXISTEM DADOS NA TABELA
SELECT 'Verificando dados existentes na tabela tickets...' as etapa;

SELECT 
    id,
    ticket_number,
    title,
    category,
    status,
    priority
FROM public.tickets 
LIMIT 10;

-- 5. VERIFICAR SE EXISTEM OUTRAS TABELAS RELACIONADAS
SELECT 'Verificando tabelas relacionadas...' as etapa;

SELECT 
    table_name,
    table_schema
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%categor%'
ORDER BY table_name;
