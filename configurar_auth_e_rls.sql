-- =====================================================
-- CONFIGURAR AUTENTICAÇÃO E RLS
-- =====================================================
-- 
-- Execute este script após criar as tabelas
-- Configura as políticas de segurança necessárias
-- =====================================================

-- 1. VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 'Verificando RLS...' as etapa;
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'units', 'tickets')
ORDER BY tablename;

-- 2. HABILITAR RLS NAS TABELAS (se não estiver habilitado)
SELECT 'Habilitando RLS...' as etapa;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR POLÍTICAS DE SEGURANÇA
SELECT 'Criando políticas de segurança...' as etapa;

-- Política para usuários verem seu próprio perfil
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Política para usuários atualizarem seu próprio perfil
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Política para admins verem todos os usuários
DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Política para unidades (qualquer usuário autenticado pode ver)
DROP POLICY IF EXISTS "Anyone can view active units" ON public.units;
CREATE POLICY "Anyone can view active units" ON public.units
    FOR SELECT USING (status = 'active');

-- Política para tickets (usuários veem tickets da sua unidade)
DROP POLICY IF EXISTS "Users can view tickets from their unit" ON public.tickets;
CREATE POLICY "Users can view tickets from their unit" ON public.tickets
    FOR SELECT USING (
        requester_id = auth.uid()
        OR
        assignee_id = auth.uid()
        OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'manager')
        )
    );

-- Política para usuários criarem tickets
DROP POLICY IF EXISTS "Users can create tickets" ON public.tickets;
CREATE POLICY "Users can create tickets" ON public.tickets
    FOR INSERT WITH CHECK (requester_id = auth.uid());

-- 4. VERIFICAR POLÍTICAS CRIADAS
SELECT 'Verificando políticas criadas...' as etapa;
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
AND tablename IN ('users', 'units', 'tickets')
ORDER BY tablename, policyname;

-- 5. CRIAR FUNÇÃO PARA SINCRONIZAR USUÁRIOS AUTH
SELECT 'Criando função de sincronização...' as etapa;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        'user'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. CRIAR TRIGGER PARA NOVOS USUÁRIOS
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 7. VERIFICAR CONFIGURAÇÃO FINAL
SELECT 'Configuração final...' as etapa;
SELECT 
    'RLS habilitado em:' as tipo,
    COUNT(*) as total_tabelas
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true
AND tablename IN ('users', 'units', 'tickets')

UNION ALL

SELECT 
    'Políticas criadas:' as tipo,
    COUNT(*) as total_politicas
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('users', 'units', 'tickets')

UNION ALL

SELECT 
    'Trigger criado:' as tipo,
    COUNT(*) as total_triggers
FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

-- =====================================================
-- CONFIGURAÇÃO CONCLUÍDA!
-- =====================================================
-- 
-- Agora você pode:
-- 1. Criar usuários pelo Supabase Auth
-- 2. Os usuários serão automaticamente sincronizados
-- 3. As políticas de segurança estão ativas
-- =====================================================
