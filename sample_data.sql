-- =====================================================
-- DADOS DE EXEMPLO PARA O SISTEMA DE GESTÃO DE TI
-- Execute este script APÓS executar o script principal
-- =====================================================

-- =====================================================
-- 1. INSERIR USUÁRIOS DE EXEMPLO
-- =====================================================

-- IMPORTANTE: Primeiro você deve criar os usuários no Supabase Auth
-- Vá para Authentication > Users no Supabase Dashboard e crie os usuários:
-- 1. admin@empresa.com (senha: senha123)
-- 2. gerente@empresa.com (senha: senha123)  
-- 3. tecnico@empresa.com (senha: senha123)
-- 4. usuario@empresa.com (senha: senha123)
-- 5. ana@empresa.com (senha: senha123)

-- Depois de criar os usuários no Auth, execute este script para criar os perfis
-- NOTA: Substitua os UUIDs pelos IDs reais dos usuários criados no Auth

-- Para obter os UUIDs, execute no SQL Editor:
-- SELECT id, email FROM auth.users WHERE email IN ('admin@empresa.com', 'gerente@empresa.com', 'tecnico@empresa.com', 'usuario@empresa.com', 'ana@empresa.com');

-- Exemplo (substitua pelos UUIDs reais):
-- INSERT INTO public.users (id, email, full_name, role, department, phone) VALUES
-- ('UUID_REAL_DO_ADMIN', 'admin@empresa.com', 'Administrador Sistema', 'admin', 'TI', '+55 11 99999-0001'),
-- ('UUID_REAL_DO_GERENTE', 'gerente@empresa.com', 'Maria Gerente', 'manager', 'TI', '+55 11 99999-0002'),
-- ('UUID_REAL_DO_TECNICO', 'tecnico@empresa.com', 'João Técnico', 'technician', 'TI', '+55 11 99999-0003'),
-- ('UUID_REAL_DO_USUARIO', 'usuario@empresa.com', 'Pedro Usuário', 'user', 'Vendas', '+55 11 99999-0004'),
-- ('UUID_REAL_DA_ANA', 'ana@empresa.com', 'Ana Silva', 'user', 'Financeiro', '+55 11 99999-0005')
-- ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. INSERIR UNIDADES/LOJAS
-- =====================================================

-- NOTA: Substitua os UUIDs pelos IDs reais dos usuários criados no Auth
-- Para obter os UUIDs, execute: SELECT id, email FROM auth.users WHERE email IN ('admin@empresa.com', 'gerente@empresa.com');

INSERT INTO public.units (name, code, address, city, state, zip_code, phone, manager_id, status) VALUES
('Loja Centro', 'LC001', 'Rua das Flores, 123', 'São Paulo', 'SP', '01234-567', '+55 11 3333-0001', NULL, 'active'),
('Loja Norte', 'LN001', 'Av. Paulista, 456', 'São Paulo', 'SP', '01310-000', '+55 11 3333-0002', NULL, 'active'),
('Loja Sul', 'LS001', 'Rua Augusta, 789', 'São Paulo', 'SP', '01212-000', '+55 11 3333-0003', NULL, 'active'),
('Loja Leste', 'LL001', 'Av. Brigadeiro Faria Lima, 1000', 'São Paulo', 'SP', '01452-000', '+55 11 3333-0004', NULL, 'active'),
('Escritório Central', 'EC001', 'Av. Engenheiro Caetano Álvares, 500', 'São Paulo', 'SP', '02516-000', '+55 11 3333-0005', NULL, 'active'),
('Depósito', 'DEP001', 'Rua do Comércio, 200', 'São Paulo', 'SP', '01001-000', '+55 11 3333-0006', NULL, 'active')
ON CONFLICT (code) DO NOTHING;

-- Depois de inserir os usuários, atualize os manager_id das unidades:
-- UPDATE public.units SET manager_id = (SELECT id FROM public.users WHERE email = 'gerente@empresa.com') WHERE code IN ('LC001', 'LN001', 'LS001', 'LL001');
-- UPDATE public.units SET manager_id = (SELECT id FROM public.users WHERE email = 'admin@empresa.com') WHERE code IN ('EC001', 'DEP001');

