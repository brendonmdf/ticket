-- =====================================================
-- CRIAÇÃO DAS TABELAS PARA MONITORAMENTO DE REDE
-- =====================================================

-- 1. CRIAR TABELA UNITS (se não existir)
CREATE TABLE IF NOT EXISTS public.units (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE,
    address TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CRIAR TABELA NETWORK_MONITORING
CREATE TABLE IF NOT EXISTS public.network_monitoring (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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

-- 3. INSERIR UNIDADE PADRÃO
INSERT INTO public.units (name, code, status)
VALUES ('Unidade Principal', 'MAIN', 'active')
ON CONFLICT (code) DO NOTHING;

-- 4. ATIVAR RLS NAS TABELAS
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_monitoring ENABLE ROW LEVEL SECURITY;

-- 5. CRIAR POLÍTICAS RLS BÁSICAS
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

-- 6. VERIFICAR SE AS TABELAS FORAM CRIADAS
SELECT 'Verificação final' as status;
SELECT COUNT(*) as total_units FROM public.units;
SELECT COUNT(*) as total_network_devices FROM public.network_monitoring;
