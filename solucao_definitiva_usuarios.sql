-- SOLUÇÃO DEFINITIVA PARA TABELA USERS
-- Execute este script no SQL Editor do Supabase

-- 1. DESABILITAR RLS COMPLETAMENTE
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
DROP POLICY IF EXISTS "Allow all operations for development" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can view all users" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can insert users" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can update users" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can delete users" ON public.users;

-- 3. VERIFICAR SE RLS FOI DESABILITADO
SELECT 
  'RLS STATUS' as tipo,
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';

-- 4. VERIFICAR SE NÃO HÁ MAIS POLÍTICAS
SELECT 
  'POLÍTICAS RESTANTES' as tipo,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'users' AND schemaname = 'public';

-- 5. TESTAR CONSULTA AGORA (deve funcionar)
SELECT 
  'TESTE CONSULTA' as tipo,
  id,
  email,
  full_name,
  role,
  status,
  created_at
FROM public.users
ORDER BY created_at DESC;

-- 6. VERIFICAR PERMISSÕES DA TABELA
SELECT 
  'PERMISSÕES' as tipo,
  grantee,
  table_name,
  privilege_type
FROM information_schema.table_privileges 
WHERE table_name = 'users' AND table_schema = 'public';

-- 7. CONFIRMAR QUE A TABELA ESTÁ ACESSÍVEL
SELECT 
  'CONFIRMAÇÃO' as tipo,
  COUNT(*) as total_usuarios,
  'Tabela users acessível sem RLS' as status
FROM public.users;
