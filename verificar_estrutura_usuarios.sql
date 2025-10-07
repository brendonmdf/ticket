-- Script para verificar e corrigir a estrutura da tabela users
-- Execute este script no SQL Editor do Supabase

-- 1. VERIFICAR SE A TABELA EXISTE
SELECT 
  schemaname,
  tablename,
  tableowner
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';

-- 2. VERIFICAR ESTRUTURA DA TABELA (se existir)
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    RAISE NOTICE 'Tabela users existe. Verificando estrutura...';
    
    -- Verificar colunas
    RAISE NOTICE 'Colunas da tabela users:';
    PERFORM column_name, data_type, is_nullable, column_default
    FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'users'
    ORDER BY ordinal_position;
    
  ELSE
    RAISE NOTICE 'Tabela users NÃO existe. Criando...';
    
    -- Criar tabela users
    CREATE TABLE public.users (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      full_name TEXT,
      role TEXT DEFAULT 'user',
      status TEXT DEFAULT 'active',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      last_sign_in TIMESTAMP WITH TIME ZONE
    );
    
    -- Habilitar RLS
    ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
    
    -- Criar políticas RLS
    CREATE POLICY "Users can view their own profile" ON public.users
      FOR SELECT USING (auth.uid()::text = id::text);
    
    CREATE POLICY "Users can update their own profile" ON public.users
      FOR UPDATE USING (auth.uid()::text = id::text);
    
    CREATE POLICY "Admins can manage all users" ON public.users
      FOR ALL USING (
        EXISTS (
          SELECT 1 FROM public.users 
          WHERE id = auth.uid()::text AND role = 'admin'
        )
      );
    
    RAISE NOTICE 'Tabela users criada com sucesso!';
  END IF;
END $$;

-- 3. VERIFICAR DADOS EXISTENTES
SELECT 
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN role IS NULL THEN 1 END) as usuarios_sem_role,
  COUNT(CASE WHEN status IS NULL THEN 1 END) as usuarios_sem_status
FROM public.users;

-- 4. VERIFICAR RLS
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';

-- 5. VERIFICAR POLÍTICAS RLS
SELECT 
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'users' AND schemaname = 'public';

-- 6. INSERIR USUÁRIO ADMIN SE NÃO EXISTIR
INSERT INTO public.users (email, full_name, role, status)
SELECT 'admin@ti-management.com', 'Administrador do Sistema', 'admin', 'active'
WHERE NOT EXISTS (
  SELECT 1 FROM public.users WHERE email = 'admin@ti-management.com'
);

-- 7. VERIFICAR RESULTADO FINAL
SELECT 
  id,
  email,
  full_name,
  role,
  status,
  created_at
FROM public.users
ORDER BY created_at DESC;
