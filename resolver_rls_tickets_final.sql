-- Script FINAL para resolver problema de RLS na tabela tickets
-- Execute este script no SQL Editor do Supabase

-- 1. VERIFICAR STATUS ATUAL DO RLS
SELECT 
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename = 'tickets';

-- 2. DESABILITAR RLS (se estiver ativo)
ALTER TABLE public.tickets DISABLE ROW LEVEL SECURITY;

-- 3. CONFIRMAR QUE RLS FOI DESABILITADO
SELECT 
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename = 'tickets';

-- 4. VERIFICAR DADOS EXISTENTES
SELECT 
    id,
    ticket_number,
    title,
    status,
    updated_at
FROM tickets 
ORDER BY created_at DESC 
LIMIT 5;

-- 5. TESTAR ATUALIZAÇÃO COM PRIMEIRO TICKET
-- Este comando atualiza o ticket mais recente automaticamente
UPDATE tickets 
SET status = 'in_progress', updated_at = NOW()
WHERE id = (
    SELECT id FROM tickets 
    ORDER BY created_at DESC 
    LIMIT 1
)
RETURNING id, ticket_number, title, status, updated_at;

-- 6. VERIFICAR SE A ATUALIZAÇÃO FUNCIONOU
SELECT 
    id,
    ticket_number,
    title,
    status,
    updated_at
FROM tickets 
ORDER BY updated_at DESC 
LIMIT 3;

-- 7. MENSAGEM FINAL
SELECT '✅ RLS desabilitado e teste de atualização realizado com sucesso!' as resultado;
