import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { supabase, getCurrentUser, signOut } from '@/lib/supabase'
import type { AuthUser } from '@/lib/supabase'

export const useAuth = () => {
  const [user, setUser] = useState<AuthUser | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  // Verificar usuário atual na inicialização
  useEffect(() => {
    const checkUser = async () => {
      try {
        setLoading(true)
        const currentUser = await getCurrentUser()
        setUser(currentUser)
        setError(null)
      } catch (err) {
        setError('Erro ao verificar usuário')
        console.error('Erro ao verificar usuário:', err)
      } finally {
        setLoading(false)
      }
    }

    checkUser()

    // Escutar mudanças na autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event === 'SIGNED_IN' && session?.user) {
          try {
            const currentUser = await getCurrentUser()
            setUser(currentUser)
            setError(null)
          } catch (err) {
            setError('Erro ao obter perfil do usuário')
          }
        } else if (event === 'SIGNED_OUT') {
          setUser(null)
          setError(null)
        }
        setLoading(false)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  // Função de login
  const signIn = async (email: string, password: string) => {
    try {
      setLoading(true)
      setError(null)

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) {
        setError(error.message)
        return { success: false, error: error.message }
      }

      if (data.user) {
        // Buscar perfil do usuário
        const currentUser = await getCurrentUser()
        setUser(currentUser)
        
        // Redirecionar para dashboard
        router.push('/dashboard')
        return { success: true, user: currentUser }
      }

      return { success: false, error: 'Erro desconhecido no login' }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro inesperado'
      setError(errorMessage)
      return { success: false, error: errorMessage }
    } finally {
      setLoading(false)
    }
  }

  // Função de registro
  const signUp = async (email: string, password: string, fullName: string) => {
    try {
      setLoading(true)
      setError(null)

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName,
          },
        },
      })

      if (error) {
        setError(error.message)
        return { success: false, error: error.message }
      }

      if (data.user) {
        // Criar perfil do usuário na tabela users
        const { error: profileError } = await supabase
          .from('users')
          .insert([
            {
              id: data.user.id,
              email: data.user.email!,
              full_name: fullName,
              role: 'user', // Role padrão
            },
          ])

        if (profileError) {
          console.error('Erro ao criar perfil:', profileError)
          // Não falhar o registro se houver erro no perfil
        }

        return { 
          success: true, 
          message: 'Verifique seu email para confirmar a conta',
          user: data.user 
        }
      }

      return { success: false, error: 'Erro desconhecido no registro' }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro inesperado'
      setError(errorMessage)
      return { success: false, error: errorMessage }
    } finally {
      setLoading(false)
    }
  }

  // Função de logout
  const handleSignOut = async () => {
    try {
      setLoading(true)
      const success = await signOut()
      
      if (success) {
        setUser(null)
        setError(null)
        router.push('/')
        return { success: true }
      } else {
        setError('Erro ao fazer logout')
        return { success: false, error: 'Erro ao fazer logout' }
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro inesperado'
      setError(errorMessage)
      return { success: false, error: errorMessage }
    } finally {
      setLoading(false)
    }
  }

  // Função para redefinir senha
  const resetPassword = async (email: string) => {
    try {
      setLoading(true)
      setError(null)

      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      })

      if (error) {
        setError(error.message)
        return { success: false, error: error.message }
      }

      return { 
        success: true, 
        message: 'Email de redefinição enviado com sucesso' 
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro inesperado'
      setError(errorMessage)
      return { success: false, error: errorMessage }
    } finally {
      setLoading(false)
    }
  }

  // Função para atualizar perfil
  const updateProfile = async (updates: Partial<AuthUser>) => {
    try {
      setLoading(true)
      setError(null)

      if (!user) {
        setError('Usuário não autenticado')
        return { success: false, error: 'Usuário não autenticado' }
      }

      const { error } = await supabase
        .from('users')
        .update(updates)
        .eq('id', user.id)

      if (error) {
        setError(error.message)
        return { success: false, error: error.message }
      }

      // Atualizar usuário local
      const updatedUser = await getCurrentUser()
      setUser(updatedUser)

      return { success: true, user: updatedUser }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro inesperado'
      setError(errorMessage)
      return { success: false, error: errorMessage }
    } finally {
      setLoading(false)
    }
  }

  // Verificar se o usuário tem role específico
  const hasRole = (requiredRole: string) => {
    return user?.role === requiredRole
  }

  // Verificar se o usuário tem pelo menos um dos roles
  const hasAnyRole = (requiredRoles: string[]) => {
    return user?.role ? requiredRoles.includes(user.role) : false
  }

  // Verificar se o usuário está autenticado
  const isAuthenticated = () => {
    return user !== null
  }

  return {
    // Estado
    user,
    loading,
    error,
    
    // Funções
    signIn,
    signUp,
    signOut: handleSignOut,
    resetPassword,
    updateProfile,
    
    // Verificações
    hasRole,
    hasAnyRole,
    isAuthenticated,
    
    // Utilitários
    clearError: () => setError(null),
  }
}
