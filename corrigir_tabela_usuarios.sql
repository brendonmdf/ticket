-- =====================================================
-- CORREÇÃO DIRETA DA TABELA DE USUÁRIOS
-- =====================================================

-- 1. VERIFICAR ESTRUTURA ATUAL
SELECT 'Estrutura atual da tabela users:' as info;
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'users'
ORDER BY ordinal_position;

-- 2. CORRIGIR COLUNA ID (se necessário)
DO $$ 
BEGIN
    -- Verificar se a coluna id existe e tem o tipo correto
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND column_name = 'id'
    ) THEN
        -- Se a coluna id não tem DEFAULT, adicionar
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'users' 
                AND column_name = 'id' 
                AND column_default IS NOT NULL
        ) THEN
            ALTER TABLE public.users ALTER COLUMN id SET DEFAULT gen_random_uuid();
            RAISE NOTICE 'DEFAULT adicionado para coluna id';
        END IF;
        
        -- Se a coluna id não é UUID, converter
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
                AND table_name = 'users' 
                AND column_name = 'id' 
                AND data_type != 'uuid'
        ) THEN
            ALTER TABLE public.users ALTER COLUMN id TYPE UUID USING id::uuid;
            RAISE NOTICE 'Coluna id convertida para UUID';
        END IF;
    ELSE
        -- Se a coluna id não existe, criar
        ALTER TABLE public.users ADD COLUMN id UUID DEFAULT gen_random_uuid() PRIMARY KEY;
        RAISE NOTICE 'Coluna id criada';
    END IF;
END $$;

-- 3. ADICIONAR COLUNAS FALTANTES
DO $$ 
BEGIN
    -- Adicionar coluna role se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND column_name = 'role'
    ) THEN
        ALTER TABLE public.users ADD COLUMN role TEXT DEFAULT 'user';
        RAISE NOTICE 'Coluna role adicionada';
    END IF;
    
    -- Adicionar coluna status se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND column_name = 'status'
    ) THEN
        ALTER TABLE public.users ADD COLUMN status TEXT DEFAULT 'active';
        RAISE NOTICE 'Coluna status adicionada';
    END IF;
    
    -- Adicionar coluna full_name se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND column_name = 'full_name'
    ) THEN
        ALTER TABLE public.users ADD COLUMN full_name TEXT;
        RAISE NOTICE 'Coluna full_name adicionada';
    END IF;
    
    -- Adicionar coluna updated_at se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE public.users ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Coluna updated_at adicionada';
    END IF;
    
    -- Adicionar coluna last_sign_in se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND column_name = 'last_sign_in'
    ) THEN
        ALTER TABLE public.users ADD COLUMN last_sign_in TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Coluna last_sign_in adicionada';
    END IF;
END $$;

-- 4. ADICIONAR CONSTRAINTS SE NÃO EXISTIREM
DO $$ 
BEGIN
    -- Adicionar PRIMARY KEY se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE public.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
        RAISE NOTICE 'PRIMARY KEY adicionado';
    END IF;
    
    -- Adicionar UNIQUE constraint para email se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND constraint_type = 'UNIQUE'
            AND constraint_name LIKE '%email%'
    ) THEN
        ALTER TABLE public.users ADD CONSTRAINT users_email_key UNIQUE (email);
        RAISE NOTICE 'UNIQUE constraint para email adicionado';
    END IF;
END $$;

-- 5. ATIVAR RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR POLÍTICAS RLS BÁSICAS
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

-- 7. INSERIR USUÁRIO ADMIN PADRÃO SE NÃO EXISTIR
INSERT INTO public.users (id, email, full_name, role, status)
SELECT gen_random_uuid(), 'admin@ti-management.com', 'Administrador do Sistema', 'admin', 'active'
WHERE NOT EXISTS (SELECT 1 FROM public.users WHERE email = 'admin@ti-management.com');

-- 8. VERIFICAÇÃO FINAL
SELECT 'Verificação final da tabela users:' as info;
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'users'
ORDER BY ordinal_position;

SELECT 'Total de usuários:' as info, COUNT(*) as quantidade FROM public.users;
SELECT 'Usuários por role:' as info, role, COUNT(*) as quantidade FROM public.users GROUP BY role;
SELECT 'Usuários por status:' as info, status, COUNT(*) as quantidade FROM public.users GROUP BY status;
