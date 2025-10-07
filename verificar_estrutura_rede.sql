-- =====================================================
-- VERIFICAÇÃO E CORREÇÃO DA ESTRUTURA DE REDE
-- =====================================================

-- 1. VERIFICAR SE AS TABELAS EXISTEM
SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('units', 'network_monitoring', 'users')
ORDER BY table_name;

-- 2. VERIFICAR ESTRUTURA DA TABELA UNITS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'units'
ORDER BY ordinal_position;

-- 3. VERIFICAR ESTRUTURA DA TABELA NETWORK_MONITORING
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'network_monitoring'
ORDER BY ordinal_position;

-- 4. VERIFICAR DADOS NAS TABELAS
SELECT 'units' as tabela, COUNT(*) as total_registros FROM public.units
UNION ALL
SELECT 'network_monitoring' as tabela, COUNT(*) as total_registros FROM public.network_monitoring
UNION ALL
SELECT 'users' as tabela, COUNT(*) as total_registros FROM public.users;

-- 5. VERIFICAR CONSTRAINTS E FOREIGN KEYS
SELECT 
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
    AND tc.table_name IN ('units', 'network_monitoring')
ORDER BY tc.table_name, tc.constraint_type;

-- 6. VERIFICAR POLÍTICAS RLS
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
WHERE schemaname = 'public'
    AND tablename IN ('units', 'network_monitoring')
ORDER BY tablename, policyname;

-- 7. VERIFICAR SE RLS ESTÁ ATIVADO
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public'
    AND tablename IN ('units', 'network_monitoring');

-- =====================================================
-- CORREÇÕES AUTOMÁTICAS (EXECUTAR APENAS SE NECESSÁRIO)
-- =====================================================

-- 8. CRIAR TABELA UNITS SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS public.units (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE,
    address TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. CRIAR TABELA NETWORK_MONITORING SE NÃO EXISTIR
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

-- 10. INSERIR UNIDADE PADRÃO SE NÃO EXISTIR
INSERT INTO public.units (name, code, status)
SELECT 'Unidade Principal', 'MAIN', 'active'
WHERE NOT EXISTS (SELECT 1 FROM public.units WHERE code = 'MAIN');

-- 11. ATIVAR RLS NAS TABELAS
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_monitoring ENABLE ROW LEVEL SECURITY;

-- 12. CRIAR POLÍTICAS RLS BÁSICAS
-- Política para units (permitir visualização para todos)
DROP POLICY IF EXISTS "Anyone can view units" ON public.units;
CREATE POLICY "Anyone can view units" ON public.units
    FOR SELECT USING (true);

-- Política para network_monitoring (permitir visualização para todos)
DROP POLICY IF EXISTS "Anyone can view network status" ON public.network_monitoring;
CREATE POLICY "Anyone can view network status" ON public.network_monitoring
    FOR SELECT USING (true);

-- Política para inserção em network_monitoring (permitir para usuários autenticados)
DROP POLICY IF EXISTS "Authenticated users can insert network monitoring" ON public.network_monitoring;
CREATE POLICY "Authenticated users can insert network monitoring" ON public.network_monitoring
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 13. VERIFICAR SE AS CORREÇÕES FUNCIONARAM
SELECT 'Verificação final' as status;
SELECT COUNT(*) as total_units FROM public.units;
SELECT COUNT(*) as total_network_devices FROM public.network_monitoring;
