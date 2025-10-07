-- =====================================================
-- INSERIR DADOS DE EXEMPLO NO INVENTÁRIO
-- Execute este script para testar a funcionalidade
-- =====================================================

-- 1. INSERIR ALGUNS ATIVOS DE EXEMPLO
INSERT INTO assets (code, name, model, brand, category_id, unit_id, status, acquisition_date, purchase_value, serial_number, location_details, notes) VALUES
    ('PC-001', 'Computador Desktop', 'OptiPlex 7090', 'Dell', 
     (SELECT id FROM asset_categories WHERE name = 'Computadores' LIMIT 1),
     (SELECT id FROM units WHERE name = 'Loja 1' LIMIT 1),
     'active', '2024-01-15', 3500.00, 'SN-DELL-001', 'Sala de TI', 'Computador para desenvolvedor'),
     
    ('MON-001', 'Monitor 24"', 'P2419H', 'Dell',
     (SELECT id FROM asset_categories WHERE name = 'Monitores' LIMIT 1),
     (SELECT id FROM units WHERE name = 'Loja 1' LIMIT 1),
     'active', '2024-01-15', 800.00, 'SN-MON-001', 'Sala de TI', 'Monitor principal'),
     
    ('TEC-001', 'Teclado Mecânico', 'K95 RGB', 'Corsair',
     (SELECT id FROM asset_categories WHERE name = 'Periféricos' LIMIT 1),
     (SELECT id FROM units WHERE name = 'Loja 2' LIMIT 1),
     'active', '2024-02-01', 250.00, 'SN-TEC-001', 'Mesa 5', 'Teclado gaming'),
     
    ('CAB-001', 'Cabo de Rede', 'Cat6 10m', 'Genérico',
     (SELECT id FROM asset_categories WHERE name = 'Cabos' LIMIT 1),
     (SELECT id FROM units WHERE name = 'Loja 3' LIMIT 1),
     'active', '2024-01-20', 45.00, 'SN-CAB-001', 'Depósito', 'Cabo para conexão de rede')
ON CONFLICT (code) DO NOTHING;

-- 2. INSERIR ALGUMAS MOVIMENTAÇÕES DE EXEMPLO
INSERT INTO asset_movements (asset_id, action, from_unit_id, to_unit_id, notes) VALUES
    ((SELECT id FROM assets WHERE code = 'PC-001' LIMIT 1), 'Aquisição', 
     NULL, (SELECT id FROM units WHERE name = 'Loja 1' LIMIT 1), 'Compra inicial'),
     
    ((SELECT id FROM assets WHERE code = 'MON-001' LIMIT 1), 'Aquisição',
     NULL, (SELECT id FROM units WHERE name = 'Loja 1' LIMIT 1), 'Compra inicial'),
     
    ((SELECT id FROM assets WHERE code = 'TEC-001' LIMIT 1), 'Transferência',
     (SELECT id FROM units WHERE name = 'Loja 1' LIMIT 1), (SELECT id FROM units WHERE name = 'Loja 2' LIMIT 1), 'Transferido para Loja 2'),
     
    ((SELECT id FROM assets WHERE code = 'CAB-001' LIMIT 1), 'Aquisição',
     NULL, (SELECT id FROM units WHERE name = 'Loja 3' LIMIT 1), 'Compra inicial')
ON CONFLICT DO NOTHING;

-- 3. VERIFICAR DADOS INSERIDOS
SELECT '📊 ATIVOS CRIADOS:' as info;
SELECT a.code, a.name, a.model, a.brand, ac.name as categoria, u.name as unidade, a.status
FROM assets a
LEFT JOIN asset_categories ac ON a.category_id = ac.id
LEFT JOIN units u ON a.unit_id = u.id
ORDER BY a.code;

SELECT '🔄 MOVIMENTAÇÕES CRIADAS:' as info;
SELECT am.action, a.code as ativo, 
       fu.name as de_unidade, tu.name as para_unidade, am.notes
FROM asset_movements am
LEFT JOIN assets a ON am.asset_id = a.id
LEFT JOIN units fu ON am.from_unit_id = fu.id
LEFT JOIN units tu ON am.to_unit_id = tu.id
ORDER BY am.performed_at;

-- 4. RESUMO FINAL
SELECT '✅ DADOS DE EXEMPLO INSERIDOS COM SUCESSO!' as resultado;
SELECT '📊 Total de ativos: ' || COUNT(*) as total_ativos FROM assets;
SELECT '🔄 Total de movimentações: ' || COUNT(*) as total_movimentacoes FROM asset_movements;