-- =====================================================
-- 3. INSERIR ATIVOS DE EXEMPLO
-- =====================================================

-- Computadores
-- NOTA: Substitua os UUIDs pelos IDs reais dos usuários criados no Auth
INSERT INTO public.assets (code, name, model, brand, category_id, unit_id, responsible_id, status, acquisition_date, warranty_expiry, purchase_value, serial_number, specifications) VALUES
('INV-PC-001', 'Desktop Dell OptiPlex 7090', 'OptiPlex 7090', 'Dell', 
 (SELECT id FROM public.asset_categories WHERE name = 'Computadores'),
 (SELECT id FROM public.units WHERE code = 'LC001'),
 NULL, 'active', '2023-03-15', '2026-03-15', 3500.00, 'DL789456123', '{"cpu": "Intel i7-10700", "ram": "16GB", "storage": "512GB SSD"}'),

('INV-PC-002', 'Notebook HP ProBook 450 G8', 'ProBook 450 G8', 'HP',
 (SELECT id FROM public.asset_categories WHERE name = 'Computadores'),
 (SELECT id FROM public.units WHERE code = 'LN001'),
 NULL, 'active', '2023-05-20', '2026-05-20', 4200.00, 'HP456789123', '{"cpu": "Intel i5-10210U", "ram": "8GB", "storage": "256GB SSD"}'),

('INV-PC-003', 'Desktop Lenovo ThinkCentre M90t', 'ThinkCentre M90t', 'Lenovo',
 (SELECT id FROM public.asset_categories WHERE name = 'Computadores'),
 (SELECT id FROM public.units WHERE code = 'LS001'),
 NULL, 'active', '2023-02-10', '2026-02-10', 3200.00, 'LN321654987', '{"cpu": "Intel i5-10400", "ram": "8GB", "storage": "1TB HDD"}')
ON CONFLICT (code) DO NOTHING;

-- Depois de inserir os usuários, atualize os responsible_id dos ativos:
-- UPDATE public.assets SET responsible_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE code LIKE 'INV-PC-%';

-- Monitores
INSERT INTO public.assets (code, name, model, brand, category_id, unit_id, responsible_id, status, acquisition_date, warranty_expiry, purchase_value, serial_number, specifications) VALUES
('INV-MON-001', 'Monitor LG 24ML600', '24ML600', 'LG',
 (SELECT id FROM public.asset_categories WHERE name = 'Monitores'),
 (SELECT id FROM public.units WHERE code = 'LC001'),
 NULL, 'active', '2023-02-10', '2026-02-10', 800.00, 'LG147258369', '{"size": "24\"", "resolution": "1920x1080", "panel": "IPS"}'),

('INV-MON-002', 'Monitor Samsung 27" Curvo', 'LC27F390FHLXZD', 'Samsung',
 (SELECT id FROM public.asset_categories WHERE name = 'Monitores'),
 (SELECT id FROM public.units WHERE code = 'LN001'),
 NULL, 'active', '2023-04-15', '2026-04-15', 1200.00, 'SM963852741', '{"size": "27\"", "resolution": "1920x1080", "panel": "VA", "curved": true}')
ON CONFLICT (code) DO NOTHING;

-- Depois de inserir os usuários, atualize os responsible_id dos monitores:
-- UPDATE public.assets SET responsible_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE code LIKE 'INV-MON-%';

-- Periféricos
INSERT INTO public.assets (code, name, model, brand, category_id, unit_id, responsible_id, status, acquisition_date, warranty_expiry, purchase_value, serial_number, specifications) VALUES
('INV-PER-001', 'Kit Teclado e Mouse Logitech MK270', 'MK270', 'Logitech',
 (SELECT id FROM public.asset_categories WHERE name = 'Periféricos'),
 (SELECT id FROM public.units WHERE code = 'LS001'),
 NULL, 'active', '2023-04-12', '2025-04-12', 150.00, 'LG951753852', '{"connection": "Wireless 2.4GHz", "battery_life": "12 months"}'),

