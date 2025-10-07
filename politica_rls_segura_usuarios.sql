-- POLÍTICA RLS SEGURA PARA TABELA USERS
-- Execute este script APÓS desabilitar RLS temporariamente

-- 1. PRIMEIRO, DESABILITAR RLS
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

-- 3. HABILITAR RLS NOVAMENTE
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS SEGURAS (SEM RECURSÃO)
-- Política para visualização: permitir acesso a usuários autenticados
CREATE POLICY "Allow authenticated users to view users" ON public.users
  FOR SELECT USING (auth.role() = 'authenticated');

-- Política para inserção: permitir inserção por usuários autenticados
CREATE POLICY "Allow authenticated users to insert users" ON public.users
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para atualização: permitir atualização por usuários autenticados
CREATE POLICY "Allow authenticated users to update users" ON public.users
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para exclusão: permitir exclusão por usuários autenticados
CREATE POLICY "Allow authenticated users to delete users" ON public.users
  FOR DELETE USING (auth.role() = 'authenticated');

-- 5. VERIFICAR SE AS POLÍTICAS FORAM CRIADAS
SELECT 
  'POLÍTICAS CRIADAS' as tipo,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'users' AND schemaname = 'public';

-- 6. TESTAR CONSULTA COM RLS ATIVO
SELECT 
  'TESTE COM RLS' as tipo,
  id,
  email,
  full_name,
  role,
  status,
  created_at
FROM public.users
ORDER BY created_at DESC;

-- 7. VERIFICAR STATUS FINAL
SELECT 
  'STATUS FINAL' as tipo,
  schemaname,
  tablename,
  rowsecurity,
  'RLS ativo com políticas seguras' as descricao
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';
