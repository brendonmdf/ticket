-- Script para DESABILITAR RLS temporariamente na tabela tickets
-- Execute este script no SQL Editor do Supabase para permitir atualizações

-- 1. VERIFICAR STATUS ATUAL DO RLS
SELECT 
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'tickets';

-- 2. DESABILITAR RLS
ALTER TABLE public.tickets DISABLE ROW LEVEL SECURITY;

-- 3. VERIFICAR SE FOI DESABILITADO
SELECT 
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'tickets';

-- 4. REMOVER TODAS AS POLÍTICAS RLS (opcional)
-- Descomente se quiser remover todas as políticas:
/*
DROP POLICY IF EXISTS "Usuários autenticados podem ler tickets" ON public.tickets;
DROP POLICY IF EXISTS "Usuários autenticados podem criar tickets" ON public.tickets;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar tickets" ON public.tickets;
DROP POLICY IF EXISTS "Usuários autenticados podem excluir tickets" ON public.tickets;
*/

-- 5. BUSCAR IDS DISPONÍVEIS PARA TESTE
SELECT 
    id,
    ticket_number,
    title,
    status
FROM tickets 
ORDER BY created_at DESC 
LIMIT 3;

-- 6. TESTAR ATUALIZAÇÃO DIRETA (substitua o ID pelo valor real)
-- Descomente e modifique o ID para testar:
/*
UPDATE tickets 
SET status = 'in_progress', updated_at = NOW()
WHERE id = 'SUBSTITUA_PELO_ID_REAL_AQUI'
RETURNING id, ticket_number, status, updated_at;
*/

-- 7. VERIFICAR SE A ATUALIZAÇÃO FUNCIONOU
SELECT 
    id,
    ticket_number,
    title,
    status,
    updated_at
FROM tickets 
ORDER BY updated_at DESC 
LIMIT 3;

-- 8. MENSAGEM DE CONFIRMAÇÃO
SELECT 'RLS desabilitado com sucesso! Agora você pode atualizar tickets.' as status;