('INV-PER-002', 'Impressora HP LaserJet Pro M404n', 'LaserJet Pro M404n', 'HP',
 (SELECT id FROM public.asset_categories WHERE name = 'Periféricos'),
 (SELECT id FROM public.units WHERE code = 'LC001'),
 NULL, 'active', '2023-01-20', '2026-01-20', 1800.00, 'HP753951456', '{"type": "Laser", "speed": "40 ppm", "network": true}')
ON CONFLICT (code) DO NOTHING;

-- Depois de inserir os usuários, atualize os responsible_id dos periféricos:
-- UPDATE public.assets SET responsible_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE code LIKE 'INV-PER-%';

-- =====================================================
-- 4. INSERIR TICKETS DE EXEMPLO
-- =====================================================

-- NOTA: Os tickets serão criados depois que os usuários estiverem na tabela users
-- Por enquanto, vamos criar tickets sem usuários específicos
INSERT INTO public.tickets (ticket_number, title, description, status, priority, category, requester_id, assignee_id, unit_id, asset_id, estimated_hours, due_date) VALUES
('TKT-000001', 'Impressora não funciona', 'A impressora HP LaserJet não está respondendo aos comandos de impressão. Aparece erro de papel', 'in_progress', 'high', 'hardware',
 NULL, NULL, (SELECT id FROM public.units WHERE code = 'LC001'),
 (SELECT id FROM public.assets WHERE code = 'INV-PER-002'), 2, NOW() + INTERVAL '2 days'),

('TKT-000002', 'Internet lenta na Loja Norte', 'Conexão com internet está muito lenta, dificultando o trabalho da equipe de vendas', 'new', 'medium', 'network',
 NULL, NULL, (SELECT id FROM public.units WHERE code = 'LN001'), NULL, 4, NOW() + INTERVAL '3 days'),

('TKT-000003', 'Software ERP travando', 'O sistema ERP está travando constantemente durante o uso, principalmente ao gerar relatórios', 'resolved', 'low', 'software',
 NULL, NULL, (SELECT id FROM public.units WHERE code = 'LC001'), NULL, 3, NOW() + INTERVAL '1 day'),

('TKT-000004', 'Acesso negado ao sistema', 'Não consigo acessar o sistema de vendas com minhas credenciais. Senha foi alterada recentemente', 'new', 'high', 'access',
 NULL, NULL, (SELECT id FROM public.units WHERE code = 'LS001'), NULL, 1, NOW() + INTERVAL '1 day'),

('TKT-000005', 'Monitor com manchas', 'O monitor da estação de trabalho está apresentando manchas escuras na tela', 'new', 'medium', 'hardware',
 NULL, NULL, (SELECT id FROM public.units WHERE code = 'LC001'),
 (SELECT id FROM public.assets WHERE code = 'INV-MON-001'), 2, NOW() + INTERVAL '5 days')
ON CONFLICT (ticket_number) DO NOTHING;

-- Depois de inserir os usuários, atualize os tickets com os IDs reais:
-- UPDATE public.tickets SET requester_id = (SELECT id FROM public.users WHERE email = 'usuario@empresa.com') WHERE ticket_number = 'TKT-000001';
-- UPDATE public.tickets SET assignee_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE ticket_number = 'TKT-000001';
-- UPDATE public.tickets SET requester_id = (SELECT id FROM public.users WHERE email = 'ana@empresa.com') WHERE ticket_number = 'TKT-000002';
-- UPDATE public.tickets SET assignee_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE ticket_number = 'TKT-000002';
-- UPDATE public.tickets SET requester_id = (SELECT id FROM public.users WHERE email = 'usuario@empresa.com') WHERE ticket_number = 'TKT-000003';
-- UPDATE public.tickets SET assignee_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE ticket_number = 'TKT-000003';
-- UPDATE public.tickets SET requester_id = (SELECT id FROM public.users WHERE email = 'ana@empresa.com') WHERE ticket_number = 'TKT-000004';
-- UPDATE public.tickets SET assignee_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE ticket_number = 'TKT-000004';
-- UPDATE public.tickets SET requester_id = (SELECT id FROM public.users WHERE email = 'usuario@empresa.com') WHERE ticket_number = 'TKT-000005';
-- UPDATE public.tickets SET assignee_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE ticket_number = 'TKT-000005';

