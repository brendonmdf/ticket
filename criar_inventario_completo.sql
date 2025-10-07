-- =====================================================
-- SCRIPT COMPLETO PARA CRIAR INVENTÁRIO
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. CRIAR TABELA asset_categories
CREATE TABLE IF NOT EXISTS public.asset_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT DEFAULT 'package',
    color TEXT DEFAULT 'bg-blue-100 text-blue-800',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CRIAR TABELA units
CREATE TABLE IF NOT EXISTS public.units (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE,
    address TEXT,
    city TEXT,
    state TEXT,
    phone TEXT,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CRIAR TABELA assets
CREATE TABLE IF NOT EXISTS public.assets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    model TEXT,
    brand TEXT,
    category_id UUID REFERENCES public.asset_categories(id),
    unit_id UUID REFERENCES public.units(id),
    responsible_id UUID,
    status TEXT DEFAULT 'active',
    acquisition_date DATE,
    purchase_value DECIMAL(10,2),
    serial_number TEXT,
    location_details TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. CRIAR TABELA asset_movements
CREATE TABLE IF NOT EXISTS public.asset_movements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    asset_id UUID REFERENCES public.assets(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    from_unit_id UUID REFERENCES public.units(id),
    to_unit_id UUID REFERENCES public.units(id),
    from_responsible_id UUID,
    to_responsible_id UUID,
    notes TEXT,
    performed_by UUID,
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. DESABILITAR RLS
ALTER TABLE public.asset_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.units DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.asset_movements DISABLE ROW LEVEL SECURITY;

-- 6. INSERIR CATEGORIAS PADRÃO
INSERT INTO public.asset_categories (name, description, icon, color) VALUES
    ('Computadores', 'Desktops, notebooks e workstations', 'computer', 'bg-blue-100 text-blue-800'),
    ('Monitores', 'Monitores e displays', 'monitor', 'bg-green-100 text-green-800'),
    ('Periféricos', 'Teclados, mouses e outros acessórios', 'keyboard', 'bg-purple-100 text-purple-800'),
    ('Cabos', 'Cabos de rede, energia e dados', 'cable', 'bg-orange-100 text-orange-800'),
    ('Câmeras', 'Câmeras de segurança e webcams', 'camera', 'bg-red-100 text-red-800'),
    ('Leitores', 'Leitores de código de barras e RFID', 'barcode', 'bg-indigo-100 text-indigo-800')
ON CONFLICT (name) DO NOTHING;

-- 7. INSERIR UNIDADES PADRÃO
INSERT INTO public.units (name, code, city, state) VALUES
    ('Loja 1', 'LOJA-001', 'São Paulo', 'SP'),
    ('Loja 2', 'LOJA-002', 'São Paulo', 'SP'),
    ('Loja 3', 'LOJA-003', 'São Paulo', 'SP'),
    ('Loja 4', 'LOJA-004', 'São Paulo', 'SP'),
    ('Loja 5', 'LOJA-005', 'São Paulo', 'SP')
ON CONFLICT (code) DO NOTHING;

-- 8. VERIFICAR CRIAÇÃO
SELECT '✅ Inventário criado com sucesso!' as resultado;
SELECT '📊 Categorias criadas: ' || COUNT(*) as total_categorias FROM public.asset_categories;
SELECT '🏢 Unidades criadas: ' || COUNT(*) as total_unidades FROM public.units;
SELECT '🔓 RLS desabilitado em todas as tabelas' as rls_status;
