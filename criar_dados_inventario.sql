-- =====================================================
-- SCRIPT PARA CRIAR DADOS REAIS DO INVENTÁRIO
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. VERIFICAR SE AS TABELAS EXISTEM
SELECT 'Verificando tabelas de inventário...' as etapa;

SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY table_name;

-- 2. CRIAR CATEGORIAS DE ATIVOS (se não existirem)
INSERT INTO public.asset_categories (name, description, icon, color) VALUES
    ('Computadores', 'Desktops, notebooks e workstations', 'computer', 'bg-blue-100 text-blue-800'),
    ('Monitores', 'Monitores e displays', 'monitor', 'bg-green-100 text-green-800'),
    ('Periféricos', 'Teclados, mouses e outros acessórios', 'keyboard', 'bg-purple-100 text-purple-800'),
    ('Cabos', 'Cabos de rede, energia e dados', 'cable', 'bg-orange-100 text-orange-800'),
    ('Câmeras', 'Câmeras de segurança e webcams', 'camera', 'bg-red-100 text-red-800'),
    ('Leitores', 'Leitores de código de barras e RFID', 'barcode', 'bg-indigo-100 text-indigo-800')
ON CONFLICT (name) DO NOTHING;

-- 3. CRIAR UNIDADES/LOJAS (se não existirem)
INSERT INTO public.units (name, code, address, city, state, status) VALUES
    ('Loja Centro', 'LC001', 'Rua das Flores, 123', 'São Paulo', 'SP', 'active'),
    ('Loja Norte', 'LN001', 'Av. Paulista, 456', 'São Paulo', 'SP', 'active'),
    ('Loja Sul', 'LS001', 'Rua Augusta, 789', 'São Paulo', 'SP', 'active'),
    ('Loja Leste', 'LL001', 'Av. Brigadeiro Faria Lima, 321', 'São Paulo', 'SP', 'active'),
    ('Loja Oeste', 'LO001', 'Rua Oscar Freire, 654', 'São Paulo', 'SP', 'active')
ON CONFLICT (code) DO NOTHING;

