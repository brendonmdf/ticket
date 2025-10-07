-- =====================================================
-- CRIAR TABELAS NECESSÁRIAS PRIMEIRO
-- =====================================================
-- 
-- Execute este script ANTES de criar as funções
-- Este script cria apenas as tabelas essenciais
-- =====================================================

-- 1. VERIFICAR SE AS TABELAS JÁ EXISTEM
SELECT 'Verificando tabelas existentes...' as etapa;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('tickets', 'users', 'units')
ORDER BY table_name;

-- 2. CRIAR TABELA DE USUÁRIOS
SELECT 'Criando tabela users...' as etapa;
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'manager', 'technician', 'user')),
    department TEXT,
    phone TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CRIAR TABELA DE UNIDADES
SELECT 'Criando tabela units...' as etapa;
CREATE TABLE IF NOT EXISTS public.units (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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

-- 4. CRIAR TABELA DE TICKETS
SELECT 'Criando tabela tickets...' as etapa;
CREATE TABLE IF NOT EXISTS public.tickets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ticket_number TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'resolved', 'closed', 'cancelled')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    category TEXT CHECK (category IN ('hardware', 'software', 'network', 'access', 'other')),
    requester_id UUID REFERENCES public.users(id),
    assignee_id UUID REFERENCES public.users(id),
    unit_id UUID REFERENCES public.units(id),
    estimated_hours INTEGER,
    actual_hours INTEGER,
    due_date TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. VERIFICAR SE AS TABELAS FORAM CRIADAS
SELECT 'Verificando criação das tabelas...' as etapa;
SELECT 
    table_name,
    table_schema,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('tickets', 'users', 'units')
ORDER BY table_name;

-- 6. INSERIR DADOS DE EXEMPLO (OPCIONAL)
SELECT 'Inserindo dados de exemplo...' as etapa;

-- Inserir usuário de exemplo
INSERT INTO public.users (id, email, full_name, role) VALUES 
(gen_random_uuid(), 'admin@exemplo.com', 'Administrador', 'admin')
ON CONFLICT (email) DO NOTHING;

-- Inserir unidade de exemplo
INSERT INTO public.units (name, code, city, state) VALUES 
('Loja Centro', 'LC001', 'São Paulo', 'SP')
ON CONFLICT (name) DO NOTHING;

-- Inserir ticket de exemplo
INSERT INTO public.tickets (ticket_number, title, description, requester_id, unit_id) VALUES 
('TKT-000001', 'Teste de Sistema', 'Ticket de teste para verificar funcionamento', 
 (SELECT id FROM public.users LIMIT 1),
 (SELECT id FROM public.units LIMIT 1))
ON CONFLICT (ticket_number) DO NOTHING;

-- 7. VERIFICAR DADOS INSERIDOS
SELECT 'Verificando dados inseridos...' as etapa;
SELECT 'Usuários:' as tipo, COUNT(*) as total FROM public.users
UNION ALL
SELECT 'Unidades:' as tipo, COUNT(*) as total FROM public.units
UNION ALL
SELECT 'Tickets:' as tipo, COUNT(*) as total FROM public.tickets;

-- =====================================================
-- TABELAS CRIADAS COM SUCESSO!
-- =====================================================
-- 
-- Agora você pode executar o script de criação da função search_tickets
-- =====================================================
