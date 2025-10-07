-- =====================================================
-- SCRIPT PARA VERIFICAR E CRIAR TABELAS DE INVENTÁRIO
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. VERIFICAR SE AS TABELAS EXISTEM
SELECT 'Verificando tabelas de inventário...' as etapa;

SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY table_name;

-- 2. CRIAR TABELA asset_categories (se não existir)
SELECT 'Criando tabela asset_categories...' as etapa;

CREATE TABLE IF NOT EXISTS public.asset_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT DEFAULT 'package',
    color TEXT DEFAULT 'bg-blue-100 text-blue-800',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CRIAR TABELA units (se não existir)
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
    manager_id UUID,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. CRIAR TABELA assets (se não existir)
SELECT 'Criando tabela assets...' as etapa;

CREATE TABLE IF NOT EXISTS public.assets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    model TEXT,
    brand TEXT,
    category_id UUID REFERENCES public.asset_categories(id),
    unit_id UUID REFERENCES public.units(id),
    responsible_id UUID,
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

-- 5. CRIAR TABELA asset_movements (se não existir)
SELECT 'Criando tabela asset_movements...' as etapa;

CREATE TABLE IF NOT EXISTS public.asset_movements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    asset_id UUID REFERENCES public.assets(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK (action IN ('acquisition', 'transfer', 'maintenance', 'repair', 'retirement', 'return')),
    from_unit_id UUID REFERENCES public.units(id),
    to_unit_id UUID REFERENCES public.units(id),
    from_responsible_id UUID,
    to_responsible_id UUID,
    notes TEXT,
    performed_by UUID,
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. VERIFICAR SE AS TABELAS FORAM CRIADAS
SELECT 'Verificando criação das tabelas...' as etapa;

SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY table_name;

-- 7. VERIFICAR ESTRUTURA DAS TABELAS
SELECT 'Verificando estrutura das tabelas...' as etapa;

-- Estrutura de asset_categories
SELECT 'asset_categories:' as tabela;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'asset_categories'
ORDER BY ordinal_position;

-- Estrutura de assets
SELECT 'assets:' as tabela;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'assets'
ORDER BY ordinal_position;

-- 8. CRIAR ÍNDICES PARA PERFORMANCE
SELECT 'Criando índices...' as etapa;

-- Índices para assets
CREATE INDEX IF NOT EXISTS idx_assets_category ON public.assets(category_id);
CREATE INDEX IF NOT EXISTS idx_assets_unit ON public.assets(unit_id);
CREATE INDEX IF NOT EXISTS idx_assets_status ON public.assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_code ON public.assets(code);

-- Índices para asset_movements
CREATE INDEX IF NOT EXISTS idx_asset_movements_asset ON public.asset_movements(asset_id);
CREATE INDEX IF NOT EXISTS idx_asset_movements_performed_at ON public.asset_movements(performed_at);

-- 9. VERIFICAR SE RLS ESTÁ ATIVO
SELECT 'Verificando status do RLS...' as etapa;

SELECT 
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY tablename;

-- 10. DESABILITAR RLS TEMPORARIAMENTE (para desenvolvimento)
SELECT 'Desabilitando RLS...' as etapa;

ALTER TABLE public.asset_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.asset_movements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.units DISABLE ROW LEVEL SECURITY;

-- 11. CONFIRMAR DESABILITAÇÃO DO RLS
SELECT 'Confirmando desabilitação do RLS...' as etapa;

SELECT 
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY tablename;

-- 12. MENSAGEM DE CONFIRMAÇÃO
SELECT '✅ Tabelas de inventário criadas e RLS desabilitado com sucesso!' as resultado;
SELECT '🔓 Agora você pode criar categorias e ativos no sistema' as observacao;
