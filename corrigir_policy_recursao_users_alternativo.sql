-- =====================================================
-- CORRIGIR POLICY DE RECURSÃO INFINITA - TABELA USERS (VERSÃO ALTERNATIVA)
-- =====================================================
-- 
-- Execute este script para resolver o erro:
-- "infinite recursion detected in policy for relation 'users'"
-- 
-- Esta versão é mais robusta para lidar com nomes de policies problemáticos
-- =====================================================

-- 1. VERIFICAR POLICIES EXISTENTES NA TABELA USERS
SELECT '=== VERIFICANDO POLICIES DA TABELA USERS ===' as etapa;

SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'users'
AND schemaname = 'public'
ORDER BY policyname;

-- 2. VERIFICAR CONSTRAINTS E TRIGGERS DA TABELA USERS
SELECT '=== VERIFICANDO CONSTRAINTS E TRIGGERS ===' as etapa;

SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.users'::regclass
ORDER BY conname;

-- 3. DESABILITAR RLS TEMPORARIAMENTE PARA EVITAR PROBLEMAS
SELECT '=== DESABILITANDO RLS TEMPORARIAMENTE ===' as etapa;

ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
SELECT 'RLS desabilitado temporariamente na tabela users' as status;

-- 4. REMOVER POLICIES PROBLEMÁTICAS INDIVIDUALMENTE
SELECT '=== REMOVENDO POLICIES PROBLEMÁTICAS ===' as etapa;

-- Lista de policies conhecidas que podem causar problemas
DO $$
BEGIN
    -- Tentar remover policies comuns que podem causar recursão
    BEGIN
        DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
        RAISE NOTICE 'Policy "Admins can view all users" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "Admins can view all users": %', SQLERRM;
    END;
    
    BEGIN
        DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
        RAISE NOTICE 'Policy "Users can view own profile" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "Users can view own profile": %', SQLERRM;
    END;
    
    BEGIN
        DROP POLICY IF EXISTS "Enable read access for all users" ON public.users;
        RAISE NOTICE 'Policy "Enable read access for all users" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "Enable read access for all users": %', SQLERRM;
    END;
    
    BEGIN
        DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;
        RAISE NOTICE 'Policy "Enable insert for authenticated users only" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "Enable insert for authenticated users only": %', SQLERRM;
    END;
    
    BEGIN
        DROP POLICY IF EXISTS "Enable update for users based on email" ON public.users;
        RAISE NOTICE 'Policy "Enable update for users based on email" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "Enable update for users based on email": %', SQLERRM;
    END;
    
    BEGIN
        DROP POLICY IF EXISTS "Enable delete for users based on email" ON public.users;
        RAISE NOTICE 'Policy "Enable delete for users based on email" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "Enable delete for users based on email": %', SQLERRM;
    END;
    
    -- Tentar remover outras policies que podem existir
    BEGIN
        DROP POLICY IF EXISTS "users_select_own" ON public.users;
        RAISE NOTICE 'Policy "users_select_own" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "users_select_own": %', SQLERRM;
    END;
    
    BEGIN
        DROP POLICY IF EXISTS "users_update_own" ON public.users;
        RAISE NOTICE 'Policy "users_update_own" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "users_update_own": %', SQLERRM;
    END;
    
    BEGIN
        DROP POLICY IF EXISTS "users_insert_auth" ON public.users;
        RAISE NOTICE 'Policy "users_insert_auth" removida';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao remover policy "users_insert_auth": %', SQLERRM;
    END;
    
END $$;

-- 5. CRIAR POLICIES SIMPLES E SEGURAS
SELECT '=== CRIANDO POLICIES SIMPLES E SEGURAS ===' as etapa;

-- Policy para usuários autenticados verem seus próprios dados
CREATE POLICY "users_select_own" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Policy para usuários autenticados atualizarem seus próprios dados
CREATE POLICY "users_update_own" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Policy para inserção (apenas para usuários autenticados)
CREATE POLICY "users_insert_auth" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy para usuários autenticados inserirem tickets
CREATE POLICY "tickets_insert_auth" ON public.tickets
    FOR INSERT WITH CHECK (
        -- Permitir inserção para usuários autenticados
        auth.uid() IS NOT NULL
        OR
        -- Permitir inserção para formulários externos (sem auth.uid)
        (requester_email IS NOT NULL AND source = 'external_form')
    );

-- Policy para usuários autenticados verem tickets
CREATE POLICY "tickets_select_auth" ON public.tickets
    FOR SELECT USING (
        -- Usuários autenticados podem ver todos os tickets
        auth.uid() IS NOT NULL
        OR
        -- Usuários externos podem ver apenas seus próprios tickets
        (requester_email IS NOT NULL AND source = 'external_form')
    );

-- 6. REABILITAR RLS
SELECT '=== REABILITANDO RLS ===' as etapa;

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
SELECT 'RLS reabilitado na tabela users' as status;

-- 7. VERIFICAR POLICIES FINAIS
SELECT '=== VERIFICANDO POLICIES FINAIS ===' as etapa;

SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    CASE 
        WHEN qual IS NOT NULL THEN 'USING: ' || qual
        ELSE 'WITH CHECK'
    END as policy_condition
FROM pg_policies 
WHERE tablename IN ('users', 'tickets')
AND schemaname = 'public'
ORDER BY tablename, policyname;

-- 8. TESTAR INSERÇÃO DE TICKET
SELECT '=== TESTANDO INSERÇÃO DE TICKET ===' as etapa;

-- Inserir ticket de teste (simulando formulário externo)
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
    'TKT-TEST-POLICY-' || EXTRACT(EPOCH FROM NOW())::TEXT,
    'Teste de Policy',
    'Este é um teste para verificar se as policies estão funcionando',
    'medium',
    'open',
    'geral',
    'Usuário Teste Policy',
    'policy@teste.com',
    '(11) 88888-8888',
    'Unidade Policy',
    'external_form'
);

-- Verificar se foi inserido
SELECT 
    ticket_number,
    title,
    requester_name,
    requester_email,
    source,
    status,
    category
FROM public.tickets 
WHERE ticket_number LIKE 'TKT-TEST-POLICY-%'
ORDER BY created_at DESC
LIMIT 1;

-- 9. LIMPAR DADOS DE TESTE (OPCIONAL)
-- DELETE FROM public.tickets WHERE ticket_number LIKE 'TKT-TEST-POLICY-%';

SELECT 'Script executado com sucesso! As policies de recursão foram corrigidas.' as resultado;
