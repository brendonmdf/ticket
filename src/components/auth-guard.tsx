"use client"

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/hooks/useAuth'

interface AuthGuardProps {
  children: React.ReactNode
  requiredRoles?: string[]
  fallback?: React.ReactNode
}

export const AuthGuard = ({ 
  children, 
  requiredRoles = [], 
  fallback = null 
}: AuthGuardProps) => {
  const { user, loading, isAuthenticated, hasAnyRole } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!loading) {
      // Se não está autenticado, redirecionar para login
      if (!isAuthenticated()) {
        router.push('/')
        return
      }

      // Se há roles requeridos, verificar se o usuário tem permissão
      if (requiredRoles.length > 0 && !hasAnyRole(requiredRoles)) {
        router.push('/unauthorized')
        return
      }
    }
  }, [loading, user, requiredRoles, router, isAuthenticated, hasAnyRole])

  // Mostrar loading enquanto verifica autenticação
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-blue-600 border-t-transparent mx-auto mb-4" />
          <p className="text-gray-600">Verificando autenticação...</p>
        </div>
      </div>
    )
  }

  // Se não está autenticado, mostrar fallback ou nada
  if (!isAuthenticated()) {
    return fallback || null
  }

  // Se há roles requeridos e o usuário não tem permissão
  if (requiredRoles.length > 0 && !hasAnyRole(requiredRoles)) {
    return fallback || (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600 mb-2">Acesso Negado</h1>
          <p className="text-gray-600">Você não tem permissão para acessar esta página.</p>
        </div>
      </div>
    )
  }

  // Usuário autenticado e com permissão, mostrar conteúdo
  return <>{children}</>
}

// Componente específico para rotas que requerem admin
export const AdminGuard = ({ children, fallback }: { children: React.ReactNode, fallback?: React.ReactNode }) => (
  <AuthGuard requiredRoles={['admin']} fallback={fallback}>
    {children}
  </AuthGuard>
)

// Componente específico para rotas que requerem manager ou admin
export const ManagerGuard = ({ children, fallback }: { children: React.ReactNode, fallback?: React.ReactNode }) => (
  <AuthGuard requiredRoles={['admin', 'manager']} fallback={fallback}>
    {children}
  </AuthGuard>
)

// Componente específico para rotas que requerem technician ou superior
export const TechnicianGuard = ({ children, fallback }: { children: React.ReactNode, fallback?: React.ReactNode }) => (
  <AuthGuard requiredRoles={['admin', 'manager', 'technician']} fallback={fallback}>
    {children}
  </AuthGuard>
)
