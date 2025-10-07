-- =====================================================
-- DIAGNÓSTICO COMPLETO DO INVENTÁRIO
-- Execute este script para verificar o estado das tabelas
-- =====================================================

-- 1. VERIFICAR SE AS TABELAS EXISTEM
SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('assets', 'asset_categories', 'units', 'asset_movements');

-- 2. VERIFICAR ESTRUTURA DA TABELA ASSETS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'assets'
ORDER BY ordinal_position;

-- 3. VERIFICAR CONSTRAINTS DA TABELA ASSETS
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.assets'::regclass;

-- 4. VERIFICAR DADOS NAS TABELAS
SELECT 'asset_categories' as tabela, COUNT(*) as total FROM asset_categories
UNION ALL
SELECT 'units' as tabela, COUNT(*) as total FROM units
UNION ALL
SELECT 'assets' as tabela, COUNT(*) as total FROM assets
UNION ALL
SELECT 'asset_movements' as tabela, COUNT(*) as total FROM asset_movements;

-- 5. VERIFICAR CATEGORIAS DISPONÍVEIS
SELECT id, name, description FROM asset_categories ORDER BY name;

-- 6. VERIFICAR UNIDADES DISPONÍVEIS
SELECT id, name, code, city, state FROM units ORDER BY name;

-- 7. VERIFICAR SE HÁ PROBLEMAS DE FOREIGN KEY
SELECT 
    'assets.category_id' as campo,
    COUNT(*) as total_assets,
    COUNT(c.id) as categorias_validas,
    COUNT(*) - COUNT(c.id) as problemas
FROM assets a
LEFT JOIN asset_categories c ON a.category_id = c.id

UNION ALL

SELECT 
    'assets.unit_id' as campo,
    COUNT(*) as total_assets,
    COUNT(u.id) as unidades_validas,
    COUNT(*) - COUNT(u.id) as problemas
FROM assets a
LEFT JOIN units u ON a.unit_id = u.id;

-- 8. VERIFICAR CÓDIGOS DUPLICADOS
SELECT code, COUNT(*) as total
FROM assets 
GROUP BY code 
HAVING COUNT(*) > 1;

-- 9. VERIFICAR RLS (Row Level Security)
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('assets', 'asset_categories', 'units', 'asset_movements');

-- 10. VERIFICAR PERMISSÕES DO USUÁRIO ATUAL
SELECT 
    table_name,
    privilege_type
FROM information_schema.table_privileges 
WHERE table_schema = 'public' 
AND table_name IN ('assets', 'asset_categories', 'units', 'asset_movements')
AND grantee = current_user;

-- 11. TESTAR INSERÇÃO SIMPLES
-- Descomente as linhas abaixo para testar inserção
/*
INSERT INTO assets (code, name, category_id, unit_id) 
VALUES ('TEST-001', 'Ativo de Teste', 
        (SELECT id FROM asset_categories LIMIT 1),
        (SELECT id FROM units LIMIT 1))
RETURNING id, code, name;

-- Remover o teste
DELETE FROM assets WHERE code = 'TEST-001';
*/

-- 12. VERIFICAR LOGS DE ERRO (se disponível)
-- Esta consulta pode não funcionar dependendo da configuração
SELECT 
    log_time,
    log_level,
    log_message
FROM pg_stat_statements 
WHERE query LIKE '%assets%'
ORDER BY log_time DESC
LIMIT 10;
