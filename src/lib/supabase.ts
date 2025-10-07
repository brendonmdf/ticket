import { createClient } from '@supabase/supabase-js'

// Verificar se as variáveis de ambiente estão configuradas
if (!process.env.NEXT_PUBLIC_SUPABASE_URL) {
  throw new Error('NEXT_PUBLIC_SUPABASE_URL não está configurada')
}

if (!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
  throw new Error('NEXT_PUBLIC_SUPABASE_ANON_KEY não está configurada')
}

// Criar cliente Supabase
export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  {
    auth: {
      // Configurações de autenticação
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true,
      flowType: 'pkce',
    },
    // Configurações de banco de dados
    db: {
      schema: 'public'
    },
    // Configurações globais
    global: {
      headers: {
        'X-Client-Info': 'ti-management-system'
      }
    }
  }
)

// Tipos para autenticação
export type AuthUser = {
  id: string
  email: string
  role?: string
  full_name?: string
}

// Função para obter usuário atual
export const getCurrentUser = async () => {
  try {
    const { data: { user }, error } = await supabase.auth.getUser()
    
    if (error) {
      console.error('Erro ao obter usuário:', error)
      return null
    }
    
    if (user) {
      // Buscar informações adicionais do usuário na tabela users
      const { data: userProfile, error: profileError } = await supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single()
      
      if (profileError) {
        console.error('Erro ao buscar perfil do usuário:', profileError)
        return user
      }
      
      return { ...user, ...userProfile }
    }
    
    return null
  } catch (error) {
    console.error('Erro inesperado ao obter usuário:', error)
    return null
  }
}

// Função para fazer logout
export const signOut = async () => {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) {
      console.error('Erro ao fazer logout:', error)
      return false
    }
    return true
  } catch (error) {
    console.error('Erro inesperado ao fazer logout:', error)
    return false
  }
}

// Função para verificar se o usuário está autenticado
export const isAuthenticated = async () => {
  const user = await getCurrentUser()
  return user !== null
}

// Função para verificar role do usuário
export const hasRole = async (requiredRole: string) => {
  const user = await getCurrentUser()
  if (!user) return false
  
  // Verificar se o usuário tem o role necessário
  return user.role === requiredRole
}

// Função para verificar se o usuário tem pelo menos um dos roles
export const hasAnyRole = async (requiredRoles: string[]) => {
  const user = await getCurrentUser()
  if (!user) return false
  
  return requiredRoles.includes(user.role || '')
}

// Hook para autenticação (para usar em componentes)
export const useAuth = () => {
  return {
    user: null, // Será implementado com useState e useEffect
    signOut,
    isAuthenticated,
    hasRole,
    hasAnyRole
  }
}
