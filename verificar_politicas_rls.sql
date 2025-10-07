-- Script para verificar e corrigir políticas RLS da tabela tickets
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se a tabela tickets existe e sua estrutura
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tickets' 
ORDER BY ordinal_position;

-- 2. Verificar políticas RLS existentes
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'tickets';

-- 3. Verificar se RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'tickets';

-- 4. Habilitar RLS se não estiver habilitado
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;

-- 5. Remover políticas existentes que possam estar causando conflito
DROP POLICY IF EXISTS "Permitir inserção externa" ON public.tickets;
DROP POLICY IF EXISTS "Permitir visualização própria" ON public.tickets;
DROP POLICY IF EXISTS "Permitir atualização própria" ON public.tickets;

-- 6. Criar política para permitir inserção de usuários não autenticados
CREATE POLICY "Permitir inserção externa" ON public.tickets
    FOR INSERT 
    WITH CHECK (true);

-- 7. Criar política para permitir visualização de tickets próprios (para usuários autenticados)
CREATE POLICY "Permitir visualização própria" ON public.tickets
    FOR SELECT 
    USING (
        auth.uid() IS NOT NULL AND (
            requester_email = auth.jwt() ->> 'email' OR
            assignee_id = auth.uid()
        )
    );

-- 8. Criar política para permitir atualização de tickets próprios
CREATE POLICY "Permitir atualização própria" ON public.tickets
    FOR UPDATE 
    USING (
        auth.uid() IS NOT NULL AND (
            requester_email = auth.jwt() ->> 'email' OR
            assignee_id = auth.uid()
        )
    );

-- 9. Verificar se as políticas foram criadas corretamente
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'tickets';

-- 10. Testar inserção de um ticket de exemplo
INSERT INTO public.tickets (
    ticket_number,
    title,
    description,
    priority,
    status,
    category,
    requester_name,
    requester_email,
    requester_phone,
    unit_name,
    source,
    created_at
) VALUES (
    'TKT-TEST-001',
    'Ticket de Teste',
    'Este é um ticket de teste para verificar as políticas RLS',
    'medium',
    'open',
    'teste',
    'Usuário Teste',
    'teste@exemplo.com',
    '(11) 99999-9999',
    'Unidade Teste',
    'external_form',
    NOW()
);

-- 11. Verificar se o ticket foi inserido
SELECT * FROM public.tickets WHERE ticket_number = 'TKT-TEST-001';

-- 12. Limpar ticket de teste
DELETE FROM public.tickets WHERE ticket_number = 'TKT-TEST-001';
