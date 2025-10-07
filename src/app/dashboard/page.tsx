"use client"

import { motion } from "framer-motion"
import { Sidebar } from "@/components/sidebar"
import { UserProfile } from "@/components/user-profile"
import { useAuth } from "@/hooks/useAuth"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { 
  Activity, 
  AlertCircle, 
  CheckCircle, 
  Clock, 
  Computer, 
  FileText, 
  Network, 
  Package, 
  TrendingUp, 
  Users 
} from "lucide-react"
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from "recharts"
import { useEffect, useState } from "react"
import { supabase } from "@/lib/supabase"

// Tipos para os dados reais
interface Ticket {
  id: string
  ticket_number: string
  title: string
  status: string
  priority: string
  assignee_id: string | null
  created_at: string
}

interface Asset {
  id: string
  code: string
  name: string
  status: string
  unit_id: string | null
}

interface Unit {
  id: string
  name: string
  code: string
  status: string
}

interface DashboardStats {
  totalTickets: number
  openTickets: number
  resolvedTickets: number
  totalAssets: number
  activeAssets: number
  totalUnits: number
  onlineUnits: number
}

export default function DashboardPage() {
  const { user } = useAuth()
  const [stats, setStats] = useState<DashboardStats>({
    totalTickets: 0,
    openTickets: 0,
    resolvedTickets: 0,
    totalAssets: 0,
    activeAssets: 0,
    totalUnits: 0,
    onlineUnits: 0
  })
  const [recentTickets, setRecentTickets] = useState<Ticket[]>([])
  const [networkStatus, setNetworkStatus] = useState<Unit[]>([])
  const [chartData, setChartData] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  // Buscar dados do dashboard
  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true)
        
        // Buscar estatísticas gerais
        await Promise.all([
          fetchTicketStats(),
          fetchAssetStats(),
          fetchUnitStats(),
          fetchRecentTickets(),
          fetchNetworkStatus(),
          fetchChartData()
        ])
        
      } catch (error) {
        console.error('Erro ao buscar dados do dashboard:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchDashboardData()
  }, [])

  // Buscar estatísticas de tickets
  const fetchTicketStats = async () => {
    try {
      const { count: totalTickets } = await supabase
        .from('tickets')
        .select('*', { count: 'exact', head: true })

      const { count: openTickets } = await supabase
        .from('tickets')
        .select('*', { count: 'exact', head: true })
        .in('status', ['new', 'in_progress'])

      const { count: resolvedTickets } = await supabase
        .from('tickets')
        .select('*', { count: 'exact', head: true })
        .in('status', ['resolved', 'closed'])

      setStats(prev => ({
        ...prev,
        totalTickets: totalTickets || 0,
        openTickets: openTickets || 0,
        resolvedTickets: resolvedTickets || 0
      }))
    } catch (error) {
      console.error('Erro ao buscar estatísticas de tickets:', error)
    }
  }

  // Buscar estatísticas de inventário
  const fetchAssetStats = async () => {
    try {
      const { count: totalAssets } = await supabase
        .from('assets')
        .select('*', { count: 'exact', head: true })

      const { count: activeAssets } = await supabase
        .from('assets')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'active')

      setStats(prev => ({
        ...prev,
        totalAssets: totalAssets || 0,
        activeAssets: activeAssets || 0
      }))
    } catch (error) {
      console.error('Erro ao buscar estatísticas de inventário:', error)
    }
  }

  // Buscar estatísticas de unidades
  const fetchUnitStats = async () => {
    try {
      const { count: totalUnits } = await supabase
        .from('units')
        .select('*', { count: 'exact', head: true })

      const { count: onlineUnits } = await supabase
        .from('units')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'active')

      setStats(prev => ({
        ...prev,
        totalUnits: totalUnits || 0,
        onlineUnits: onlineUnits || 0
      }))
    } catch (error) {
      console.error('Erro ao buscar estatísticas de unidades:', error)
    }
  }

  // Buscar tickets recentes
  const fetchRecentTickets = async () => {
    try {
      const { data: tickets, error } = await supabase
        .from('tickets')
        .select(`
          id,
          ticket_number,
          title,
          status,
          priority,
          assignee_id,
          created_at
        `)
        .order('created_at', { ascending: false })
        .limit(5)

      if (error) throw error
      setRecentTickets(tickets || [])
    } catch (error) {
      console.error('Erro ao buscar tickets recentes:', error)
    }
  }

  // Buscar status da rede
  const fetchNetworkStatus = async () => {
    try {
      const { data: units, error } = await supabase
        .from('units')
        .select('id, name, code, status')
        .order('name')

      if (error) throw error
      setNetworkStatus(units || [])
    } catch (error) {
      console.error('Erro ao buscar status da rede:', error)
    }
  }

  // Buscar dados para o gráfico
  const fetchChartData = async () => {
    try {
      // Buscar tickets dos últimos 6 meses
      const sixMonthsAgo = new Date()
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6)

      const { data: tickets, error } = await supabase
        .from('tickets')
        .select('status, created_at')
        .gte('created_at', sixMonthsAgo.toISOString())

      if (error) throw error

      // Agrupar por mês
      const monthlyData = tickets?.reduce((acc: any, ticket) => {
        const date = new Date(ticket.created_at)
        const monthKey = date.toLocaleString('pt-BR', { month: 'short' })
        
        if (!acc[monthKey]) {
          acc[monthKey] = { name: monthKey, chamados: 0, resolvidos: 0 }
        }
        
        acc[monthKey].chamados++
        
        if (['resolved', 'closed'].includes(ticket.status)) {
          acc[monthKey].resolvidos++
        }
        
        return acc
      }, {})

      const chartDataArray = Object.values(monthlyData || {})
      setChartData(chartDataArray)
    } catch (error) {
      console.error('Erro ao buscar dados do gráfico:', error)
    }
  }

  // Obter nome do usuário para saudação
  const userName = user?.full_name || 'Usuário'
  
  // Calcular porcentagem de uptime da rede
  const networkUptime = stats.totalUnits > 0 ? ((stats.onlineUnits / stats.totalUnits) * 100).toFixed(1) : '0.0'
  
  return (
    <div className="flex h-screen bg-background">
      <Sidebar />
      
      <div className="flex-1 overflow-auto">
        <div className="p-8">
          {/* Cabeçalho com perfil do usuário */}
          <div className="flex items-center justify-between mb-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <h1 className="text-3xl font-bold tracking-tight mb-2">Dashboard</h1>
              <p className="text-muted-foreground">
                {userName}, olá Dev! 👋
              </p>
            </motion.div>
            <UserProfile />
          </div>

          {/* Cards de métricas */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4 mb-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 }}
            >
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Chamados Abertos</CardTitle>
                  <FileText className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.openTickets}</div>
                  <p className="text-xs text-muted-foreground">
                    {stats.totalTickets} total no sistema
                  </p>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
            >
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Chamados Resolvidos</CardTitle>
                  <CheckCircle className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.resolvedTickets}</div>
                  <p className="text-xs text-muted-foreground">
                    {stats.totalTickets > 0 ? Math.round((stats.resolvedTickets / stats.totalTickets) * 100) : 0}% taxa de resolução
                  </p>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.3 }}
            >
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Ativos Cadastrados</CardTitle>
                  <Package className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.totalAssets}</div>
                  <p className="text-xs text-muted-foreground">
                    {stats.activeAssets} ativos
                  </p>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.4 }}
            >
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Status da Rede</CardTitle>
                  <Network className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{networkUptime}%</div>
                  <p className="text-xs text-muted-foreground">
                    {stats.onlineUnits} de {stats.totalUnits} locais online
                  </p>
                </CardContent>
              </Card>
            </motion.div>
          </div>

          {/* Gráficos e tabelas */}
          <div className="grid gap-8 md:grid-cols-2">
            {/* Gráfico de chamados */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.5, delay: 0.5 }}
            >
              <Card>
                <CardHeader>
                  <CardTitle>Evolução de Chamados</CardTitle>
                  <CardDescription>
                    Chamados abertos vs resolvidos nos últimos 6 meses
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {chartData.length > 0 ? (
                    <ResponsiveContainer width="100%" height={300}>
                      <LineChart data={chartData}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="name" />
                        <YAxis />
                        <Tooltip />
                        <Line type="monotone" dataKey="chamados" stroke="#8884d8" strokeWidth={2} />
                        <Line type="monotone" dataKey="resolvidos" stroke="#82ca9d" strokeWidth={2} />
                      </LineChart>
                    </ResponsiveContainer>
                  ) : (
                    <div className="h-[300px] flex items-center justify-center text-muted-foreground">
                      {loading ? 'Carregando dados...' : 'Nenhum dado disponível'}
                    </div>
                  )}
                </CardContent>
              </Card>
            </motion.div>

            {/* Status da rede */}
            <motion.div
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.5, delay: 0.6 }}
            >
              <Card>
                <CardHeader>
                  <CardTitle>Status da Rede</CardTitle>
                  <CardDescription>
                    Monitoramento em tempo real das unidades
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {networkStatus.map((item) => (
                      <div key={item.id} className="flex items-center justify-between">
                        <span className="text-sm font-medium">{item.name}</span>
                        <div className="flex items-center gap-2">
                          <Badge variant={item.status === "active" ? "default" : "destructive"}>
                            {item.status === "active" ? "Online" : "Offline"}
                          </Badge>
                          <span className="text-xs text-muted-foreground">
                            {item.status === "active" ? "99.9%" : "0%"}
                          </span>
                        </div>
                      </div>
                    ))}
                    {networkStatus.length === 0 && (
                      <div className="text-center text-muted-foreground py-4">
                        {loading ? 'Carregando...' : 'Nenhuma unidade encontrada'}
                      </div>
                    )}
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </div>

          {/* Tabela de chamados recentes */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.7 }}
            className="mt-8"
          >
            <Card>
              <CardHeader>
                <CardTitle>Chamados Recentes</CardTitle>
                <CardDescription>
                  Últimos tickets criados no sistema
                </CardDescription>
              </CardHeader>
              <CardContent>
                {recentTickets.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>ID</TableHead>
                        <TableHead>Título</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Prioridade</TableHead>
                        <TableHead>Criado em</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {recentTickets.map((ticket) => (
                        <TableRow key={ticket.id}>
                          <TableCell className="font-mono">{ticket.ticket_number}</TableCell>
                          <TableCell>{ticket.title}</TableCell>
                          <TableCell>
                            <Badge variant="outline">
                              {ticket.status === 'new' ? 'Novo' : 
                               ticket.status === 'in_progress' ? 'Em andamento' :
                               ticket.status === 'resolved' ? 'Resolvido' :
                               ticket.status === 'closed' ? 'Fechado' : ticket.status}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <Badge variant={
                              ticket.priority === 'high' ? 'destructive' : 
                              ticket.priority === 'medium' ? 'secondary' : 'default'
                            }>
                              {ticket.priority === 'high' ? 'Alta' :
                               ticket.priority === 'medium' ? 'Média' :
                               ticket.priority === 'low' ? 'Baixa' : ticket.priority}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            {new Date(ticket.created_at).toLocaleDateString('pt-BR')}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <div className="text-center text-muted-foreground py-8">
                    {loading ? 'Carregando tickets...' : 'Nenhum ticket encontrado'}
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>
    </div>
  )
}
