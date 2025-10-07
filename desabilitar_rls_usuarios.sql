-- DESABILITAR RLS TEMPORARIAMENTE PARA TESTE
-- ⚠️ ATENÇÃO: Este script remove toda a segurança da tabela
-- Use apenas para desenvolvimento/teste

-- 1. DESABILITAR RLS
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
DROP POLICY IF EXISTS "Allow all operations for development" ON public.users;

-- 3. VERIFICAR SE RLS FOI DESABILITADO
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';

-- 4. VERIFICAR SE NÃO HÁ MAIS POLÍTICAS
SELECT 
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'users' AND schemaname = 'public';

-- 5. TESTAR CONSULTA AGORA
SELECT 
  id,
  email,
  full_name,
  role,
  status,
  created_at
FROM public.users
ORDER BY created_at DESC;

-- 6. VERIFICAR PERMISSÕES
SELECT 
  grantee,
  table_name,
  privilege_type
FROM information_schema.table_privileges 
WHERE table_name = 'users' AND table_schema = 'public';
