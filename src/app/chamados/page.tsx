"use client"

import { useState, useEffect } from "react"
import { motion } from "framer-motion"
import { Sidebar } from "@/components/sidebar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { 
  FileText, 
  Plus, 
  Search, 
  Filter, 
  Eye, 
  User, 
  Clock, 
  MessageSquare,
  CheckCircle,
  AlertCircle,
  XCircle,
  MoreHorizontal,
  ArrowUpDown,
  RefreshCw
} from "lucide-react"
import { supabase } from "@/lib/supabase"

// Interface para os tickets
interface Ticket {
  id: string
  ticket_number: string
  title: string
  description: string
  status: string
  priority: string
  category: string
  requester_name: string
  requester_email: string
  requester_phone?: string
  unit_name?: string
  source: string
  created_at: string
  updated_at: string
}

// Interface para comentários
interface Comment {
  id: string
  ticket_id: string
  content: string
  author: string
  created_at: string
}

const statusOptions = [
  { value: "new", label: "Novo", color: "bg-blue-100 text-blue-800" },
  { value: "open", label: "Aberto", color: "bg-orange-100 text-orange-800" },
  { value: "in_progress", label: "Em andamento", color: "bg-yellow-100 text-yellow-800" },
  { value: "resolved", label: "Resolvido", color: "bg-green-100 text-green-800" },
  { value: "closed", label: "Fechado", color: "bg-gray-100 text-gray-800" },
  { value: "cancelled", label: "Cancelado", color: "bg-red-100 text-red-800" }
]

const priorityOptions = [
  { value: "low", label: "Baixa", color: "bg-green-100 text-green-800" },
  { value: "medium", label: "Média", color: "bg-yellow-100 text-yellow-800" },
  { value: "high", label: "Alta", color: "bg-orange-100 text-orange-800" },
  { value: "critical", label: "Crítica", color: "bg-red-100 text-red-800" }
]

const getStatusIcon = (status: string) => {
  switch (status) {
    case "new":
      return <div className="h-2 w-2 rounded-full bg-blue-500" />
    case "open":
      return <div className="h-2 w-2 rounded-full bg-orange-500" />
    case "in_progress":
      return <Clock className="h-4 w-4 text-yellow-500" />
    case "resolved":
      return <CheckCircle className="h-4 w-4 text-green-500" />
    case "closed":
      return <div className="h-2 w-2 rounded-full bg-gray-500" />
    case "cancelled":
      return <XCircle className="h-4 w-4 text-red-500" />
    default:
      return <div className="h-2 w-2 rounded-full bg-gray-500" />
  }
}

const getPriorityIcon = (priority: string) => {
  switch (priority) {
    case "critical":
      return <ArrowUpDown className="h-4 w-4 text-red-500 rotate-90" />
    case "high":
      return <ArrowUpDown className="h-4 w-4 text-orange-500 rotate-90" />
    case "medium":
      return <ArrowUpDown className="h-4 w-4 text-yellow-500" />
    case "low":
      return <ArrowUpDown className="h-4 w-4 text-green-500 -rotate-90" />
    default:
      return <ArrowUpDown className="h-4 w-4 text-gray-500" />
  }
}

const getStatusLabel = (status: string) => {
  const option = statusOptions.find(opt => opt.value === status)
  return option ? option.label : status
}

const getPriorityLabel = (priority: string) => {
  const option = priorityOptions.find(opt => opt.value === priority)
  return option ? option.label : priority
}

// Componente TicketCard para reutilização
const TicketCard = ({ ticket, onViewDetails }: { ticket: Ticket, onViewDetails: (ticket: Ticket) => void }) => {
  const getBorderColor = (status: string) => {
    switch (status) {
      case "new":
        return "border-l-blue-500"
      case "open":
      case "in_progress":
        return "border-l-yellow-500"
      case "resolved":
      case "closed":
        return "border-l-green-500"
      default:
        return "border-l-gray-500"
    }
  }

  // Função formatDate local para o componente
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <Card className={`hover:shadow-md transition-shadow border-l-4 ${getBorderColor(ticket.status)}`}>
      <CardContent className="p-4">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-2">
              <Badge variant="secondary" className={statusOptions.find(s => s.value === ticket.status)?.color}>
                {getStatusLabel(ticket.status)}
              </Badge>
              <Badge variant="outline" className={priorityOptions.find(p => p.value === ticket.priority)?.color}>
                {getPriorityLabel(ticket.priority)}
              </Badge>
            </div>
            <h3 className="text-lg font-semibold mb-2">{ticket.title}</h3>
            <p className="text-muted-foreground mb-3 line-clamp-2">
              {ticket.description}
            </p>
            <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
              <div className="flex items-center gap-1">
                <User className="h-4 w-4" />
                <span>{ticket.requester_name}</span>
              </div>
              {ticket.unit_name && (
                <div className="flex items-center gap-1">
                  <FileText className="h-4 w-4" />
                  <span>{ticket.unit_name}</span>
                </div>
              )}
              <div className="flex items-center gap-1">
                <Clock className="h-4 w-4" />
                <span>Criado em {formatDate(ticket.created_at)}</span>
              </div>
            </div>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() => onViewDetails(ticket)}
          >
            <Eye className="h-4 w-4 mr-2" />
            Ver detalhes
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}

