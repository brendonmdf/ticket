-- =====================================================
-- VERIFICAÇÃO E CORREÇÃO DA TABELA DE USUÁRIOS
-- =====================================================

-- 1. VERIFICAR SE A TABELA USERS EXISTE
SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name = 'users';

-- 2. VERIFICAR ESTRUTURA DA TABELA USERS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'users'
ORDER BY ordinal_position;

-- 3. VERIFICAR DADOS NA TABELA
SELECT COUNT(*) as total_usuarios FROM public.users;

-- 4. VERIFICAR SE RLS ESTÁ ATIVADO
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public'
    AND tablename = 'users';

-- 5. VERIFICAR POLÍTICAS RLS
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
    AND tablename = 'users'
ORDER BY policyname;

-- =====================================================
-- CORREÇÕES AUTOMÁTICAS (EXECUTAR APENAS SE NECESSÁRIO)
-- =====================================================

-- 6. VERIFICAR E CORRIGIR ESTRUTURA DA TABELA EXISTENTE
DO $$ 
BEGIN
    -- Se a tabela não existir, criar
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
        CREATE TABLE public.users (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            email TEXT NOT NULL UNIQUE,
            full_name TEXT,
            role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'manager', 'technician', 'user')),
            status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            last_sign_in TIMESTAMP WITH TIME ZONE
        );
    ELSE
        -- Se a tabela existir, verificar e corrigir colunas
        -- Verificar se a coluna id tem DEFAULT
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'users' 
                AND column_name = 'id' 
                AND column_default IS NOT NULL
        ) THEN
            -- Adicionar DEFAULT para coluna id se não existir
            ALTER TABLE public.users ALTER COLUMN id SET DEFAULT gen_random_uuid();
        END IF;
        
        -- Verificar se a coluna id é UUID
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'users' 
                AND column_name = 'id' 
                AND data_type != 'uuid'
        ) THEN
            -- Converter coluna id para UUID se necessário
            ALTER TABLE public.users ALTER COLUMN id TYPE UUID USING id::uuid;
        END IF;
    END IF;
END $$;

-- 7. ADICIONAR COLUNAS SE NÃO EXISTIREM
DO $$ 
BEGIN
    -- Adicionar coluna role se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'role') THEN
        ALTER TABLE public.users ADD COLUMN role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'manager', 'technician', 'user'));
    END IF;
    
    -- Adicionar coluna status se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'status') THEN
        ALTER TABLE public.users ADD COLUMN status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending'));
    END IF;
    
    -- Adicionar coluna full_name se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'full_name') THEN
        ALTER TABLE public.users ADD COLUMN full_name TEXT;
    END IF;
    
    -- Adicionar coluna updated_at se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'updated_at') THEN
        ALTER TABLE public.users ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    -- Adicionar coluna last_sign_in se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'last_sign_in') THEN
        ALTER TABLE public.users ADD COLUMN last_sign_in TIMESTAMP WITH TIME ZONE;
    END IF;
    
    -- Verificar se a coluna id tem PRIMARY KEY
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND constraint_type = 'PRIMARY KEY'
    ) THEN
        -- Adicionar PRIMARY KEY se não existir
        ALTER TABLE public.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
    END IF;
    
    -- Verificar se a coluna email tem UNIQUE constraint
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND constraint_type = 'UNIQUE'
            AND constraint_name LIKE '%email%'
    ) THEN
        -- Adicionar UNIQUE constraint para email se não existir
        ALTER TABLE public.users ADD CONSTRAINT users_email_key UNIQUE (email);
    END IF;
END $$;

-- 8. ATIVAR RLS NA TABELA
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 9. CRIAR POLÍTICAS RLS BÁSICAS
-- Política para visualização (permitir para usuários autenticados)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid()::text = id::text);

-- Política para administradores verem todos os usuários
DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Política para inserção (permitir para administradores)
DROP POLICY IF EXISTS "Admins can insert users" ON public.users;
CREATE POLICY "Admins can insert users" ON public.users
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Política para atualização (permitir para administradores ou próprio usuário)
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Política para atualização por administradores
DROP POLICY IF EXISTS "Admins can update all users" ON public.users;
CREATE POLICY "Admins can update all users" ON public.users
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Política para exclusão (permitir apenas para administradores)
DROP POLICY IF EXISTS "Admins can delete users" ON public.users;
CREATE POLICY "Admins can delete users" ON public.users
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- 10. INSERIR USUÁRIO ADMIN PADRÃO SE NÃO EXISTIR
INSERT INTO public.users (id, email, full_name, role, status)
SELECT gen_random_uuid(), 'admin@ti-management.com', 'Administrador do Sistema', 'admin', 'active'
WHERE NOT EXISTS (SELECT 1 FROM public.users WHERE email = 'admin@ti-management.com');

-- 11. VERIFICAR SE AS CORREÇÕES FUNCIONARAM
SELECT 'Verificação final' as status;
SELECT COUNT(*) as total_usuarios FROM public.users;
SELECT role, COUNT(*) as quantidade FROM public.users GROUP BY role;
SELECT status, COUNT(*) as quantidade FROM public.users GROUP BY status;