-- =====================================================
-- 5. INSERIR COMENTÁRIOS NOS TICKETS
-- =====================================================

-- NOTA: Os comentários serão criados depois que os usuários estiverem na tabela users
-- Por enquanto, vamos criar comentários sem usuários específicos
INSERT INTO public.ticket_comments (ticket_id, user_id, comment, is_internal) VALUES
((SELECT id FROM public.tickets WHERE ticket_number = 'TKT-000001'),
 NULL, 'Verificando drivers da impressora e conexão de rede', false),

((SELECT id FROM public.tickets WHERE ticket_number = 'TKT-000001'),
 NULL, 'Problema persiste mesmo após reiniciar a impressora', false),

((SELECT id FROM public.tickets WHERE ticket_number = 'TKT-000003'),
 NULL, 'Atualização do sistema aplicada com sucesso', false),

((SELECT id FROM public.tickets WHERE ticket_number = 'TKT-000003'),
 NULL, 'Confirmado funcionamento normal após a atualização', false)
ON CONFLICT DO NOTHING;

-- Depois de inserir os usuários, atualize os comentários com os IDs reais:
-- UPDATE public.ticket_comments SET user_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE comment LIKE 'Verificando drivers%';
-- UPDATE public.ticket_comments SET user_id = (SELECT id FROM public.users WHERE email = 'usuario@empresa.com') WHERE comment LIKE 'Problema persiste%';
-- UPDATE public.ticket_comments SET user_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE comment LIKE 'Atualização do sistema%';
-- UPDATE public.ticket_comments SET user_id = (SELECT id FROM public.users WHERE email = 'usuario@empresa.com') WHERE comment LIKE 'Confirmado funcionamento%';

-- =====================================================
-- 6. INSERIR HISTÓRICO DE STATUS DOS TICKETS
-- =====================================================

-- NOTA: O histórico será criado depois que os usuários estiverem na tabela users
-- Por enquanto, vamos criar histórico sem usuários específicos
INSERT INTO public.ticket_status_history (ticket_id, old_status, new_status, changed_by, notes) VALUES
((SELECT id FROM public.tickets WHERE ticket_number = 'TKT-000001'), 'new', 'in_progress',
 NULL, 'Ticket assumido para análise'),

((SELECT id FROM public.tickets WHERE ticket_number = 'TKT-000003'), 'in_progress', 'resolved',
 NULL, 'Problema resolvido com atualização do sistema')
ON CONFLICT DO NOTHING;

-- Depois de inserir os usuários, atualize o histórico com os IDs reais:
-- UPDATE public.ticket_status_history SET changed_by = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE notes LIKE 'Ticket assumido%';
-- UPDATE public.ticket_status_history SET changed_by = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE notes LIKE 'Problema resolvido%';

-- =====================================================
-- 7. INSERIR MONITORAMENTO DE REDE
-- =====================================================

INSERT INTO public.network_monitoring (unit_id, ip_address, hostname, status, uptime_percentage, last_ping_ms, vpn_status, services, last_check) VALUES
((SELECT id FROM public.units WHERE code = 'LC001'), '192.168.1.100', 'loja-centro-dc01', 'online', 99.9, 15, 'connected', '["Web", "Email", "Database", "File Server"]', NOW()),

((SELECT id FROM public.units WHERE code = 'LN001'), '192.168.1.101', 'loja-norte-dc01', 'online', 99.7, 22, 'connected', '["Web", "Email", "Database"]', NOW()),

