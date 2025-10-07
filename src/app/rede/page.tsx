"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Sidebar } from "@/components/sidebar"
import { UserProfile } from "@/components/user-profile"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { 
  Network, 
  Wifi, 
  WifiOff, 
  Activity, 
  AlertTriangle, 
  CheckCircle, 
  RefreshCw,
  Server,
  Globe,
  Shield,
  Zap,
  Plus,
  Settings,
  Monitor
} from "lucide-react"
import { createClient } from "@supabase/supabase-js"

// Configuração do Supabase
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

// Log para debug
console.log('Supabase URL:', supabaseUrl)
console.log('Supabase Key:', supabaseAnonKey ? 'Configurada' : 'Não configurada')

const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '')

// Interface para dispositivos de rede
interface NetworkDevice {
  id: string
  unit_id?: string
  ip_address: string
  hostname?: string
  status: string
  uptime_percentage?: number
  last_ping_ms?: number | null
  vpn_status: string
  services?: string[]
  last_check: string
  created_at: string
  updated_at: string
  // Campos relacionados para exibição
  unit?: {
    id: string
    name: string
    code: string
  }
}

// Estatísticas calculadas dinamicamente baseadas nos dados reais
const calculateNetworkStats = (devices: NetworkDevice[]) => {
  const total = devices.length
  const online = devices.filter(d => d.status === 'online').length
  const offline = devices.filter(d => d.status === 'offline').length
  const warning = devices.filter(d => d.status === 'warning').length
  
  const avgUptime = devices.length > 0 
    ? (devices.reduce((sum, d) => sum + (d.uptime_percentage || 0), 0) / devices.length).toFixed(1)
    : '0.0'
  
  return {
    totalLocations: total,
    onlineLocations: online,
    offlineLocations: offline,
    warningLocations: warning,
    averageUptime: `${avgUptime}%`
  }
}

