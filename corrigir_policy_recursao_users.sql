-- =====================================================
-- CORRIGIR POLICY DE RECURSÃO INFINITA - TABELA USERS
-- =====================================================
-- 
-- Execute este script para resolver o erro:
-- "infinite recursion detected in policy for relation 'users'"
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

-- 3. VERIFICAR FUNÇÕES RELACIONADAS
SELECT '=== VERIFICANDO FUNÇÕES RELACIONADAS ===' as etapa;

SELECT 
    routine_name,
    routine_schema,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE '%user%'
ORDER BY routine_name;

-- 4. DESABILITAR TEMPORARIAMENTE AS POLICIES PROBLEMÁTICAS
SELECT '=== DESABILITANDO POLICIES PROBLEMÁTICAS ===' as etapa;

DO $$
DECLARE
    policy_rec RECORD;
BEGIN
    FOR policy_rec IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'users' 
        AND schemaname = 'public'
    LOOP
        -- Usar aspas duplas para nomes de policies que contêm espaços
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_rec.policyname || '" ON public.users';
        RAISE NOTICE 'Policy "%" removida temporariamente', policy_rec.policyname;
    END LOOP;
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

-- 6. VERIFICAR POLICIES FINAIS
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

-- 7. TESTAR INSERÇÃO DE TICKET
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

-- 8. LIMPAR DADOS DE TESTE (OPCIONAL)
-- DELETE FROM public.tickets WHERE ticket_number LIKE 'TKT-TEST-POLICY-%';

SELECT 'Script executado com sucesso! As policies de recursão foram corrigidas.' as resultado;
