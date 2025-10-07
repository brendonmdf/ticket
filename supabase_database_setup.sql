-- =====================================================
-- SCRIPT DE CONFIGURAÇÃO COMPLETA DO BANCO DE DADOS
-- SISTEMA DE GESTÃO DE TI - SUPABASE
-- =====================================================

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. TABELAS PRINCIPAIS
-- =====================================================

-- Tabela de usuários (estende auth.users do Supabase)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'manager', 'technician', 'user')),
    department TEXT,
    phone TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de unidades/lojas
CREATE TABLE IF NOT EXISTS public.units (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    phone TEXT,
    manager_id UUID REFERENCES public.users(id),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de categorias de ativos
CREATE TABLE IF NOT EXISTS public.asset_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT,
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de ativos do inventário
CREATE TABLE IF NOT EXISTS public.assets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    model TEXT,
    brand TEXT,
    category_id UUID REFERENCES public.asset_categories(id),
    unit_id UUID REFERENCES public.units(id),
    responsible_id UUID REFERENCES public.users(id),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance', 'retired', 'lost')),
    acquisition_date DATE,
    warranty_expiry DATE,
    purchase_value DECIMAL(10,2),
    serial_number TEXT,
    specifications JSONB,
    location_details TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de histórico de movimentação de ativos
CREATE TABLE IF NOT EXISTS public.asset_movements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    asset_id UUID REFERENCES public.assets(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK (action IN ('acquisition', 'transfer', 'maintenance', 'repair', 'retirement', 'return')),
    from_unit_id UUID REFERENCES public.units(id),
    to_unit_id UUID REFERENCES public.units(id),
    from_responsible_id UUID REFERENCES public.users(id),
    to_responsible_id UUID REFERENCES public.users(id),
    notes TEXT,
    performed_by UUID REFERENCES public.users(id),
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de chamados/tickets
CREATE TABLE IF NOT EXISTS public.tickets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ticket_number TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'resolved', 'closed', 'cancelled')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    category TEXT CHECK (category IN ('hardware', 'software', 'network', 'access', 'other')),
    requester_id UUID REFERENCES public.users(id),
    assignee_id UUID REFERENCES public.users(id),
    unit_id UUID REFERENCES public.units(id),
    asset_id UUID REFERENCES public.assets(id),
    estimated_hours INTEGER,
    actual_hours INTEGER,
    due_date TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de comentários dos tickets
CREATE TABLE IF NOT EXISTS public.ticket_comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ticket_id UUID REFERENCES public.tickets(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id),
    comment TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de histórico de status dos tickets
CREATE TABLE IF NOT EXISTS public.ticket_status_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ticket_id UUID REFERENCES public.tickets(id) ON DELETE CASCADE,
    old_status TEXT,
    new_status TEXT NOT NULL,
    changed_by UUID REFERENCES public.users(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);

-- Tabela de monitoramento de rede
CREATE TABLE IF NOT EXISTS public.network_monitoring (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    unit_id UUID REFERENCES public.units(id),
    ip_address INET,
    hostname TEXT,
    status TEXT DEFAULT 'unknown' CHECK (status IN ('online', 'offline', 'warning', 'unknown')),
    uptime_percentage DECIMAL(5,2),
    last_ping_ms INTEGER,
    vpn_status TEXT DEFAULT 'unknown' CHECK (vpn_status IN ('connected', 'disconnected', 'unknown')),
    services JSONB,
    last_check TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de histórico de status da rede
CREATE TABLE IF NOT EXISTS public.network_status_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    monitoring_id UUID REFERENCES public.network_monitoring(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    ping_ms INTEGER,
    uptime_percentage DECIMAL(5,2),
    vpn_status TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de configurações do sistema
CREATE TABLE IF NOT EXISTS public.system_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    value JSONB,
    description TEXT,
    updated_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para tickets
CREATE INDEX IF NOT EXISTS idx_tickets_status ON public.tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_priority ON public.tickets(priority);
CREATE INDEX IF NOT EXISTS idx_tickets_requester ON public.tickets(requester_id);
CREATE INDEX IF NOT EXISTS idx_tickets_assignee ON public.tickets(assignee_id);
CREATE INDEX IF NOT EXISTS idx_tickets_unit ON public.tickets(unit_id);
CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON public.tickets(created_at);

-- Índices para ativos
CREATE INDEX IF NOT EXISTS idx_assets_category ON public.assets(category_id);
CREATE INDEX IF NOT EXISTS idx_assets_unit ON public.assets(unit_id);
CREATE INDEX IF NOT EXISTS idx_assets_status ON public.assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_code ON public.assets(code);

-- Índices para monitoramento de rede
CREATE INDEX IF NOT EXISTS idx_network_monitoring_unit ON public.network_monitoring(unit_id);
CREATE INDEX IF NOT EXISTS idx_network_monitoring_status ON public.network_monitoring(status);
CREATE INDEX IF NOT EXISTS idx_network_monitoring_last_check ON public.network_monitoring(last_check);

-- =====================================================
-- 3. FUNÇÕES E PROCEDIMENTOS (CRIADAS ANTES DAS VIEWS)
-- =====================================================

-- Função para gerar número de ticket automático
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.ticket_number := 'TKT-' || LPAD(CAST(nextval('ticket_sequence') AS TEXT), 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Sequência para números de tickets
CREATE SEQUENCE IF NOT EXISTS ticket_sequence START 1;

-- Trigger para gerar número de ticket
CREATE TRIGGER trigger_generate_ticket_number
    BEFORE INSERT ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION generate_ticket_number();

-- Função para atualizar timestamp de atualização
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar timestamps
CREATE TRIGGER trigger_update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_assets_updated_at
    BEFORE UPDATE ON public.assets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_tickets_updated_at
    BEFORE UPDATE ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_network_monitoring_updated_at
    BEFORE UPDATE ON public.network_monitoring
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Função para registrar histórico de status de tickets
CREATE OR REPLACE FUNCTION log_ticket_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.ticket_status_history (
            ticket_id, old_status, new_status, changed_by, notes
        ) VALUES (
            NEW.id, OLD.status, NEW.status, 
            COALESCE(NEW.assignee_id, NEW.requester_id),
            'Status alterado de ' || OLD.status || ' para ' || NEW.status
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para histórico de status
CREATE TRIGGER trigger_log_ticket_status_change
    AFTER UPDATE ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION log_ticket_status_change();

-- Função para calcular uptime médio (CRIADA ANTES DAS VIEWS)
CREATE OR REPLACE FUNCTION calculate_average_uptime()
RETURNS DECIMAL AS $$
DECLARE
    avg_uptime DECIMAL;
BEGIN
    SELECT AVG(uptime_percentage)
    INTO avg_uptime
    FROM public.network_monitoring
    WHERE status = 'online';
    
    RETURN COALESCE(avg_uptime, 0);
END;
$$ LANGUAGE plpgsql;

-- Função para buscar tickets por filtros (CRIADA ANTES DAS VIEWS)
CREATE OR REPLACE FUNCTION search_tickets(
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

-- Função para estatísticas do dashboard
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS TABLE (
    total_tickets INTEGER,
    open_tickets INTEGER,
    resolved_tickets INTEGER,
    total_assets INTEGER,
    online_units INTEGER,
    offline_units INTEGER,
    avg_uptime DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM public.tickets) as total_tickets,
        (SELECT COUNT(*) FROM public.tickets WHERE status IN ('new', 'in_progress')) as open_tickets,
        (SELECT COUNT(*) FROM public.tickets WHERE status = 'resolved') as resolved_tickets,
        (SELECT COUNT(*) FROM public.assets WHERE status = 'active') as total_assets,
        (SELECT COUNT(*) FROM public.network_monitoring WHERE status = 'online') as online_units,
        (SELECT COUNT(*) FROM public.network_monitoring WHERE status = 'offline') as offline_units,
        (SELECT calculate_average_uptime()) as avg_uptime;
END;
$$ LANGUAGE plpgsql;

-- Função para notificar sobre tickets críticos
CREATE OR REPLACE FUNCTION notify_critical_tickets()
RETURNS TRIGGER AS $$
BEGIN
    -- Aqui você pode implementar lógica de notificação
    -- Por exemplo, enviar email, webhook, etc.
    
    IF NEW.priority = 'critical' AND NEW.status = 'new' THEN
        -- Log da notificação (você pode expandir isso)
        RAISE LOG 'TICKET CRÍTICO CRIADO: % - %', NEW.ticket_number, NEW.title;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para notificações
CREATE TRIGGER trigger_notify_critical_tickets
    AFTER INSERT ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION notify_critical_tickets();

-- Função para limpar histórico antigo
CREATE OR REPLACE FUNCTION cleanup_old_records()
RETURNS void AS $$
BEGIN
    -- Limpar histórico de status de rede com mais de 30 dias
    DELETE FROM public.network_status_history 
    WHERE recorded_at < NOW() - INTERVAL '30 days';
    
    -- Limpar histórico de movimentação de ativos com mais de 1 ano
    DELETE FROM public.asset_movements 
    WHERE performed_at < NOW() - INTERVAL '1 year';
    
    -- Limpar histórico de status de tickets com mais de 1 ano
    DELETE FROM public.ticket_status_history 
    WHERE changed_at < NOW() - INTERVAL '1 year';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. DADOS INICIAIS
-- =====================================================

-- Inserir categorias de ativos padrão
INSERT INTO public.asset_categories (name, description, icon, color) VALUES
('Computadores', 'Desktops, notebooks e workstations', 'computer', 'bg-blue-100 text-blue-800'),
('Monitores', 'Monitores e displays', 'monitor', 'bg-green-100 text-green-800'),
('Periféricos', 'Teclados, mouses e outros periféricos', 'keyboard', 'bg-purple-100 text-purple-800'),
('Cabos', 'Cabos de rede, energia e dados', 'cable', 'bg-orange-100 text-orange-800'),
('Câmeras', 'Câmeras de segurança e webcams', 'camera', 'bg-red-100 text-red-800'),
('Leitores', 'Leitores de código de barras e RFID', 'barcode', 'bg-indigo-100 text-indigo-800')
ON CONFLICT (name) DO NOTHING;

-- Inserir configurações padrão do sistema
INSERT INTO public.system_settings (key, value, description) VALUES
('ticket_auto_assignment', '{"enabled": true, "round_robin": true}', 'Configurações de atribuição automática de tickets'),
('network_monitoring_interval', '{"seconds": 30}', 'Intervalo de verificação da rede em segundos'),
('notification_settings', '{"email": true, "slack": false, "webhook": false}', 'Configurações de notificações'),
('maintenance_mode', '{"enabled": false, "message": ""}', 'Modo de manutenção do sistema')
ON CONFLICT (key) DO NOTHING;

-- =====================================================
-- 5. POLÍTICAS DE SEGURANÇA (RLS)
-- =====================================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.asset_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_monitoring ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- Políticas para usuários
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Políticas para unidades
CREATE POLICY "Anyone can view active units" ON public.units
    FOR SELECT USING (status = 'active');

CREATE POLICY "Admins and managers can manage units" ON public.units
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager')
        )
    );

-- Políticas para ativos
CREATE POLICY "Anyone can view active assets" ON public.assets
    FOR SELECT USING (status = 'active');

CREATE POLICY "Technicians and above can manage assets" ON public.assets
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager', 'technician')
        )
    );

-- Políticas para tickets
CREATE POLICY "Users can view tickets from their unit" ON public.tickets
    FOR SELECT USING (
        requester_id = auth.uid()
        OR
        assignee_id = auth.uid()
        OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager')
        )
    );

CREATE POLICY "Users can create tickets" ON public.tickets
    FOR INSERT WITH CHECK (requester_id = auth.uid());

CREATE POLICY "Assigned technicians can update tickets" ON public.tickets
    FOR UPDATE USING (assignee_id = auth.uid());

CREATE POLICY "Admins and managers can manage all tickets" ON public.tickets
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager')
        )
    );