-- 4. INSERIR ATIVOS REAIS NO INVENTÁRIO
INSERT INTO public.assets (code, name, model, brand, category_id, unit_id, responsible_id, status, acquisition_date, purchase_value, serial_number, location_details, notes) VALUES
    -- Computadores
    ('INV-PC-001', 'Desktop Dell OptiPlex 7090', 'OptiPlex 7090', 'Dell', 
     (SELECT id FROM public.asset_categories WHERE name = 'Computadores'),
     (SELECT id FROM public.units WHERE code = 'LC001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-03-15', 3500.00, 'SN-DELL-001', 'Sala TI - 2º Andar', 'Equipamento principal da TI'),
    
    ('INV-PC-002', 'Notebook HP ProBook 450', 'ProBook 450 G8', 'HP',
     (SELECT id FROM public.asset_categories WHERE name = 'Computadores'),
     (SELECT id FROM public.units WHERE code = 'LN001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-05-20', 4200.00, 'SN-HP-001', 'Escritório Gerencial', 'Notebook para gerentes'),
    
    ('INV-PC-003', 'Workstation Lenovo ThinkStation', 'ThinkStation P350', 'Lenovo',
     (SELECT id FROM public.asset_categories WHERE name = 'Computadores'),
     (SELECT id FROM public.units WHERE code = 'LS001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-07-10', 5800.00, 'SN-LENOVO-001', 'Sala de Design', 'Workstation para designers'),
    
    -- Monitores
    ('INV-MON-001', 'Monitor LG 24ML600', '24ML600', 'LG',
     (SELECT id FROM public.asset_categories WHERE name = 'Monitores'),
     (SELECT id FROM public.units WHERE code = 'LC001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-02-10', 850.00, 'SN-LG-001', 'Sala TI - 2º Andar', 'Monitor principal'),
    
    ('INV-MON-002', 'Monitor Samsung 27" Curvo', 'LC27F390FHLXZD', 'Samsung',
     (SELECT id FROM public.asset_categories WHERE name = 'Monitores'),
     (SELECT id FROM public.units WHERE code = 'LN001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-04-15', 1200.00, 'SN-SAMSUNG-001', 'Escritório Gerencial', 'Monitor curvo para apresentações'),
    
    -- Periféricos
    ('INV-PER-001', 'Kit Teclado e Mouse Logitech', 'MK270', 'Logitech',
     (SELECT id FROM public.asset_categories WHERE name = 'Periféricos'),
     (SELECT id FROM public.units WHERE code = 'LS001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-04-12', 180.00, 'SN-LOGITECH-001', 'Sala de Design', 'Kit wireless'),
    
    ('INV-PER-002', 'Impressora HP LaserJet Pro', 'LaserJet Pro M404n', 'HP',
     (SELECT id FROM public.asset_categories WHERE name = 'Periféricos'),
     (SELECT id FROM public.units WHERE code = 'LC001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-01-20', 1200.00, 'SN-HP-002', 'Sala de Impressão', 'Impressora principal'),
    
    -- Cabos
    ('INV-CAB-001', 'Cabo de Rede Cat6', 'Cat6 UTP 100m', 'Genérico',
     (SELECT id FROM public.asset_categories WHERE name = 'Cabos'),
     (SELECT id FROM public.units WHERE code = 'LC001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-06-01', 150.00, 'CAB-NET-001', 'Depósito de Cabos', 'Cabo para instalação de rede'),
    
    ('INV-CAB-002', 'Cabo HDMI 2.0', 'HDMI 2.0 3m', 'Genérico',
     (SELECT id FROM public.asset_categories WHERE name = 'Cabos'),
     (SELECT id FROM public.units WHERE code = 'LN001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-08-15', 45.00, 'CAB-HDMI-001', 'Depósito de Cabos', 'Cabo para apresentações'),
    
    -- Câmeras
    ('INV-CAM-001', 'Câmera IP Hikvision', 'DS-2CD2142FWD-I', 'Hikvision',
     (SELECT id FROM public.asset_categories WHERE name = 'Câmeras'),
     (SELECT id FROM public.units WHERE code = 'LC001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-09-01', 450.00, 'SN-HIKVISION-001', 'Entrada Principal', 'Câmera de segurança'),
    
    -- Leitores
    ('INV-LEI-001', 'Leitor de Código de Barras', 'Honeywell 1900', 'Honeywell',
     (SELECT id FROM public.asset_categories WHERE name = 'Leitores'),
     (SELECT id FROM public.units WHERE code = 'LC001'),
     (SELECT id FROM public.users LIMIT 1), 'active', '2023-10-10', 320.00, 'SN-HONEYWELL-001', 'Sala de Estoque', 'Leitor para controle de estoque')
ON CONFLICT (code) DO NOTHING;

-- 5. INSERIR HISTÓRICO DE MOVIMENTAÇÃO
INSERT INTO public.asset_movements (asset_id, action, from_unit_id, to_unit_id, from_responsible_id, to_responsible_id, notes, performed_by) VALUES
    -- Movimentações para PC-001
    ((SELECT id FROM public.assets WHERE code = 'INV-PC-001'), 'acquisition', NULL, (SELECT id FROM public.units WHERE code = 'LC001'), NULL, (SELECT id FROM public.users LIMIT 1), 'Aquisição inicial do equipamento', (SELECT id FROM public.users LIMIT 1)),
    ((SELECT id FROM public.assets WHERE code = 'INV-PC-001'), 'maintenance', (SELECT id FROM public.units WHERE code = 'LC001'), (SELECT id FROM public.units WHERE code = 'LC001'), (SELECT id FROM public.users LIMIT 1), (SELECT id FROM public.users LIMIT 1), 'Manutenção preventiva', (SELECT id FROM public.users LIMIT 1)),
    
    -- Movimentações para PC-002
    ((SELECT id FROM public.assets WHERE code = 'INV-PC-002'), 'acquisition', NULL, (SELECT id FROM public.units WHERE code = 'LN001'), NULL, (SELECT id FROM public.users LIMIT 1), 'Aquisição para gerentes', (SELECT id FROM public.users LIMIT 1)),
    
    -- Movimentações para MON-001
    ((SELECT id FROM public.assets WHERE code = 'INV-MON-001'), 'acquisition', NULL, (SELECT id FROM public.units WHERE code = 'LC001'), NULL, (SELECT id FROM public.users LIMIT 1), 'Aquisição do monitor principal', (SELECT id FROM public.users LIMIT 1)),
    ((SELECT id FROM public.assets WHERE code = 'INV-MON-001'), 'maintenance', (SELECT id FROM public.units WHERE code = 'LC001'), (SELECT id FROM public.units WHERE code = 'LC001'), (SELECT id FROM public.users LIMIT 1), (SELECT id FROM public.users LIMIT 1), 'Limpeza e calibração', (SELECT id FROM public.users LIMIT 1))
ON CONFLICT DO NOTHING;

-- 6. VERIFICAR DADOS INSERIDOS
SELECT 'Verificando dados inseridos...' as etapa;

-- Contar ativos por categoria
SELECT 
    ac.name as categoria,
    COUNT(a.id) as total_ativos,
    COUNT(CASE WHEN a.status = 'active' THEN 1 END) as ativos_ativos,
    COUNT(CASE WHEN a.status = 'maintenance' THEN 1 END) as em_manutencao
FROM public.asset_categories ac
LEFT JOIN public.assets a ON ac.id = a.category_id
GROUP BY ac.id, ac.name
ORDER BY total_ativos DESC;

-- Contar ativos por unidade
SELECT 
    u.name as unidade,
    COUNT(a.id) as total_ativos,
    COUNT(CASE WHEN a.status = 'active' THEN 1 END) as ativos_ativos
FROM public.units u
LEFT JOIN public.assets a ON u.id = a.unit_id
GROUP BY u.id, u.name
ORDER BY total_ativos DESC;

-- 7. MENSAGEM DE CONFIRMAÇÃO
SELECT '✅ Dados do inventário criados com sucesso!' as resultado;
SELECT '📊 Total de ativos inseridos: ' || COUNT(*) as total FROM public.assets;
