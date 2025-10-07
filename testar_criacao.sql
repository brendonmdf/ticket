-- =====================================================
-- TESTAR CRIAÇÃO DE DADOS NAS TABELAS
-- Execute este script para verificar se as inserções estão funcionando
-- =====================================================

-- 1. TESTAR INSERÇÃO DE CATEGORIA
INSERT INTO asset_categories (name, description, icon, color) 
VALUES ('Teste Categoria', 'Categoria para teste', 'package', 'bg-blue-100 text-blue-800')
ON CONFLICT (name) DO NOTHING;

SELECT '✅ Categoria de teste criada' as resultado;

-- 2. TESTAR INSERÇÃO DE UNIDADE
INSERT INTO units (name, code, city, state) 
VALUES ('Teste Unidade', 'TESTE-UNIDADE', 'São Paulo', 'SP')
ON CONFLICT (code) DO NOTHING;

SELECT '✅ Unidade de teste criada' as resultado;

-- 3. TESTAR INSERÇÃO DE ATIVO
INSERT INTO assets (code, name, model, brand, category_id, unit_id, status) 
VALUES (
  'TESTE-001', 
  'Ativo de Teste', 
  'Modelo Teste', 
  'Marca Teste',
  (SELECT id FROM asset_categories WHERE name = 'Teste Categoria' LIMIT 1),
  (SELECT id FROM units WHERE name = 'Teste Unidade' LIMIT 1),
  'active'
)
ON CONFLICT (code) DO NOTHING;

SELECT '✅ Ativo de teste criado' as resultado;

-- 4. VERIFICAR DADOS INSERIDOS
SELECT '📊 CATEGORIAS:' as info;
SELECT name, description, icon, color FROM asset_categories WHERE name LIKE '%Teste%';

SELECT '🏢 UNIDADES:' as info;
SELECT name, code, city, state, status FROM units WHERE name LIKE '%Teste%';

SELECT '📦 ATIVOS:' as info;
SELECT a.code, a.name, a.model, a.brand, ac.name as categoria, u.name as unidade, a.status
FROM assets a
LEFT JOIN asset_categories ac ON a.category_id = ac.id
LEFT JOIN units u ON a.unit_id = u.id
WHERE a.name LIKE '%Teste%';

-- 5. LIMPAR DADOS DE TESTE
DELETE FROM assets WHERE code = 'TESTE-001';
DELETE FROM units WHERE code = 'TESTE-UNIDADE';
DELETE FROM asset_categories WHERE name = 'Teste Categoria';

SELECT '🧹 Dados de teste removidos' as resultado;
