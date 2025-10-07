-- DIAGNÓSTICO COMPLETO DA TABELA USERS
-- Execute este script no SQL Editor do Supabase

-- 1. VERIFICAR SE A TABELA EXISTE E SUA ESTRUTURA
SELECT 
  'TABELA' as tipo,
  schemaname,
  tablename,
  tableowner,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';

-- 2. VERIFICAR COLUNAS DA TABELA
SELECT 
  'COLUNAS' as tipo,
  column_name,
  data_type,
  is_nullable,
  column_default,
  ordinal_position
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'users'
ORDER BY ordinal_position;

-- 3. VERIFICAR DADOS EXISTENTES
SELECT 
  'DADOS' as tipo,
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN role IS NULL THEN 1 END) as usuarios_sem_role,
  COUNT(CASE WHEN status IS NULL THEN 1 END) as usuarios_sem_status,
  COUNT(CASE WHEN email IS NULL THEN 1 END) as usuarios_sem_email
FROM public.users;

-- 4. VERIFICAR POLÍTICAS RLS ATIVAS
SELECT 
  'POLÍTICAS RLS' as tipo,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'users' AND schemaname = 'public';

-- 5. VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
  'RLS STATUS' as tipo,
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';

-- 6. TESTAR CONSULTA SIMPLES (sem RLS)
SELECT 
  'TESTE SIMPLES' as tipo,
  id,
  email,
  full_name,
  role,
  status,
  created_at
FROM public.users
ORDER BY created_at DESC;

-- 7. VERIFICAR PERMISSÕES DO USUÁRIO ANON
SELECT 
  'PERMISSÕES ANON' as tipo,
  grantee,
  table_name,
  privilege_type
FROM information_schema.table_privileges 
WHERE table_name = 'users' AND table_schema = 'public';

-- 8. VERIFICAR SE EXISTEM CONSTRAINTS PROBLEMÁTICOS
SELECT 
  'CONSTRAINTS' as tipo,
  constraint_name,
  constraint_type,
  table_name
FROM information_schema.table_constraints 
WHERE table_name = 'users' AND table_schema = 'public';

-- 9. VERIFICAR SE A TABELA TEM DADOS REAIS
SELECT 
  'DADOS REAIS' as tipo,
  id,
  email,
  full_name,
  role,
  status,
  created_at,
  updated_at
FROM public.users
LIMIT 10;
