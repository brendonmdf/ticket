-- =====================================================
-- SCRIPT PARA DESABILITAR RLS NAS TABELAS DE INVENTÁRIO
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. VERIFICAR STATUS ATUAL DO RLS NAS TABELAS DE INVENTÁRIO
SELECT 'Verificando status do RLS...' as etapa;

SELECT 
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY tablename;

-- 2. DESABILITAR RLS EM TODAS AS TABELAS DE INVENTÁRIO
SELECT 'Desabilitando RLS...' as etapa;

ALTER TABLE public.asset_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.asset_movements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.units DISABLE ROW LEVEL SECURITY;

-- 3. CONFIRMAR QUE RLS FOI DESABILITADO
SELECT 'Confirmando desabilitação do RLS...' as etapa;

SELECT 
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY tablename;

-- 4. REMOVER POLÍTICAS RLS EXISTENTES (opcional)
SELECT 'Removendo políticas RLS...' as etapa;

-- Remover políticas da tabela asset_categories
DROP POLICY IF EXISTS "Anyone can view asset categories" ON public.asset_categories;
DROP POLICY IF EXISTS "Admins can manage asset categories" ON public.asset_categories;

-- Remover políticas da tabela assets
DROP POLICY IF EXISTS "Anyone can view active assets" ON public.assets;
DROP POLICY IF EXISTS "Technicians and above can manage assets" ON public.assets;

-- Remover políticas da tabela asset_movements
DROP POLICY IF EXISTS "Anyone can view asset movements" ON public.asset_movements;
DROP POLICY IF EXISTS "Technicians and above can manage movements" ON public.asset_movements;

-- Remover políticas da tabela units
DROP POLICY IF EXISTS "Anyone can view active units" ON public.units;
DROP POLICY IF EXISTS "Admins and managers can manage units" ON public.units;

-- 5. VERIFICAR SE AS POLÍTICAS FORAM REMOVIDAS
SELECT 'Verificando remoção das políticas...' as etapa;

SELECT 
    schemaname,
    tablename,
    policyname
FROM pg_policies 
WHERE tablename IN ('asset_categories', 'assets', 'asset_movements', 'units')
ORDER BY tablename, policyname;

-- 6. TESTAR OPERAÇÕES BÁSICAS
SELECT 'Testando operações básicas...' as etapa;

-- Testar SELECT em asset_categories
SELECT COUNT(*) as total_categorias FROM public.asset_categories;

-- Testar SELECT em assets
SELECT COUNT(*) as total_ativos FROM public.assets;

-- Testar SELECT em units
SELECT COUNT(*) as total_unidades FROM public.units;

-- Testar SELECT em asset_movements
SELECT COUNT(*) as total_movimentacoes FROM public.asset_movements;

-- 7. MENSAGEM DE CONFIRMAÇÃO
SELECT '✅ RLS desabilitado com sucesso em todas as tabelas de inventário!' as resultado;
SELECT '🔓 Agora você pode realizar operações CRUD completas no inventário' as observacao;
