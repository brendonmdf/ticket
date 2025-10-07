-- =====================================================
-- SCRIPT PARA TESTAR SE AS TABELAS DE INVENTÁRIO EXISTEM
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. VERIFICAR TABELAS EXISTENTES
SELECT 'Verificando tabelas existentes...' as etapa;

SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY table_name;

-- 2. VERIFICAR SE EXISTEM DADOS
SELECT 'Verificando dados existentes...' as etapa;

-- Verificar asset_categories
SELECT 
    'asset_categories' as tabela,
    COUNT(*) as total_registros
FROM public.asset_categories
UNION ALL
SELECT 
    'units' as tabela,
    COUNT(*) as total_registros
FROM public.units
UNION ALL
SELECT 
    'assets' as tabela,
    COUNT(*) as total_registros
FROM public.assets
UNION ALL
SELECT 
    'asset_movements' as tabela,
    COUNT(*) as total_registros
FROM public.asset_movements;

-- 3. VERIFICAR STATUS DO RLS
SELECT 'Verificando status do RLS...' as etapa;

SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN '🔒 ATIVO'
        ELSE '🔓 DESABILITADO'
    END as rls_status
FROM pg_tables 
WHERE tablename IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY tablename;

-- 4. MENSAGEM FINAL
SELECT 
    CASE 
        WHEN COUNT(*) = 4 THEN '✅ Todas as tabelas existem!'
        ELSE '❌ Algumas tabelas estão faltando'
    END as resultado
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('asset_categories', 'assets', 'asset_movements', 'units');
