-- =====================================================
-- SCRIPT DE DIAGNÓSTICO COMPLETO - FUNÇÃO search_tickets
-- =====================================================
-- 
-- Execute este script no SQL Editor do Supabase para diagnosticar
-- o problema com a função search_tickets()
-- =====================================================

-- 1. VERIFICAR SE AS TABELAS NECESSÁRIAS EXISTEM
SELECT 'VERIFICAÇÃO DE TABELAS' as etapa;

SELECT 
    table_name,
    table_schema,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('tickets', 'users', 'units')
ORDER BY table_name;

-- 2. VERIFICAR SE A FUNÇÃO JÁ EXISTE
SELECT 'VERIFICAÇÃO DE FUNÇÕES EXISTENTES' as etapa;

SELECT 
    routine_name,
    routine_schema,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name = 'search_tickets';

-- 3. VERIFICAR PERMISSÕES DO USUÁRIO ATUAL
SELECT 'VERIFICAÇÃO DE PERMISSÕES' as etapa;

SELECT 
    current_user as usuario_atual,
    current_database() as banco_atual,
    current_schema as schema_atual;

-- 4. VERIFICAR SE O SCHEMA PUBLIC EXISTE
SELECT 'VERIFICAÇÃO DO SCHEMA PUBLIC' as etapa;

SELECT 
    schema_name,
    schema_owner
FROM information_schema.schemata 
WHERE schema_name = 'public';

-- 5. TENTAR CRIAR A FUNÇÃO COM TRATAMENTO DE ERRO
SELECT 'TENTATIVA DE CRIAÇÃO DA FUNÇÃO' as etapa;

-- Criar a função diretamente
CREATE OR REPLACE FUNCTION public.search_tickets(
    p_search TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_priority TEXT DEFAULT NULL,
    p_unit_id UUID DEFAULT NULL,
    p_assignee_id UUID DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    ticket_number TEXT,
    title TEXT,
    status TEXT,
    priority TEXT,
    requester_name TEXT,
    assignee_name TEXT,
    unit_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.ticket_number,
        t.title,
        t.status,
        t.priority,
        ur.full_name as requester_name,
        ass.full_name as assignee_name,
        u.name as unit_name,
        t.created_at
    FROM public.tickets t
    LEFT JOIN public.users ur ON t.requester_id = ur.id
    LEFT JOIN public.users ass ON t.assignee_id = ass.id
    LEFT JOIN public.units u ON t.unit_id = u.id
    WHERE (p_search IS NULL OR 
           t.title ILIKE '%' || p_search || '%' OR 
           t.description ILIKE '%' || p_search || '%')
      AND (p_status IS NULL OR t.status = p_status)
      AND (p_priority IS NULL OR t.priority = p_priority)
      AND (p_unit_id IS NULL OR t.unit_id = p_unit_id)
      AND (p_assignee_id IS NULL OR t.assignee_id = p_assignee_id)
    ORDER BY 
        CASE t.priority
            WHEN 'critical' THEN 1
            WHEN 'high' THEN 2
            WHEN 'medium' THEN 3
            WHEN 'low' THEN 4
        END,
        t.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- 6. VERIFICAR SE A FUNÇÃO FOI CRIADA APÓS A TENTATIVA
SELECT 'VERIFICAÇÃO FINAL' as etapa;

SELECT 
    routine_name,
    routine_schema,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name = 'search_tickets';

-- 7. TESTAR A FUNÇÃO (se foi criada)
SELECT 'TESTE DA FUNÇÃO' as etapa;

-- Verificar se a função existe e testar
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines 
            WHERE routine_schema = 'public' 
            AND routine_name = 'search_tickets'
        ) THEN 'Função existe - testando...'
        ELSE 'Função não existe!'
    END as status;

-- Se a função existir, testar (pode retornar tabela vazia se não houver tickets)
SELECT * FROM public.search_tickets() LIMIT 5;

-- =====================================================
-- DIAGNÓSTICO CONCLUÍDO
-- =====================================================