-- Políticas para comentários de tickets
CREATE POLICY "Users can view comments from their tickets" ON public.ticket_comments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.tickets t
            WHERE t.id = ticket_comments.ticket_id
            AND (t.requester_id = auth.uid() OR t.assignee_id = auth.uid())
        )
    );

CREATE POLICY "Users can add comments to their tickets" ON public.ticket_comments
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tickets t
            WHERE t.id = ticket_comments.ticket_id
            AND (t.requester_id = auth.uid() OR t.assignee_id = auth.uid())
        )
    );

-- Políticas para monitoramento de rede
CREATE POLICY "Anyone can view network status" ON public.network_monitoring
    FOR SELECT USING (true);

CREATE POLICY "Admins and technicians can manage network monitoring" ON public.network_monitoring
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager', 'technician')
        )
    );

-- Políticas para configurações do sistema
CREATE POLICY "Only admins can manage system settings" ON public.system_settings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- 6. VIEWS ÚTEIS (CRIADAS APÓS AS FUNÇÕES)
-- =====================================================

-- View para dashboard com estatísticas
CREATE OR REPLACE VIEW public.dashboard_overview AS
SELECT 
    (SELECT COUNT(*) FROM public.tickets WHERE status IN ('new', 'in_progress')) as open_tickets,
    (SELECT COUNT(*) FROM public.tickets WHERE status = 'resolved') as resolved_tickets,
    (SELECT COUNT(*) FROM public.assets WHERE status = 'active') as total_assets,
    (SELECT COUNT(*) FROM public.network_monitoring WHERE status = 'online') as online_units,
    (SELECT COUNT(*) FROM public.network_monitoring WHERE status = 'offline') as offline_units,
    (SELECT calculate_average_uptime()) as avg_uptime;

