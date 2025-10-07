-- =====================================================
-- DIAGNÓSTICO COMPLETO DE CONSTRAINTS - TABELA TICKETS
-- =====================================================
-- 
-- Execute este script para identificar TODAS as constraints
-- que podem estar causando problemas na inserção de tickets
-- =====================================================

-- 1. VERIFICAR TODAS AS CONSTRAINTS DA TABELA TICKETS
SELECT '=== VERIFICANDO TODAS AS CONSTRAINTS ===' as etapa;

SELECT 
    conname as constraint_name,
    contype as constraint_type,
    CASE contype
        WHEN 'c' THEN 'CHECK'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 't' THEN 'TRIGGER'
        ELSE 'OUTRO'
    END as constraint_type_desc,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.tickets'::regclass
ORDER BY contype, conname;

-- 2. VERIFICAR CONSTRAINTS DE CHECK ESPECIFICAMENTE
SELECT '=== VERIFICANDO CONSTRAINTS DE CHECK ===' as etapa;

SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition,
    'POTENCIALMENTE PROBLEMÁTICA' as observacao
FROM pg_constraint 
WHERE conrelid = 'public.tickets'::regclass
AND contype = 'c'
ORDER BY conname;

-- 3. VERIFICAR ESTRUTURA DAS COLUNAS COM CONSTRAINTS
SELECT '=== VERIFICANDO COLUNAS COM CONSTRAINTS ===' as etapa;

SELECT 
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_constraint pc 
            WHERE pc.conrelid = 'public.tickets'::regclass 
            AND pc.contype = 'c'
            AND pg_get_constraintdef(pc.oid) LIKE '%' || c.column_name || '%'
        ) THEN 'TEM CONSTRAINT CHECK'
        ELSE 'SEM CONSTRAINT CHECK'
    END as tem_constraint
FROM information_schema.columns c
WHERE c.table_name = 'tickets' 
AND c.table_schema = 'public'
AND c.column_name IN ('status', 'priority', 'category')
ORDER BY c.column_name;

-- 4. VERIFICAR VALORES ATUAIS NAS COLUNAS COM CONSTRAINTS
SELECT '=== VERIFICANDO VALORES ATUAIS ===' as etapa;

SELECT 
    'status' as coluna,
    status as valor,
    COUNT(*) as quantidade
FROM public.tickets 
GROUP BY status
UNION ALL
SELECT 
    'priority' as coluna,
    priority as valor,
    COUNT(*) as quantidade
FROM public.tickets 
GROUP BY priority
UNION ALL
SELECT 
    'category' as coluna,
    category as valor,
    COUNT(*) as quantidade
FROM public.tickets 
GROUP BY category
ORDER BY coluna, valor;

-- 5. VERIFICAR SE EXISTEM DADOS NA TABELA
SELECT '=== VERIFICANDO DADOS EXISTENTES ===' as etapa;

SELECT 
    COUNT(*) as total_tickets,
    COUNT(CASE WHEN status IS NOT NULL THEN 1 END) as tickets_com_status,
    COUNT(CASE WHEN priority IS NOT NULL THEN 1 END) as tickets_com_priority,
    COUNT(CASE WHEN category IS NOT NULL THEN 1 END) as tickets_com_category
FROM public.tickets;

-- 6. SUGESTÃO DE VALORES PARA NOVAS CONSTRAINTS
SELECT '=== SUGESTÃO DE VALORES PARA CONSTRAINTS ===' as etapa;

SELECT 
    'status' as coluna,
    'new, open, in_progress, resolved, closed, cancelled, pending' as valores_sugeridos,
    'Incluir "open" para formulários externos' as observacao
UNION ALL
SELECT 
    'priority' as coluna,
    'low, medium, high, critical, urgent' as valores_sugeridos,
    'Incluir "urgent" para casos especiais' as observacao
UNION ALL
SELECT 
    'category' as coluna,
    'hardware, software, network, access, other, geral, internet, equipamento, sistema' as valores_sugeridos,
    'Incluir "geral" para formulários externos' as observacao;

-- 7. VERIFICAR SE EXISTEM OUTRAS TABELAS RELACIONADAS
SELECT '=== VERIFICANDO TABELAS RELACIONADAS ===' as etapa;

SELECT 
    table_name,
    table_schema,
    'Possível tabela de referência' as observacao
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('ticket_categories', 'ticket_statuses', 'ticket_priorities')
ORDER BY table_name;

-- 8. RESUMO FINAL
SELECT '=== RESUMO FINAL ===' as etapa;

SELECT 
    'Para resolver o problema, execute o script:' as instrucao,
    'adicionar_colunas_tickets_corrigido.sql' as script_recomendado,
    'Este script irá:' as acao,
    '1. Remover constraints problemáticas' as passo1,
    '2. Adicionar novas constraints flexíveis' as passo2,
    '3. Adicionar colunas faltantes' as passo3,
    '4. Testar inserção de ticket' as passo4;
