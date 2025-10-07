-- =====================================================
-- TESTAR TABELAS DO INVENTÁRIO
-- Execute este script para verificar se tudo está funcionando
-- =====================================================

-- 1. VERIFICAR SE AS TABELAS EXISTEM
SELECT 'asset_categories' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'asset_categories') 
            THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status;

SELECT 'units' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'units') 
            THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status;

SELECT 'assets' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'assets') 
            THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status;

SELECT 'asset_movements' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'asset_movements') 
            THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status;

-- 2. VERIFICAR RLS (forma correta)
SELECT 'asset_categories' as tabela, 
       CASE WHEN EXISTS (
         SELECT 1 FROM pg_policies WHERE tablename = 'asset_categories'
       ) THEN '🔒 RLS ATIVO' ELSE '🔓 RLS DESABILITADO' END as rls_status;

SELECT 'units' as tabela, 
       CASE WHEN EXISTS (
         SELECT 1 FROM pg_policies WHERE tablename = 'units'
       ) THEN '🔒 RLS ATIVO' ELSE '🔓 RLS DESABILITADO' END as rls_status;

SELECT 'assets' as tabela, 
       CASE WHEN EXISTS (
         SELECT 1 FROM pg_policies WHERE tablename = 'assets'
       ) THEN '🔒 RLS ATIVO' ELSE '🔓 RLS DESABILITADO' END as rls_status;

SELECT 'asset_movements' as tabela, 
       CASE WHEN EXISTS (
         SELECT 1 FROM pg_policies WHERE tablename = 'asset_movements'
       ) THEN '🔒 RLS ATIVO' ELSE '🔓 RLS DESABILITADO' END as rls_status;

-- 3. CONTAR REGISTROS
SELECT 'asset_categories' as tabela, COUNT(*) as total FROM asset_categories
UNION ALL
SELECT 'units' as tabela, COUNT(*) as total FROM units
UNION ALL
SELECT 'assets' as tabela, COUNT(*) as total FROM assets
UNION ALL
SELECT 'asset_movements' as tabela, COUNT(*) as total FROM asset_movements;

-- 4. TESTAR INSERÇÃO DE UNIDADE
INSERT INTO units (name, code, city, state) 
VALUES ('Teste Unidade', 'TESTE-001', 'São Paulo', 'SP')
ON CONFLICT (code) DO NOTHING;

SELECT '✅ Teste de inserção concluído' as resultado;

-- 5. VERIFICAR DADOS
SELECT '📊 CATEGORIAS:' as info;
SELECT name, description, icon, color FROM asset_categories ORDER BY name;

SELECT '🏢 UNIDADES:' as info;
SELECT name, code, city, state, status FROM units ORDER BY name;

-- 6. LIMPAR DADOS DE TESTE
DELETE FROM units WHERE code = 'TESTE-001';
SELECT '🧹 Dados de teste removidos' as resultado;