-- View para tickets com informações completas
CREATE OR REPLACE VIEW public.tickets_overview AS
SELECT 
    t.*,
    ur.full_name as requester_name,
    ur.email as requester_email,
    ass.full_name as assignee_name,
    ass.email as assignee_email,
    u.name as unit_name,
    ac.name as asset_category,
    a.name as asset_name
FROM public.tickets t
LEFT JOIN public.users ur ON t.requester_id = ur.id
LEFT JOIN public.users ass ON t.assignee_id = ass.id
LEFT JOIN public.units u ON t.unit_id = u.id
LEFT JOIN public.assets a ON t.asset_id = a.id
LEFT JOIN public.asset_categories ac ON a.category_id = ac.id;

-- View para inventário com informações completas
CREATE OR REPLACE VIEW public.inventory_overview AS
SELECT 
    a.*,
    ac.name as category_name,
    ac.icon as category_icon,
    ac.color as category_color,
    u.name as unit_name,
    u.code as unit_code,
    r.full_name as responsible_name,
    r.email as responsible_email
FROM public.assets a
LEFT JOIN public.asset_categories ac ON a.category_id = ac.id
LEFT JOIN public.units u ON a.unit_id = u.id
LEFT JOIN public.users r ON a.responsible_id = r.id;

-- View para status da rede em tempo real
CREATE OR REPLACE VIEW public.network_status_overview AS
SELECT 
    nm.*,
    u.name as unit_name,
    u.code as unit_code,
    u.status as unit_status
