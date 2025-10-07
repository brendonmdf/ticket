-- Script simples para testar inserção de tickets
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se a tabela tickets existe
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'tickets'
);

-- 2. Verificar estrutura da tabela
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tickets' 
ORDER BY ordinal_position;

-- 3. Desabilitar RLS temporariamente para teste
ALTER TABLE public.tickets DISABLE ROW LEVEL SECURITY;

-- 4. Tentar inserir um ticket de teste
INSERT INTO public.tickets (
    ticket_number,
    title,
    description,
    priority,
    status,
    category,
    requester_name,
    requester_email,
    source,
    created_at
) VALUES (
    'TKT-TEST-' || EXTRACT(EPOCH FROM NOW())::integer,
    'Ticket de Teste RLS',
    'Teste de inserção com RLS desabilitado',
    'medium',
    'open',
    'teste',
    'Usuário Teste',
    'teste@exemplo.com',
    'external_form',
    NOW()
);

-- 5. Verificar se foi inserido
SELECT * FROM public.tickets 
WHERE title = 'Ticket de Teste RLS' 
ORDER BY created_at DESC 
LIMIT 1;

-- 6. Reabilitar RLS
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;

-- 7. Criar política simples para inserção
DROP POLICY IF EXISTS "Permitir inserção externa" ON public.tickets;
CREATE POLICY "Permitir inserção externa" ON public.tickets
    FOR INSERT 
    WITH CHECK (true);

-- 8. Testar inserção com RLS habilitado
INSERT INTO public.tickets (
    ticket_number,
    title,
    description,
    priority,
    status,
    category,
    requester_name,
    requester_email,
    source,
    created_at
) VALUES (
    'TKT-TEST-RLS-' || EXTRACT(EPOCH FROM NOW())::integer,
    'Ticket de Teste com RLS',
    'Teste de inserção com RLS habilitado',
    'medium',
    'open',
    'teste',
    'Usuário Teste RLS',
    'teste-rls@exemplo.com',
    'external_form',
    NOW()
);

-- 9. Verificar se foi inserido
SELECT * FROM public.tickets 
WHERE title = 'Ticket de Teste com RLS' 
ORDER BY created_at DESC 
LIMIT 1;
