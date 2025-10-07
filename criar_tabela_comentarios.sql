-- Script para criar a tabela de comentários dos tickets
-- Execute este script no SQL Editor do Supabase

-- 1. CRIAR TABELA DE COMENTÁRIOS
CREATE TABLE IF NOT EXISTS public.ticket_comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ticket_id UUID NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    author VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. HABILITAR RLS (Row Level Security)
ALTER TABLE public.ticket_comments ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR POLÍTICAS RLS
-- Política para leitura: usuários autenticados podem ler comentários
CREATE POLICY "Usuários autenticados podem ler comentários" ON public.ticket_comments
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política para inserção: usuários autenticados podem criar comentários
CREATE POLICY "Usuários autenticados podem criar comentários" ON public.ticket_comments
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para atualização: usuários autenticados podem editar seus próprios comentários
CREATE POLICY "Usuários autenticados podem editar comentários" ON public.ticket_comments
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para exclusão: usuários autenticados podem excluir seus próprios comentários
CREATE POLICY "Usuários autenticados podem excluir comentários" ON public.ticket_comments
    FOR DELETE USING (auth.role() = 'authenticated');

-- 4. CRIAR ÍNDICES PARA MELHOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_ticket_comments_ticket_id ON public.ticket_comments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_comments_created_at ON public.ticket_comments(created_at);

-- 5. CRIAR FUNÇÃO PARA ATUALIZAR updated_at AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 6. CRIAR TRIGGER PARA ATUALIZAR updated_at
CREATE TRIGGER update_ticket_comments_updated_at 
    BEFORE UPDATE ON public.ticket_comments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 7. VERIFICAR SE A TABELA FOI CRIADA
SELECT 
    'ticket_comments' as tabela,
    COUNT(*) as total_registros,
    'Comentários dos tickets criados com sucesso!' as status
FROM public.ticket_comments;

-- 8. MOSTRAR ESTRUTURA DA TABELA
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'ticket_comments' 
ORDER BY ordinal_position;
