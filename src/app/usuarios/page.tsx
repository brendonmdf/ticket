"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Sidebar } from "@/components/sidebar"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { 
  Users, 
  UserPlus, 
  UserX, 
  Shield, 
  Mail, 
  Calendar,
  Search,
  Filter,
  MoreHorizontal,
  CheckCircle,
  AlertTriangle,
  XCircle
} from "lucide-react"
import { supabase } from "@/lib/supabase"

// Interface para usuários
interface User {
  id: string
  email: string
  full_name?: string
  role?: string
  status?: string
  created_at: string
  updated_at: string
  last_sign_in?: string
}

// Tipos de role disponíveis
const userRoles = [
  { value: 'admin', label: 'Administrador', color: 'bg-red-100 text-red-800' },
  { value: 'manager', label: 'Gerente', color: 'bg-blue-100 text-blue-800' },
  { value: 'technician', label: 'Técnico', color: 'bg-green-100 text-green-800' },
  { value: 'user', label: 'Usuário', color: 'bg-gray-100 text-gray-800' }
]

// Status de usuário
const userStatuses = [
  { value: 'active', label: 'Ativo', color: 'bg-green-100 text-green-800' },
  { value: 'inactive', label: 'Inativo', color: 'bg-red-100 text-red-800' },
  { value: 'pending', label: 'Pendente', color: 'bg-yellow-100 text-yellow-800' }
]

