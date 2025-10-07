-- Script SIMPLES para testar atualização de status
-- Execute este script no SQL Editor do Supabase

-- 1. VERIFICAR SE A TABELA EXISTE
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'tickets'
) as tabela_existe;

-- 2. VERIFICAR ESTRUTURA BÁSICA
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'tickets' 
AND column_name IN ('id', 'status', 'updated_at')
ORDER BY column_name;

-- 3. VERIFICAR SE RLS ESTÁ ATIVO
SELECT 
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'tickets';

-- 4. VERIFICAR POLÍTICAS RLS (se existirem)
SELECT 
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'tickets';

-- 5. VERIFICAR DADOS EXISTENTES
SELECT 
    id,
    ticket_number,
    title,
    status,
    updated_at
FROM tickets 
ORDER BY created_at DESC 
LIMIT 3;

-- 6. TESTAR ATUALIZAÇÃO DIRETA (se RLS estiver desabilitado)
-- Descomente e modifique o ID para testar:
/*
UPDATE tickets 
SET status = 'in_progress', updated_at = NOW()
WHERE id = 'COLE_AQUI_O_ID_DO_TICKET'
RETURNING id, ticket_number, status, updated_at;
*/

-- 7. VERIFICAR TOTAL DE TICKETS
SELECT COUNT(*) as total_tickets FROM tickets;

-- 8. VERIFICAR STATUS DISTINTOS
SELECT 
    status,
    COUNT(*) as quantidade
FROM tickets 
GROUP BY status 
ORDER BY quantidade DESC;