((SELECT id FROM public.units WHERE code = 'LS001'), '192.168.1.102', 'loja-sul-dc01', 'offline', 0.0, NULL, 'disconnected', '["Web", "Email"]', NOW() - INTERVAL '3 minutes'),

((SELECT id FROM public.units WHERE code = 'LL001'), '192.168.1.103', 'loja-leste-dc01', 'online', 99.8, 18, 'connected', '["Web", "Email", "Database", "File Server", "Backup"]', NOW()),

((SELECT id FROM public.units WHERE code = 'EC001'), '192.168.1.104', 'escritorio-central-dc01', 'online', 99.9, 5, 'connected', '["Web", "Email", "Database", "File Server", "Backup", "DNS", "DHCP"]', NOW()),

((SELECT id FROM public.units WHERE code = 'DEP001'), '192.168.1.105', 'deposito-dc01', 'online', 99.5, 35, 'connected', '["Web", "Email"]', NOW())
ON CONFLICT DO NOTHING;

-- =====================================================
-- 8. INSERIR HISTÓRICO DE STATUS DA REDE
-- =====================================================

INSERT INTO public.network_status_history (monitoring_id, status, ping_ms, uptime_percentage, vpn_status, recorded_at) VALUES
((SELECT id FROM public.network_monitoring WHERE hostname = 'loja-centro-dc01'), 'online', 15, 99.9, 'connected', NOW() - INTERVAL '30 minutes'),
((SELECT id FROM public.network_monitoring WHERE hostname = 'loja-centro-dc01'), 'online', 18, 99.9, 'connected', NOW() - INTERVAL '1 hour'),

((SELECT id FROM public.network_monitoring WHERE hostname = 'loja-norte-dc01'), 'online', 22, 99.7, 'connected', NOW() - INTERVAL '30 minutes'),
((SELECT id FROM public.network_monitoring WHERE hostname = 'loja-norte-dc01'), 'online', 25, 99.7, 'connected', NOW() - INTERVAL '1 hour'),

((SELECT id FROM public.network_monitoring WHERE hostname = 'loja-sul-dc01'), 'offline', NULL, 0.0, 'disconnected', NOW() - INTERVAL '30 minutes'),
((SELECT id FROM public.network_monitoring WHERE hostname = 'loja-sul-dc01'), 'offline', NULL, 0.0, 'disconnected', NOW() - INTERVAL '1 hour')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 9. INSERIR MOVIMENTAÇÕES DE ATIVOS
-- =====================================================

-- NOTA: As movimentações serão criadas depois que os usuários estiverem na tabela users
-- Por enquanto, vamos criar movimentações sem usuários específicos
INSERT INTO public.asset_movements (asset_id, action, from_unit_id, to_unit_id, from_responsible_id, to_responsible_id, notes, performed_by) VALUES
((SELECT id FROM public.assets WHERE code = 'INV-PC-001'), 'acquisition', NULL, (SELECT id FROM public.units WHERE code = 'LC001'), NULL, NULL, 'Aquisição inicial do equipamento', NULL),

((SELECT id FROM public.assets WHERE code = 'INV-PC-001'), 'maintenance', (SELECT id FROM public.units WHERE code = 'LC001'), (SELECT id FROM public.units WHERE code = 'LC001'), NULL, NULL, 'Manutenção preventiva realizada', NULL),

((SELECT id FROM public.assets WHERE code = 'INV-PC-002'), 'acquisition', NULL, (SELECT id FROM public.units WHERE code = 'LN001'), NULL, NULL, 'Aquisição inicial do equipamento', NULL),

((SELECT id FROM public.assets WHERE code = 'INV-MON-001'), 'acquisition', NULL, (SELECT id FROM public.units WHERE code = 'LC001'), NULL, NULL, 'Aquisição inicial do equipamento', NULL)
ON CONFLICT DO NOTHING;