export default function UsuariosPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [roleFilter, setRoleFilter] = useState("all")
  const [statusFilter, setStatusFilter] = useState("all")
  
  // Estados para modais
  const [isAddUserOpen, setIsAddUserOpen] = useState(false)
  const [isEditUserOpen, setIsEditUserOpen] = useState(false)
  const [isDeleteUserOpen, setIsDeleteUserOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  
  // Estados para formulários
  const [newUser, setNewUser] = useState({
    email: "",
    full_name: "",
    role: "user",
    status: "active"
  })
  
  const [editUser, setEditUser] = useState({
    email: "",
    full_name: "",
    role: "user",
    status: "active"
  })

  // Buscar usuários do banco de dados
  const fetchUsers = async () => {
    try {
      setLoading(true)
      console.log('🔍 Iniciando busca de usuários...')
      
      const { data, error, count } = await supabase
        .from('users')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })

      console.log('📊 Resultado da consulta:', { data, error, count })

      if (error) {
        console.error('❌ Erro ao buscar usuários:', error)
        alert(`Erro ao buscar usuários: ${error.message}`)
        return
      }

      if (!data || data.length === 0) {
        console.log('⚠️ Nenhum usuário encontrado na consulta')
        setUsers([])
        return
      }

      console.log(`✅ ${data.length} usuários encontrados:`, data)

      // Garantir que todos os usuários tenham valores padrão válidos
      const usersWithDefaults = data.map(user => ({
        ...user,
        role: user.role || 'user',
        status: user.status || 'active'
      }))

      console.log('🔄 Usuários com valores padrão:', usersWithDefaults)
      setUsers(usersWithDefaults)
      
    } catch (error) {
      console.error('💥 Erro inesperado ao buscar usuários:', error)
      alert(`Erro inesperado: ${error}`)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchUsers()
  }, [])

  // Filtrar usuários
  const filteredUsers = users.filter(user => {
    const matchesSearch = user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (user.full_name && user.full_name.toLowerCase().includes(searchTerm.toLowerCase()))
    const matchesRole = roleFilter === "all" || user.role === roleFilter
    const matchesStatus = statusFilter === "all" || user.status === statusFilter
    
    return matchesSearch && matchesRole && matchesStatus
  })

  // Adicionar novo usuário
  const handleAddUser = async () => {
    try {
      const { data, error } = await supabase
        .from('users')
        .insert([{
          email: newUser.email,
          full_name: newUser.full_name || null,
          role: newUser.role,
          status: newUser.status
        }])
        .select()

      if (error) {
        console.error('Erro ao adicionar usuário:', error)
        alert(`Erro ao adicionar usuário: ${error.message}`)
        return
      }

      // Limpar formulário
      setNewUser({
        email: "",
        full_name: "",
        role: "user",
        status: "active"
      })

      // Fechar modal
      setIsAddUserOpen(false)

      // Recarregar lista
      fetchUsers()
      
      alert('Usuário adicionado com sucesso!')
    } catch (error) {
      console.error('Erro ao adicionar usuário:', error)
      alert(`Erro ao adicionar usuário: ${error}`)
    }
  }

  // Editar usuário
  const handleEditUser = async () => {
    if (!selectedUser) return

    try {
      const { error } = await supabase
        .from('users')
        .update({
          email: editUser.email,
          full_name: editUser.full_name || null,
          role: editUser.role,
          status: editUser.status,
          updated_at: new Date().toISOString()
        })
        .eq('id', selectedUser.id)

      if (error) {
        console.error('Erro ao editar usuário:', error)
        alert(`Erro ao editar usuário: ${error.message}`)
        return
      }

      // Fechar modal
      setIsEditUserOpen(false)
      setSelectedUser(null)

      // Recarregar lista
      fetchUsers()
      
      alert('Usuário atualizado com sucesso!')
    } catch (error) {
      console.error('Erro ao editar usuário:', error)
      alert(`Erro ao editar usuário: ${error}`)
    }
  }

  // Deletar usuário
  const handleDeleteUser = async () => {
    if (!selectedUser) return

    try {
      const { error } = await supabase
        .from('users')
        .delete()
        .eq('id', selectedUser.id)

      if (error) {
        console.error('Erro ao deletar usuário:', error)
        alert(`Erro ao deletar usuário: ${error.message}`)
        return
      }

      // Fechar modal
      setIsDeleteUserOpen(false)
      setSelectedUser(null)

      // Recarregar lista
      fetchUsers()
      
      alert('Usuário removido com sucesso!')
    } catch (error) {
      console.error('Erro ao deletar usuário:', error)
      alert(`Erro ao deletar usuário: ${error}`)
    }
  }

  // Abrir modal de edição
  const openEditModal = (user: User) => {
    setSelectedUser(user)
    setEditUser({
      email: user.email,
      full_name: user.full_name || "",
      role: user.role || "user",
      status: user.status || "active"
    })
    setIsEditUserOpen(true)
  }

  // Abrir modal de exclusão
  const openDeleteModal = (user: User) => {
    setSelectedUser(user)
    setIsDeleteUserOpen(true)
  }

  // Obter cor do role
  const getRoleColor = (role: string) => {
    const roleConfig = userRoles.find(r => r.value === role)
    return roleConfig?.color || 'bg-gray-100 text-gray-800'
  }

  // Obter cor do status
  const getStatusColor = (status: string) => {
    const statusConfig = userStatuses.find(s => s.value === status)
    return statusConfig?.color || 'bg-gray-100 text-gray-800'
  }

  // Obter label do role
  const getRoleLabel = (role: string) => {
    const roleConfig = userRoles.find(r => r.value === role)
    return roleConfig?.label || 'Usuário'
  }

  // Obter label do status
  const getStatusLabel = (status: string) => {
    const statusConfig = userStatuses.find(s => s.value === status)
    return statusConfig?.label || 'Desconhecido'
  }

  // Formatar data
  const formatDate = (dateString: string) => {
    try {
      return new Date(dateString).toLocaleString('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    } catch (error) {
      return 'Data inválida'
    }
  }

  if (loading) {
    return (
      <div className="flex h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex items-center justify-center">
          <div className="flex items-center gap-2">
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary"></div>
            <span>Carregando usuários...</span>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="flex h-screen bg-background">
      <Sidebar />
      
      <div className="flex-1 overflow-auto">
        <div className="p-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="mb-8"
          >
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-3xl font-bold tracking-tight">Gerenciamento de Usuários</h1>
                <p className="text-muted-foreground">
                  Gerencie todos os usuários do sistema, seus níveis de acesso e status.
                </p>
              </div>
              <Button onClick={() => setIsAddUserOpen(true)}>
                <UserPlus className="h-4 w-4 mr-2" />
                Adicionar Usuário
              </Button>
            </div>
          </motion.div>

          {/* Filtros e Busca */}
          <Card className="mb-6">
            <CardContent className="p-4">
              <div className="flex flex-col md:flex-row gap-4">
                <div className="flex-1">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Buscar por email ou nome..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10"
                    />
                  </div>
                </div>
                
                <Select value={roleFilter} onValueChange={(value) => setRoleFilter(value)}>
                  <SelectTrigger className="w-48">
                    <SelectValue placeholder="Filtrar por role" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos os roles</SelectItem>
                    {userRoles.map(role => (
                      <SelectItem key={role.value} value={role.value}>
                        {role.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>

                <Select value={statusFilter} onValueChange={(value) => setStatusFilter(value)}>
                  <SelectTrigger className="w-48">
                    <SelectValue placeholder="Filtrar por status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos os status</SelectItem>
                    {userStatuses.map(status => (
                      <SelectItem key={status.value} value={status.value}>
                        {status.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          {/* Lista de Usuários */}
          <div className="grid gap-4">
            {filteredUsers.length === 0 ? (
              <Card>
                <CardContent className="p-12 text-center">
                  <Users className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
                  <h3 className="text-lg font-semibold mb-2">Nenhum usuário encontrado</h3>
                                     <p className="text-muted-foreground">
                     {searchTerm || (roleFilter !== "all") || (statusFilter !== "all")
                       ? 'Tente ajustar os filtros de busca'
                       : 'Adicione seu primeiro usuário para começar'
                     }
                   </p>
                </CardContent>
              </Card>
            ) : (
              filteredUsers.map((user) => (
                <motion.div
                  key={user.id}
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ duration: 0.3 }}
                >
                  <Card className="hover:shadow-lg transition-shadow">
                    <CardContent className="p-6">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-4">
                          <div className="flex-shrink-0">
                            <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center">
                              <Users className="h-6 w-6 text-primary" />
                            </div>
                          </div>
                          
                          <div className="flex-1">
                            <div className="flex items-center gap-3 mb-2">
                              <h3 className="text-lg font-semibold">
                                {user.full_name || 'Sem nome'}
                              </h3>
                              <Badge className={getRoleColor(user.role || 'user')}>
                                {getRoleLabel(user.role || 'user')}
                              </Badge>
                              <Badge className={getStatusColor(user.status || 'active')}>
                                {getStatusLabel(user.status || 'active')}
                              </Badge>
                            </div>
                            
                            <div className="flex items-center gap-4 text-sm text-muted-foreground">
                              <div className="flex items-center gap-1">
                                <Mail className="h-4 w-4" />
                                {user.email}
                              </div>
                              <div className="flex items-center gap-1">
                                <Calendar className="h-4 w-4" />
                                Criado em {formatDate(user.created_at)}
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <div className="flex items-center gap-2">
                                                     <Button
                             variant="outline"
                             size="sm"
                             onClick={() => openEditModal(user)}
                           >
                             <UserPlus className="h-4 w-4 mr-2" />
                             Editar
                           </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => openDeleteModal(user)}
                            className="text-red-600 hover:text-red-700 hover:bg-red-50"
                          >
                            <UserX className="h-4 w-4 mr-2" />
                            Remover
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Modal para adicionar usuário */}
      <Dialog open={isAddUserOpen} onOpenChange={setIsAddUserOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Adicionar Novo Usuário</DialogTitle>
            <DialogDescription>
              Adicione um novo usuário ao sistema com suas permissões.
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium">Email</label>
              <Input
                type="email"
                placeholder="usuario@exemplo.com"
                value={newUser.email}
                onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-medium">Nome Completo (opcional)</label>
              <Input
                placeholder="Nome completo do usuário"
                value={newUser.full_name}
                onChange={(e) => setNewUser({ ...newUser, full_name: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-medium">Nível de Acesso</label>
              <Select value={newUser.role} onValueChange={(value) => setNewUser({ ...newUser, role: value })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {userRoles.map(role => (
                    <SelectItem key={role.value} value={role.value}>
                      {role.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <label className="text-sm font-medium">Status</label>
              <Select value={newUser.status} onValueChange={(value) => setNewUser({ ...newUser, status: value })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {userStatuses.map(status => (
                    <SelectItem key={status.value} value={status.value}>
                      {status.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="flex gap-2 pt-4">
              <Button variant="outline" onClick={() => setIsAddUserOpen(false)} className="flex-1">
                Cancelar
              </Button>
              <Button onClick={handleAddUser} className="flex-1" disabled={!newUser.email}>
                Adicionar
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Modal para editar usuário */}
      <Dialog open={isEditUserOpen} onOpenChange={setIsEditUserOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Editar Usuário</DialogTitle>
            <DialogDescription>
              Edite as informações e permissões do usuário.
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium">Email</label>
              <Input
                type="email"
                placeholder="usuario@exemplo.com"
                value={editUser.email}
                onChange={(e) => setEditUser({ ...editUser, email: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-medium">Nome Completo</label>
              <Input
                placeholder="Nome completo do usuário"
                value={editUser.full_name}
                onChange={(e) => setEditUser({ ...editUser, full_name: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-medium">Nível de Acesso</label>
              <Select value={editUser.role} onValueChange={(value) => setEditUser({ ...editUser, role: value })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {userRoles.map(role => (
                    <SelectItem key={role.value} value={role.value}>
                      {role.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <label className="text-sm font-medium">Status</label>
              <Select value={editUser.status} onValueChange={(value) => setEditUser({ ...editUser, status: value })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {userStatuses.map(status => (
                    <SelectItem key={status.value} value={status.value}>
                      {status.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="flex gap-2 pt-4">
              <Button variant="outline" onClick={() => setIsEditUserOpen(false)} className="flex-1">
                Cancelar
              </Button>
              <Button onClick={handleEditUser} className="flex-1">
                Salvar Alterações
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Modal para confirmar exclusão */}
      <Dialog open={isDeleteUserOpen} onOpenChange={setIsDeleteUserOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Confirmar Exclusão</DialogTitle>
            <DialogDescription>
              Tem certeza que deseja remover este usuário? Esta ação não pode ser desfeita.
            </DialogDescription>
          </DialogHeader>
          
          {selectedUser && (
            <div className="p-4 bg-red-50 rounded-lg border border-red-200">
              <div className="flex items-center gap-2 text-red-800">
                <AlertTriangle className="h-5 w-5" />
                <span className="font-medium">Usuário: {selectedUser.full_name || selectedUser.email}</span>
              </div>
            </div>
          )}
          
          <div className="flex gap-2 pt-4">
            <Button variant="outline" onClick={() => setIsDeleteUserOpen(false)} className="flex-1">
              Cancelar
            </Button>
            <Button 
              onClick={handleDeleteUser} 
              className="flex-1 bg-red-600 hover:bg-red-700"
            >
              <UserX className="h-4 w-4 mr-2" />
              Remover Usuário
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