export default function ChamadosPage() {
  const [tickets, setTickets] = useState<Ticket[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("todos")
  const [selectedTicket, setSelectedTicket] = useState<Ticket | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)
  const [newComment, setNewComment] = useState("")
  const [comments, setComments] = useState<Comment[]>([])
  const [loadingComments, setLoadingComments] = useState(false)
  const [tempStatus, setTempStatus] = useState<string>("")
  const [updatingStatus, setUpdatingStatus] = useState(false)

  // Buscar tickets do banco de dados
  const fetchTickets = async () => {
    try {
      console.log('🔄 Buscando tickets...')
      setLoading(true)
      const { data, error } = await supabase
        .from('tickets')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) {
        console.error('❌ Erro ao buscar tickets:', error)
        return
      }

      console.log('✅ Tickets carregados:', data?.length || 0)
      setTickets(data || [])
    } catch (error) {
      console.error('❌ Erro inesperado ao buscar tickets:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTickets()
  }, [])

  const filteredTickets = tickets.filter(ticket => {
    const matchesSearch = ticket.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ticket.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ticket.requester_name.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "todos" || ticket.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const newTickets = filteredTickets.filter(ticket => ticket.status === "new")
  const openTickets = filteredTickets.filter(ticket => ticket.status === "open")
  const inProgressTickets = filteredTickets.filter(ticket => ticket.status === "in_progress")
  const resolvedTickets = filteredTickets.filter(ticket => ticket.status === "resolved")
  const closedTickets = filteredTickets.filter(ticket => ticket.status === "closed")

  const handleViewDetails = (ticket: Ticket) => {
    setSelectedTicket(ticket)
    setTempStatus(ticket.status) // Inicializar status temporário
    setIsDetailOpen(true)
    // Buscar comentários do ticket
    fetchComments(ticket.id)
  }

  const handleStatusChange = async () => {
    if (!selectedTicket) {
      console.error('Nenhum ticket selecionado')
      return
    }

    if (tempStatus === selectedTicket.status) {
      console.log('Status não foi alterado')
      return
    }

    if (updatingStatus) {
      console.log('Atualização já em andamento...')
      return
    }

    console.log('🔄 Atualizando status...', {
      ticketId: selectedTicket.id,
      oldStatus: selectedTicket.status,
      newStatus: tempStatus
    })

    setUpdatingStatus(true)

    try {
      const { data, error } = await supabase
        .from('tickets')
        .update({ 
          status: tempStatus, 
          updated_at: new Date().toISOString() 
        })
        .eq('id', selectedTicket.id)
        .select()

      if (error) {
        console.error('❌ Erro ao atualizar status:', error)
        alert(`Erro ao atualizar status: ${error.message}`)
        return
      }

      console.log('✅ Status atualizado com sucesso:', data)

      // Atualizar estado local
      setSelectedTicket({ ...selectedTicket, status: tempStatus, updated_at: new Date().toISOString() })
      
      // Recarregar lista
      await fetchTickets()
      
      // Mostrar mensagem de sucesso
      alert(`Status atualizado com sucesso para: ${getStatusLabel(tempStatus)}`)
      
      // Fechar modal após atualização
      setIsDetailOpen(false)
      
    } catch (error) {
      console.error('❌ Erro inesperado ao atualizar status:', error)
      alert('Erro inesperado ao atualizar status')
    } finally {
      setUpdatingStatus(false)
    }
  }

  // Buscar comentários de um ticket
  const fetchComments = async (ticketId: string) => {
    try {
      setLoadingComments(true)
      // Temporariamente desabilitado até a tabela ser criada
      // const { data, error } = await supabase
      //   .from('ticket_comments')
      //   .select('*')
      //   .eq('ticket_id', ticketId)
      //   .order('created_at', { ascending: true })

      // if (error) {
      //   console.error('Erro ao buscar comentários:', error)
      //   return
      // }

      // setComments(data || [])
      setComments([]) // Por enquanto, sem comentários
    } catch (error) {
      console.error('Erro ao buscar comentários:', error)
    } finally {
      setLoadingComments(false)
    }
  }

  // Adicionar novo comentário
  const handleAddComment = async () => {
    if (!selectedTicket || !newComment.trim()) return

    try {
      // Temporariamente desabilitado até a tabela ser criada
      // const { error } = await supabase
      //   .from('ticket_comments')
      //   .insert({
      //     ticket_id: selectedTicket.id,
      //     content: newComment.trim(),
      //     author: 'Usuário Atual', // Aqui você pode usar o nome do usuário logado
      //     created_at: new Date().toISOString()
      //   })

      // if (error) {
      //   console.error('Erro ao adicionar comentário:', error)
      //   return
      // }

      // Limpar campo e recarregar comentários
      setNewComment("")
      // await fetchComments(selectedTicket.id)
      
      // Mostrar mensagem de sucesso
      alert("Comentário adicionado com sucesso! (Funcionalidade temporariamente desabilitada)")
    } catch (error) {
      console.error('Erro ao adicionar comentário:', error)
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  if (loading) {
    return (
      <div className="flex h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex items-center justify-center">
          <div className="flex items-center gap-2">
            <RefreshCw className="h-6 w-6 animate-spin" />
            <span>Carregando chamados...</span>
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
                <h1 className="text-3xl font-bold tracking-tight">Chamados</h1>
                <p className="text-muted-foreground">
                  Gerencie todos os chamados do sistema.
                </p>
              </div>
              <div className="flex items-center gap-3">
                <Button onClick={fetchTickets} variant="outline" size="sm">
                  <RefreshCw className="h-4 w-4 mr-2" />
                  Atualizar
                </Button>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Novo Chamado
                </Button>
              </div>
            </div>
          </motion.div>

          {/* Filtros */}
          <div className="mb-6 flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <Input
                placeholder="Buscar por título, descrição ou solicitante..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="max-w-md"
              />
            </div>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Filtrar por status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="todos">Todos os status</SelectItem>
                {statusOptions.map((status) => (
                  <SelectItem key={status.value} value={status.value}>
                    {status.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Estatísticas */}
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Total</p>
                    <p className="text-2xl font-bold">{filteredTickets.length}</p>
                  </div>
                  <FileText className="h-8 w-8 text-blue-500" />
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Novos</p>
                    <p className="text-2xl font-bold">{newTickets.length}</p>
                  </div>
                  <div className="h-8 w-8 rounded-full bg-blue-500" />
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Abertos</p>
                    <p className="text-2xl font-bold">{openTickets.length}</p>
                  </div>
                  <div className="h-8 w-8 rounded-full bg-orange-500" />
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Em andamento</p>
                    <p className="text-2xl font-bold">{inProgressTickets.length}</p>
                  </div>
                  <Clock className="h-8 w-8 text-yellow-500" />
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Resolvidos</p>
                    <p className="text-2xl font-bold">{resolvedTickets.length}</p>
                  </div>
                  <CheckCircle className="h-8 w-8 text-green-500" />
                </div>
              </CardContent>
            </Card>
          </div>

                    {/* Abas para Separar Chamados por Status */}
          <Tabs defaultValue="todos" className="w-full">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="todos" className="flex items-center gap-2">
                <FileText className="h-4 w-4" />
                Todos ({filteredTickets.length})
              </TabsTrigger>
              <TabsTrigger value="novos" className="flex items-center gap-2">
                <div className="h-3 w-3 rounded-full bg-blue-500"></div>
                Novos ({newTickets.length})
              </TabsTrigger>
              <TabsTrigger value="atendimento" className="flex items-center gap-2">
                <Clock className="h-4 w-4" />
                Em Atendimento ({openTickets.length + inProgressTickets.length})
              </TabsTrigger>
              <TabsTrigger value="concluidos" className="flex items-center gap-2">
                <CheckCircle className="h-4 w-4" />
                Concluídos ({resolvedTickets.length + closedTickets.length})
              </TabsTrigger>
            </TabsList>

            {/* Conteúdo das Abas */}
            <TabsContent value="todos" className="space-y-4 mt-6">
              {filteredTickets.length === 0 ? (
                <Card>
                  <CardContent className="p-8 text-center">
                    <FileText className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                    <h3 className="text-lg font-semibold mb-2">Nenhum chamado encontrado</h3>
                    <p className="text-muted-foreground">
                      {searchTerm || statusFilter !== "todos" 
                        ? "Tente ajustar os filtros de busca." 
                        : "Não há chamados cadastrados no sistema."}
                    </p>
                  </CardContent>
                </Card>
              ) : (
                filteredTickets.map((ticket) => (
                  <TicketCard key={ticket.id} ticket={ticket} onViewDetails={handleViewDetails} />
                ))
              )}
            </TabsContent>

            <TabsContent value="novos" className="space-y-4 mt-6">
              {newTickets.length === 0 ? (
                <Card>
                  <CardContent className="p-8 text-center">
                    <div className="h-12 w-12 rounded-full bg-blue-500 mx-auto mb-4 flex items-center justify-center">
                      <FileText className="h-6 w-6 text-white" />
                    </div>
                    <h3 className="text-lg font-semibold mb-2">Nenhum chamado novo</h3>
                    <p className="text-muted-foreground">Todos os chamados foram atendidos!</p>
                  </CardContent>
                </Card>
              ) : (
                newTickets.map((ticket) => (
                  <TicketCard key={ticket.id} ticket={ticket} onViewDetails={handleViewDetails} />
                ))
              )}
            </TabsContent>

            <TabsContent value="atendimento" className="space-y-4 mt-6">
              {openTickets.length === 0 && inProgressTickets.length === 0 ? (
                <Card>
                  <CardContent className="p-8 text-center">
                    <Clock className="h-12 w-12 text-yellow-500 mx-auto mb-4" />
                    <h3 className="text-lg font-semibold mb-2">Nenhum chamado em atendimento</h3>
                    <p className="text-muted-foreground">Todos os chamados foram resolvidos ou estão aguardando!</p>
                  </CardContent>
                </Card>
              ) : (
                [...openTickets, ...inProgressTickets].map((ticket) => (
                  <TicketCard key={ticket.id} ticket={ticket} onViewDetails={handleViewDetails} />
                ))
              )}
            </TabsContent>

            <TabsContent value="concluidos" className="space-y-4 mt-6">
              {resolvedTickets.length === 0 && closedTickets.length === 0 ? (
                <Card>
                  <CardContent className="p-8 text-center">
                    <CheckCircle className="h-12 w-12 text-green-500 mx-auto mb-4" />
                    <h3 className="text-lg font-semibold mb-2">Nenhum chamado concluído</h3>
                    <p className="text-muted-foreground">Ainda não há chamados finalizados no sistema.</p>
                  </CardContent>
                </Card>
              ) : (
                [...resolvedTickets, ...closedTickets].map((ticket) => (
                  <TicketCard key={ticket.id} ticket={ticket} onViewDetails={handleViewDetails} />
                ))
              )}
            </TabsContent>
          </Tabs>
        </div>
      </div>

      {/* Modal de Detalhes */}
      <Dialog open={isDetailOpen} onOpenChange={setIsDetailOpen}>
        <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Detalhes do Chamado</DialogTitle>
            <DialogDescription>
              {selectedTicket?.ticket_number} - {selectedTicket?.title}
            </DialogDescription>
          </DialogHeader>
          
          {selectedTicket && (
            <div className="space-y-6">
              {/* Cabeçalho com Status e Ações */}
              <div className="bg-muted/50 p-4 rounded-lg">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Status Atual</label>
                    <div className="flex items-center gap-3 mt-2">
                      <Select value={tempStatus} onValueChange={setTempStatus}>
                        <SelectTrigger className="w-full">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {statusOptions.map((status) => (
                            <SelectItem key={status.value} value={status.value}>
                              {status.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <Button 
                        variant="outline" 
                        size="sm"
                        onClick={handleStatusChange}
                        disabled={tempStatus === selectedTicket.status || updatingStatus}
                      >
                        {updatingStatus ? (
                          <>
                            <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
                            Atualizando...
                          </>
                        ) : (
                          'Atualizar Status'
                        )}
                      </Button>
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Prioridade</label>
                    <div className="flex items-center gap-2 p-2 border rounded-md mt-2">
                      {getPriorityIcon(selectedTicket.priority)}
                      <span>{getPriorityLabel(selectedTicket.priority)}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Descrição */}
              <div>
                <label className="text-sm font-medium text-muted-foreground">Descrição</label>
                <p className="mt-1 p-3 bg-muted rounded-md">{selectedTicket.description}</p>
              </div>

              {/* Informações do solicitante */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Solicitante</label>
                  <p className="mt-1">{selectedTicket.requester_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Email</label>
                  <p className="mt-1">{selectedTicket.requester_email}</p>
                </div>
                {selectedTicket.requester_phone && (
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Telefone</label>
                    <p className="mt-1">{selectedTicket.requester_phone}</p>
                  </div>
                )}
                {selectedTicket.unit_name && (
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Unidade</label>
                    <p className="mt-1">{selectedTicket.unit_name}</p>
                  </div>
                )}
              </div>

              {/* Datas */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Criado em</label>
                  <p className="mt-1">{formatDate(selectedTicket.created_at)}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Última atualização</label>
                  <p className="mt-1">{formatDate(selectedTicket.updated_at)}</p>
                </div>
              </div>

              {/* Origem */}
              <div>
                <label className="text-sm font-medium text-muted-foreground">Origem</label>
                <p className="mt-1">
                  {selectedTicket.source === 'external_form' ? 'Formulário Externo' : 'Sistema Interno'}
                </p>
              </div>

              {/* Seção de Comentários */}
              <div className="border-t pt-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-semibold">Comentários</h3>
                  <MessageSquare className="h-5 w-5 text-muted-foreground" />
                </div>
                
                {/* Lista de comentários existentes */}
                <div className="space-y-3 mb-4">
                  {/* Comentário do sistema */}
                  <div className="bg-muted/50 p-3 rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-sm font-medium">Sistema</span>
                      <span className="text-xs text-muted-foreground">
                        {formatDate(selectedTicket.created_at)}
                      </span>
                    </div>
                    <p className="text-sm text-muted-foreground">
                      Chamado criado automaticamente pelo sistema.
                    </p>
                  </div>
                  
                  {/* Comentários de mudança de status */}
                  {selectedTicket.status !== "new" && (
                    <div className="bg-blue-50 p-3 rounded-lg border-l-4 border-l-blue-500">
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-sm font-medium text-blue-800">Status Atualizado</span>
                        <span className="text-xs text-blue-600">
                          {formatDate(selectedTicket.updated_at)}
                        </span>
                      </div>
                      <p className="text-sm text-blue-700">
                        Status alterado para: <strong>{getStatusLabel(selectedTicket.status)}</strong>
                      </p>
                    </div>
                  )}

                  {/* Comentários dos usuários */}
                  {loadingComments ? (
                    <div className="flex items-center justify-center p-4">
                      <RefreshCw className="h-4 w-4 animate-spin mr-2" />
                      <span className="text-sm text-muted-foreground">Carregando comentários...</span>
                    </div>
                  ) : comments.length > 0 ? (
                    comments.map((comment) => (
                      <div key={comment.id} className="bg-white p-3 rounded-lg border">
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-sm font-medium">{comment.author}</span>
                          <span className="text-xs text-muted-foreground">
                            {formatDate(comment.created_at)}
                          </span>
                        </div>
                        <p className="text-sm text-gray-700">{comment.content}</p>
                      </div>
                    ))
                  ) : (
                    <div className="text-center p-4 text-muted-foreground">
                      <MessageSquare className="h-8 w-8 mx-auto mb-2 opacity-50" />
                      <p className="text-sm">Nenhum comentário ainda. Seja o primeiro a comentar!</p>
                    </div>
                  )}
                </div>

                {/* Adicionar novo comentário */}
                <div className="space-y-3">
                  <label className="text-sm font-medium text-muted-foreground">
                    Adicionar Comentário
                  </label>
                  <Textarea
                    placeholder="Digite seu comentário sobre este chamado..."
                    value={newComment}
                    onChange={(e) => setNewComment(e.target.value)}
                    className="min-h-[100px]"
                  />
                  <div className="flex justify-end gap-2">
                    <Button 
                      variant="outline" 
                      onClick={() => setNewComment("")}
                    >
                      Limpar
                    </Button>
                    <Button 
                      onClick={handleAddComment}
                      disabled={!newComment.trim()}
                    >
                      <MessageSquare className="h-4 w-4 mr-2" />
                      Adicionar Comentário
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