-- Depois de inserir os usuários, atualize as movimentações com os IDs reais:
-- UPDATE public.asset_movements SET to_responsible_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE notes LIKE 'Aquisição inicial%';
-- UPDATE public.asset_movements SET performed_by = (SELECT id FROM public.users WHERE email = 'admin@empresa.com') WHERE notes LIKE 'Aquisição inicial%';
-- UPDATE public.asset_movements SET from_responsible_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com'), to_responsible_id = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com'), performed_by = (SELECT id FROM public.users WHERE email = 'tecnico@empresa.com') WHERE notes LIKE 'Manutenção preventiva%';

-- =====================================================
-- 10. VERIFICAÇÃO DOS DADOS INSERIDOS
-- =====================================================

-- Verificar contagem de registros
DO $$
DECLARE
    user_count INTEGER;
    unit_count INTEGER;
    asset_count INTEGER;
    ticket_count INTEGER;
    network_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM public.users;
    SELECT COUNT(*) INTO unit_count FROM public.units;
    SELECT COUNT(*) INTO asset_count FROM public.assets;
    SELECT COUNT(*) INTO ticket_count FROM public.tickets;
    SELECT COUNT(*) INTO network_count FROM public.network_monitoring;
    
    RAISE NOTICE '=== RESUMO DOS DADOS INSERIDOS ===';
    RAISE NOTICE 'Usuários: %', user_count;
    RAISE NOTICE 'Unidades: %', unit_count;
    RAISE NOTICE 'Ativos: %', asset_count;
    RAISE NOTICE 'Tickets: %', ticket_count;
    RAISE NOTICE 'Monitoramento de Rede: %', network_count;
    RAISE NOTICE '================================';
END $$;

-- =====================================================
-- 11. TESTES DAS FUNÇÕES
-- =====================================================

-- Testar função de busca de tickets
SELECT 'Teste de busca de tickets:' as teste;
SELECT * FROM search_tickets(p_search := 'impressora');

-- Testar função de estatísticas do dashboard
SELECT 'Teste de estatísticas do dashboard:' as teste;
SELECT * FROM get_dashboard_stats();

-- Testar view de inventário
SELECT 'Teste de view de inventário:' as teste;
SELECT code, name, category_name, unit_name FROM inventory_overview LIMIT 5;

-- Testar view de status da rede
SELECT 'Teste de view de status da rede:' as teste;
SELECT unit_name, status, uptime_percentage, vpn_status FROM network_status_overview;

-- =====================================================
-- DADOS DE EXEMPLO INSERIDOS COM SUCESSO!
-- =====================================================
-- 
-- PRÓXIMOS PASSOS:
-- 
-- 1. CRIAR USUÁRIOS NO SUPABASE AUTH:
--    - Vá para Authentication > Users no Supabase Dashboard
--    - Crie os usuários com as seguintes credenciais:
--      * admin@empresa.com (senha: senha123)
--      * gerente@empresa.com (senha: senha123)
--      * tecnico@empresa.com (senha: senha123)
--      * usuario@empresa.com (senha: senha123)
--      * ana@empresa.com (senha: senha123)
--
-- 2. OBTER OS UUIDs DOS USUÁRIOS:
--    - Execute no SQL Editor:
--      SELECT id, email FROM auth.users WHERE email IN ('admin@empresa.com', 'gerente@empresa.com', 'tecnico@empresa.com', 'usuario@empresa.com', 'ana@empresa.com');
--
-- 3. CRIAR PERFIS DOS USUÁRIOS:
--    - Execute o script de criação de perfis (veja seção 1)
--    - Substitua os UUIDs pelos IDs reais
--
-- 4. ATUALIZAR RELACIONAMENTOS:
--    - Execute os comandos UPDATE comentados em cada seção
--    - Isso conectará usuários, unidades, ativos e tickets
--
-- 5. TESTAR O SISTEMA:
--    - Faça login com as credenciais criadas
--    - Verifique se todas as funcionalidades estão funcionando
--
-- =====================================================
