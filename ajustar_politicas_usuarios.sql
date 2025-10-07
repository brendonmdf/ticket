-- Script para ajustar as políticas RLS da tabela users
-- Execute este script no SQL Editor do Supabase

-- 1. REMOVER POLÍTICAS EXISTENTES (se houver)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;

-- 2. CRIAR POLÍTICA PERMISSIVA PARA DESENVOLVIMENTO
-- ⚠️ ATENÇÃO: Esta política permite acesso total - use apenas para desenvolvimento/teste
CREATE POLICY "Allow all operations for development" ON public.users
  FOR ALL USING (true);

-- 3. VERIFICAR SE A POLÍTICA FOI CRIADA
SELECT 
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'users' AND schemaname = 'public';

-- 4. TESTAR ACESSO
-- Execute esta consulta para verificar se está funcionando:
SELECT 
  id,
  email,
  full_name,
  role,
  status,
  created_at
FROM public.users
ORDER BY created_at DESC;

-- 5. ALTERNATIVA: POLÍTICA MAIS SEGURA (comentada)
/*
-- Descomente estas linhas quando quiser implementar segurança adequada:

-- Política para visualização (usuários logados podem ver todos)
CREATE POLICY "Authenticated users can view all users" ON public.users
  FOR SELECT USING (auth.role() = 'authenticated');

-- Política para inserção (usuários logados podem criar)
CREATE POLICY "Authenticated users can insert users" ON public.users
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para atualização (usuários logados podem atualizar)
CREATE POLICY "Authenticated users can update users" ON public.users
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para exclusão (usuários logados podem deletar)
CREATE POLICY "Authenticated users can delete users" ON public.users
  FOR DELETE USING (auth.role() = 'authenticated');
*/
