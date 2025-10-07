-- =====================================================
-- CONFIGURAR PERMISSÕES PARA USUÁRIOS EXTERNOS
-- =====================================================
-- 
-- Execute este script para permitir que usuários externos
-- criem tickets sem autenticação
-- =====================================================

-- 1. VERIFICAR POLÍTICAS ATUAIS
SELECT 'Verificando políticas atuais...' as etapa;
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename = 'tickets'
ORDER BY policyname;

-- 2. REMOVER POLÍTICAS RESTRITIVAS EXISTENTES
SELECT 'Removendo políticas restritivas...' as etapa;
DROP POLICY IF EXISTS "Users can view tickets from their unit" ON public.tickets;
DROP POLICY IF EXISTS "Users can create tickets" ON public.tickets;

-- 3. CRIAR NOVA POLÍTICA PARA INSERÇÃO EXTERNA
SELECT 'Criando política para inserção externa...' as etapa;

-- Política para permitir inserção de tickets externos
CREATE POLICY "External users can create tickets" ON public.tickets
    FOR INSERT WITH CHECK (true);

-- 4. CRIAR POLÍTICA PARA VISUALIZAÇÃO (apenas técnicos autenticados)
SELECT 'Criando política para visualização...' as etapa;

-- Política para técnicos verem todos os tickets
CREATE POLICY "Technicians can view all tickets" ON public.tickets
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager', 'technician')
        )
    );

-- Política para usuários verem seus próprios tickets
CREATE POLICY "Users can view their own tickets" ON public.tickets
    FOR SELECT USING (
        requester_email = (
            SELECT email FROM auth.users WHERE id = auth.uid()
        )
    );

-- 5. CRIAR POLÍTICA PARA ATUALIZAÇÃO (apenas técnicos)
SELECT 'Criando política para atualização...' as etapa;

CREATE POLICY "Technicians can update tickets" ON public.tickets
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager', 'technician')
        )
    );

-- 6. VERIFICAR SE A TABELA TEM AS COLUNAS NECESSÁRIAS
SELECT 'Verificando estrutura da tabela tickets...' as etapa;

-- Adicionar colunas se não existirem
DO $$
BEGIN
    -- Adicionar coluna requester_name se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'requester_name') THEN
        ALTER TABLE public.tickets ADD COLUMN requester_name TEXT;
    END IF;
    
    -- Adicionar coluna requester_email se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'requester_email') THEN
        ALTER TABLE public.tickets ADD COLUMN requester_email TEXT;
    END IF;
    
    -- Adicionar coluna requester_phone se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'requester_phone') THEN
        ALTER TABLE public.tickets ADD COLUMN requester_phone TEXT;
    END IF;
    
    -- Adicionar coluna unit_name se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'unit_name') THEN
        ALTER TABLE public.tickets ADD COLUMN unit_name TEXT;
    END IF;
    
    -- Adicionar coluna source se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'source') THEN
        ALTER TABLE public.tickets ADD COLUMN source TEXT DEFAULT 'internal';
    END IF;
    
    -- Adicionar coluna category se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tickets' AND column_name = 'category') THEN
        ALTER TABLE public.tickets ADD COLUMN category TEXT DEFAULT 'geral';
    END IF;
END $$;

-- 7. VERIFICAR ESTRUTURA FINAL
SELECT 'Verificando estrutura final...' as etapa;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tickets' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 8. VERIFICAR POLÍTICAS FINAIS
SELECT 'Verificando políticas finais...' as etapa;
SELECT 
    policyname,
    cmd,
    permissive,
    roles
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename = 'tickets'
ORDER BY policyname;

-- 9. TESTAR INSERÇÃO EXTERNA
SELECT 'Testando inserção externa...' as etapa;

-- Inserir ticket de teste (simulando usuário externo)
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
    source
) VALUES (
    'TKT-TEST-' || EXTRACT(EPOCH FROM NOW())::TEXT,
    'Teste de Ticket Externo',
    'Este é um ticket de teste para verificar as permissões',
    'medium',
    'open',
    'geral',
    'Usuário Teste',
    'teste@exemplo.com',
    '(11) 99999-9999',
    'Unidade Teste',
    'external_form'
);

-- Verificar se foi inserido
SELECT 
    ticket_number,
    title,
    requester_name,
    requester_email,
    source,
    created_at
FROM public.tickets 
WHERE source = 'external_form'
ORDER BY created_at DESC
LIMIT 1;

-- 10. LIMPEZA (opcional - remover ticket de teste)
SELECT 'Limpando ticket de teste...' as etapa;
DELETE FROM public.tickets WHERE source = 'external_form' AND title = 'Teste de Ticket Externo';

-- =====================================================
-- CONFIGURAÇÃO CONCLUÍDA!
-- =====================================================
-- 
-- Agora usuários externos podem:
-- 1. Criar tickets sem autenticação
-- 2. Os tickets são marcados com source = 'external_form'
-- 3. Técnicos podem ver e gerenciar todos os tickets
-- 4. Usuários autenticados veem apenas seus próprios tickets
-- =====================================================