FROM public.network_monitoring nm
LEFT JOIN public.units u ON nm.unit_id = u.id;

-- =====================================================
-- 7. COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE public.users IS 'Tabela de usuários do sistema que estende auth.users do Supabase';
COMMENT ON TABLE public.units IS 'Tabela de unidades/lojas da empresa';
COMMENT ON TABLE public.assets IS 'Tabela de ativos do inventário de TI';
COMMENT ON TABLE public.tickets IS 'Tabela de chamados/tickets de suporte';
COMMENT ON TABLE public.network_monitoring IS 'Tabela de monitoramento de status da rede';
COMMENT ON TABLE public.system_settings IS 'Tabela de configurações do sistema';

COMMENT ON FUNCTION generate_ticket_number() IS 'Gera número automático para novos tickets';
COMMENT ON FUNCTION calculate_average_uptime() IS 'Calcula uptime médio de todas as unidades';
COMMENT ON FUNCTION search_tickets() IS 'Busca tickets com filtros avançados';
COMMENT ON FUNCTION get_dashboard_stats() IS 'Retorna estatísticas para o dashboard';

-- =====================================================
-- 8. VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se todas as tabelas foram criadas
DO $$
DECLARE
    table_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE';
    
    RAISE NOTICE 'Total de tabelas criadas: %', table_count;
END $$;

-- Verificar se todas as funções foram criadas
DO $$
DECLARE
    function_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO function_count
    FROM information_schema.routines 
    WHERE routine_schema = 'public' 
    AND routine_type = 'FUNCTION';
    
    RAISE NOTICE 'Total de funções criadas: %', function_count;
END $$;

-- Verificar se RLS está habilitado
DO $$
DECLARE
    rls_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO rls_count
    FROM pg_tables 
    WHERE schemaname = 'public' 
    AND rowsecurity = true;
    
    RAISE NOTICE 'Tabelas com RLS habilitado: %', rls_count;
END $$;

-- Verificar se todas as views foram criadas
DO $$
DECLARE
    view_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO view_count
    FROM information_schema.views 
    WHERE table_schema = 'public';
    
    RAISE NOTICE 'Total de views criadas: %', view_count;
END $$;

-- =====================================================
-- SCRIPT CONCLUÍDO COM SUCESSO!
-- =====================================================
-- 
-- Este script cria um banco de dados completo para o sistema de gestão de TI
-- incluindo:
-- - 10 tabelas principais
-- - 8 funções e procedimentos
-- - 4 views úteis
-- - Políticas de segurança (RLS)
-- - Triggers automáticos
-- - Dados iniciais
-- - Índices para performance
--
-- ORDEM DE EXECUÇÃO CORRIGIDA:
-- 1. Tabelas e extensões
-- 2. Índices para performance
-- 3. Funções e procedimentos (incluindo search_tickets e calculate_average_uptime)
-- 4. Dados iniciais
-- 5. Políticas de segurança (RLS)
-- 6. Views (criadas após as funções)
-- 7. Comentários e documentação
-- 8. Verificações finais
--
-- Para usar no Supabase:
-- 1. Vá para o SQL Editor
-- 2. Cole este script completo
-- 3. Execute o script
-- 4. Configure as variáveis de ambiente necessárias
-- 5. Teste as funcionalidades
-- =====================================================