export default function RedePage() {
  const [devices, setDevices] = useState<NetworkDevice[]>([])
  const [loading, setLoading] = useState(true)
  const [isAddDeviceOpen, setIsAddDeviceOpen] = useState(false)
  const [monitoring, setMonitoring] = useState(false)
  const [newDevice, setNewDevice] = useState({
    ip_address: "",
    hostname: "",
    services: [] as string[]
  })

  // Buscar dispositivos do banco de dados
  const fetchDevices = async () => {
    try {
      console.log('Iniciando busca de dispositivos...')
      setLoading(true)
      
      const { data, error } = await supabase
        .from('network_monitoring')
        .select(`
          *,
          unit:units(id, name, code)
        `)
        .order('created_at', { ascending: false })

      console.log('Resposta da busca:', { data, error })

      if (error) {
        console.error('Erro ao buscar dispositivos:', error)
        alert(`Erro ao buscar dispositivos: ${error.message}`)
        return
      }

      console.log('Dispositivos encontrados:', data)
      setDevices(data || [])
    } catch (error) {
      console.error('Erro inesperado ao buscar dispositivos:', error)
      alert(`Erro inesperado ao buscar dispositivos: ${error}`)
    } finally {
      setLoading(false)
    }
  }

  // Verificar estrutura do banco
  const checkDatabaseStructure = async () => {
    try {
      console.log('Verificando estrutura do banco...')
      
      // Verificar se a tabela units existe e tem dados
      const { data: units, error: unitsError } = await supabase
        .from('units')
        .select('id, name')
        .limit(5)
      
      console.log('Verificação da tabela units:', { units, unitsError })
      
      // Verificar se a tabela network_monitoring existe
      const { data: networkData, error: networkError } = await supabase
        .from('network_monitoring')
        .select('id')
        .limit(1)
      
      console.log('Verificação da tabela network_monitoring:', { networkData, networkError })
      
      if (unitsError) {
        console.error('Problema com a tabela units:', unitsError)
        alert('Problema com a tabela units. Verifique se ela existe.')
      }
      
      if (networkError) {
        console.error('Problema com a tabela network_monitoring:', networkError)
        alert('Problema com a tabela network_monitoring. Verifique se ela existe.')
      }
      
      if (!units || units.length === 0) {
        console.warn('Tabela units está vazia. É necessário ter pelo menos uma unidade.')
        alert('A tabela units está vazia. É necessário cadastrar pelo menos uma unidade antes de adicionar dispositivos.')
      }
      
    } catch (error) {
      console.error('Erro ao verificar estrutura do banco:', error)
    }
  }

  // Função para verificar status de um dispositivo
  const checkDeviceStatus = async (device: NetworkDevice) => {
    try {
      const startTime = Date.now()
      
      // Simular ping (em produção, você pode usar uma API real de ping)
      const pingResult = await simulatePing(device.ip_address)
      const pingTime = Date.now() - startTime
      
      // Determinar status baseado no ping
      let status = 'unknown'
      let uptime = device.uptime_percentage || 0
      
      if (pingResult.success) {
        status = 'online'
        // Calcular uptime (simplificado - em produção seria mais complexo)
        uptime = Math.min(100, Math.max(0, uptime + (Math.random() * 2 - 1)))
      } else {
        status = 'offline'
        uptime = Math.max(0, uptime - 5) // Reduzir uptime se offline
      }
      
      // Atualizar dispositivo no banco
      const { error } = await supabase
        .from('network_monitoring')
        .update({
          status: status,
          uptime_percentage: Math.round(uptime * 100) / 100,
          last_ping_ms: pingResult.success ? Math.round(pingTime) : null,
          last_check: new Date().toISOString()
        })
        .eq('id', device.id)
      
      if (error) {
        console.error(`Erro ao atualizar dispositivo ${device.id}:`, error)
      }
      
      return {
        id: device.id,
        status,
        uptime_percentage: Math.round(uptime * 100) / 100,
        last_ping_ms: pingResult.success ? Math.round(pingTime) : null,
        last_check: new Date().toISOString()
      }
    } catch (error) {
      console.error(`Erro ao verificar status do dispositivo ${device.id}:`, error)
      return null
    }
  }

  // Simular ping (substitua por uma implementação real)
  const simulatePing = async (ipAddress: string): Promise<{ success: boolean, latency?: number }> => {
    // Simulação simples - em produção, use uma API real de ping
    return new Promise((resolve) => {
      setTimeout(() => {
        // Simular 90% de chance de sucesso para IPs válidos
        const isLocalNetwork = ipAddress.startsWith('192.168.') || 
                              ipAddress.startsWith('10.') || 
                              ipAddress.startsWith('172.')
        
        if (isLocalNetwork) {
          resolve({ success: true, latency: Math.random() * 50 + 5 })
        } else {
          resolve({ success: Math.random() > 0.3, latency: Math.random() * 100 + 20 })
        }
      }, Math.random() * 1000 + 500) // Simular latência de rede
    })
  }

  // Função para monitorar todos os dispositivos
  const monitorAllDevices = async () => {
    if (devices.length === 0) return
    
    console.log('Iniciando monitoramento de dispositivos...')
    setMonitoring(true)
    
    try {
      const updatePromises = devices.map(device => checkDeviceStatus(device))
      const results = await Promise.all(updatePromises)
      
      // Filtrar resultados válidos
      const validResults = results.filter(result => result !== null)
      
      if (validResults.length > 0) {
        // Atualizar estado local com os novos dados
        setDevices(prevDevices => 
          prevDevices.map(device => {
            const update = validResults.find(r => r?.id === device.id)
            if (update) {
              return {
                ...device,
                status: update.status,
                uptime_percentage: update.uptime_percentage,
                last_ping_ms: update.last_ping_ms || undefined,
                last_check: update.last_check
              }
            }
            return device
          })
        )
        
        console.log(`${validResults.length} dispositivos monitorados com sucesso`)
      }
    } catch (error) {
      console.error('Erro durante monitoramento:', error)
    } finally {
      setMonitoring(false)
    }
  }

  // Iniciar monitoramento automático
  useEffect(() => {
    checkDatabaseStructure()
    fetchDevices()
    
    // Configurar monitoramento a cada 2 minutos
    const monitoringInterval = setInterval(monitorAllDevices, 2 * 60 * 1000)
    
    // Limpar intervalo quando componente for desmontado
    return () => clearInterval(monitoringInterval)
  }, [devices.length]) // Re-executar quando o número de dispositivos mudar

  const handleAddDevice = async () => {
    try {
      console.log('Iniciando criação de dispositivo...')
      console.log('Dados do dispositivo:', newDevice)
      
      // Primeiro, buscar uma unidade válida
      const { data: units, error: unitsError } = await supabase
        .from('units')
        .select('id, name')
        .limit(1)
      
      console.log('Unidades encontradas:', units)
      console.log('Erro ao buscar unidades:', unitsError)
      
      if (unitsError) {
        console.error('Erro ao buscar unidades:', unitsError)
        alert('Erro ao buscar unidades. Verifique se a tabela units existe.')
        return
      }
      
      if (!units || units.length === 0) {
        console.error('Nenhuma unidade encontrada')
        alert('Nenhuma unidade encontrada. É necessário ter pelo menos uma unidade cadastrada.')
        return
      }

      const deviceData = {
        unit_id: units[0].id,
        ip_address: newDevice.ip_address,
        hostname: newDevice.hostname || null,
        status: 'unknown',
        vpn_status: 'unknown',
        services: newDevice.services.length > 0 ? newDevice.services : null
      }
      
      console.log('Dados para inserção:', deviceData)
      
      const { data, error } = await supabase
        .from('network_monitoring')
        .insert([deviceData])
        .select()

      console.log('Resposta da inserção:', { data, error })

      if (error) {
        console.error('Erro ao adicionar dispositivo:', error)
        alert(`Erro ao adicionar dispositivo: ${error.message}`)
        return
      }

      console.log('Dispositivo criado com sucesso:', data)

      // Limpar formulário
      setNewDevice({
        ip_address: "",
        hostname: "",
        services: []
      })

      // Fechar modal
      setIsAddDeviceOpen(false)

      // Recarregar lista
      fetchDevices()
      
      alert('Dispositivo adicionado com sucesso!')
    } catch (error) {
      console.error('Erro inesperado ao adicionar dispositivo:', error)
      alert(`Erro inesperado: ${error}`)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "online":
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case "offline":
        return <WifiOff className="h-4 w-4 text-red-500" />
      case "warning":
        return <AlertTriangle className="h-4 w-4 text-yellow-500" />
      default:
        return <Activity className="h-4 w-4 text-gray-500" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "online":
        return "bg-green-100 text-green-800"
      case "offline":
        return "bg-red-100 text-red-800"
      case "warning":
        return "bg-yellow-100 text-yellow-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getVPNStatusColor = (status: string) => {
    switch (status) {
      case "connected":
        return "bg-green-100 text-green-800"
      case "disconnected":
        return "bg-red-100 text-red-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

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
            <RefreshCw className="h-6 w-6 animate-spin" />
            <span>Carregando dispositivos de rede...</span>
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
                <h1 className="text-3xl font-bold tracking-tight">Monitoramento de Rede</h1>
                                 <div>
                   <p className="text-muted-foreground">
                     Acompanhe o status de todos os dispositivos e conexões VPN.
                   </p>
                   <p className="text-xs text-muted-foreground mt-1">
                     Monitoramento automático a cada 2 minutos
                     {devices.length > 0 && (
                       <span className="ml-2">
                         • Última verificação: {formatDate(devices[0]?.last_check || new Date().toISOString())}
                       </span>
                     )}
                   </p>
                 </div>
              </div>
                             <div className="flex items-center gap-3">
                 <Button 
                   onClick={monitorAllDevices} 
                   variant="outline" 
                   size="sm"
                   disabled={monitoring}
                 >
                   <RefreshCw className={`h-4 w-4 mr-2 ${monitoring ? 'animate-spin' : ''}`} />
                   {monitoring ? 'Monitorando...' : 'Monitorar Agora'}
                 </Button>
                 <Button onClick={fetchDevices} variant="outline" size="sm">
                   <RefreshCw className="h-4 w-4 mr-2" />
                   Atualizar
                 </Button>
                 <Button onClick={() => setIsAddDeviceOpen(true)}>
                   <Plus className="h-4 w-4 mr-2" />
                   Adicionar Dispositivo
                 </Button>
               </div>
            </div>
          </motion.div>

          {/* Estatísticas */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Total de Dispositivos</p>
                    <p className="text-2xl font-bold">{calculateNetworkStats(devices).totalLocations}</p>
                  </div>
                  <Network className="h-8 w-8 text-blue-500" />
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Online</p>
                    <p className="text-2xl font-bold text-green-600">{calculateNetworkStats(devices).onlineLocations}</p>
                  </div>
                  <CheckCircle className="h-8 w-8 text-green-500" />
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Offline</p>
                    <p className="text-2xl font-bold text-red-600">{calculateNetworkStats(devices).offlineLocations}</p>
                  </div>
                  <WifiOff className="h-8 w-8 text-red-500" />
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Uptime Médio</p>
                    <p className="text-2xl font-bold">{calculateNetworkStats(devices).averageUptime}</p>
                  </div>
                  <Activity className="h-8 w-8 text-blue-500" />
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Lista de Dispositivos */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {devices.length === 0 ? (
              <div className="col-span-full text-center py-12">
                <div className="flex flex-col items-center gap-4">
                  <Network className="h-16 w-16 text-muted-foreground" />
                  <div>
                    <h3 className="text-lg font-semibold">Nenhum dispositivo encontrado</h3>
                    <p className="text-muted-foreground">Adicione seu primeiro dispositivo para começar o monitoramento</p>
                  </div>
                </div>
              </div>
            ) : (
              devices.map((device) => (
                <motion.div
                  key={device.id}
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ duration: 0.3 }}
                >
                  <Card className="hover:shadow-lg transition-shadow">
                    <CardHeader className="pb-3">
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-lg">
                          {device.hostname || device.unit?.name || 'Dispositivo'}
                        </CardTitle>
                        <div className="flex items-center gap-2">
                          {getStatusIcon(device.status)}
                          <Badge className={getStatusColor(device.status)}>
                            {device.status === "online" ? "Online" : 
                             device.status === "offline" ? "Offline" : 
                             device.status === "warning" ? "Atenção" : "Desconhecido"}
                          </Badge>
                        </div>
                      </div>
                      <CardDescription className="flex items-center gap-2">
                        <Globe className="h-4 w-4" />
                        {device.ip_address}
                      </CardDescription>
                    </CardHeader>
                    
                    <CardContent className="space-y-4">
                      {/* Status VPN */}
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">VPN</span>
                        <Badge variant="outline" className={getVPNStatusColor(device.vpn_status)}>
                          {device.vpn_status === "connected" ? "Conectado" : 
                           device.vpn_status === "disconnected" ? "Desconectado" : "Desconhecido"}
                        </Badge>
                      </div>

                      {/* Uptime */}
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">Uptime</span>
                        <span className="text-sm font-medium">
                          {device.uptime_percentage ? `${device.uptime_percentage}%` : 'N/A'}
                        </span>
                      </div>

                      {/* Ping */}
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">Ping</span>
                        <span className="text-sm font-medium">
                          {device.last_ping_ms ? `${device.last_ping_ms}ms` : 'N/A'}
                        </span>
                      </div>

                      {/* Serviços */}
                      <div>
                        <span className="text-sm text-muted-foreground">Serviços</span>
                        <div className="flex flex-wrap gap-1 mt-1">
                                                     {device.services && Array.isArray(device.services) && device.services.length > 0 ? (
                             device.services.map((service: string, index: number) => (
                               <Badge key={index} variant="secondary" className="text-xs">
                                 {service}
                               </Badge>
                             ))
                           ) : (
                             <span className="text-xs text-muted-foreground">Nenhum serviço configurado</span>
                           )}
                        </div>
                      </div>

                      {/* Última verificação */}
                      <div className="text-xs text-muted-foreground">
                        Última verificação: {formatDate(device.last_check)}
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Modal para adicionar dispositivo */}
      <Dialog open={isAddDeviceOpen} onOpenChange={setIsAddDeviceOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Adicionar Novo Dispositivo</DialogTitle>
            <DialogDescription>
              Adicione um novo dispositivo ou rede para monitoramento.
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium">Endereço IP</label>
              <Input
                placeholder="Ex: 192.168.1.100"
                value={newDevice.ip_address}
                onChange={(e) => setNewDevice({ ...newDevice, ip_address: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-medium">Hostname (opcional)</label>
              <Input
                placeholder="Ex: server01.local"
                value={newDevice.hostname}
                onChange={(e) => setNewDevice({ ...newDevice, hostname: e.target.value })}
              />
            </div>

            <div className="flex gap-2 pt-4">
              <Button variant="outline" onClick={() => setIsAddDeviceOpen(false)} className="flex-1">
                Cancelar
              </Button>
              <Button onClick={handleAddDevice} className="flex-1" disabled={!newDevice.ip_address}>
                Adicionar
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
