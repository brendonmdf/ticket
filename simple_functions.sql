-- =====================================================
-- SCRIPT SIMPLES - APENAS FUNÇÕES ESSENCIAIS
-- =====================================================

-- Função para calcular uptime médio
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

-- Função para buscar tickets por filtros
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

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================

-- Verificar se as funções foram criadas
SELECT 
    routine_name, 
    routine_type 
FROM information_schema.routines 
WHERE routine_name IN ('search_tickets', 'calculate_average_uptime', 'get_dashboard_stats')
AND routine_schema = 'public';

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================
