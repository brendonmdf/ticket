-- =====================================================
-- SCRIPT DE CORREÇÃO - FUNÇÃO search_tickets()
-- =====================================================
-- 
-- Este script cria apenas a função search_tickets() que está faltando
-- Execute este script no SQL Editor do Supabase se a função não existir
-- =====================================================

-- Função para buscar tickets por filtros
CREATE OR REPLACE FUNCTION public.search_tickets(
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

-- Verificar se a função foi criada
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_schema = 'public' 
        AND routine_name = 'search_tickets'
    ) THEN
        RAISE NOTICE 'Função search_tickets() criada com sucesso!';
    ELSE
        RAISE NOTICE 'ERRO: Função search_tickets() não foi criada!';
    END IF;
END $$;

-- Testar a função (opcional)
-- SELECT * FROM public.search_tickets();
