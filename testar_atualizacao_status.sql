-- Script para testar a atualização de status dos tickets
-- Execute este script no SQL Editor do Supabase para verificar permissões

-- 1. VERIFICAR ESTRUTURA DA TABELA TICKETS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tickets' 
ORDER BY ordinal_position;

-- 2. VERIFICAR STATUS RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'tickets';

-- 3. VERIFICAR POLÍTICAS RLS
SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'tickets';

-- 4. TESTAR ATUALIZAÇÃO DIRETA (se RLS estiver desabilitado)
-- Descomente as linhas abaixo para testar:
-- UPDATE tickets 
-- SET status = 'in_progress', updated_at = NOW()
-- WHERE id = 'ID_DO_TICKET_AQUI'
-- RETURNING id, status, updated_at;

-- 5. VERIFICAR DADOS EXISTENTES
SELECT 
    id,
    ticket_number,
    title,
    status,
    updated_at
FROM tickets 
ORDER BY created_at DESC 
LIMIT 5;

-- 6. VERIFICAR PERMISSÕES DO USUÁRIO ATUAL
SELECT 
    current_user,
    session_user,
    current_setting('role');

-- 7. TESTAR SELECT (deve funcionar se RLS estiver configurado)
SELECT COUNT(*) as total_tickets FROM tickets;

-- 8. VERIFICAR SE HÁ CONSTRAINTS IMPEDINDO ATUALIZAÇÃO
SELECT 
    conname,
    contype,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'tickets'::regclass;
