"use client"

import { useState, useEffect } from "react"
import { motion } from "framer-motion"
import { Sidebar } from "@/components/sidebar"
import { UserProfile } from "@/components/user-profile"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { 
  Package, 
  Search, 
  Eye, 
  Plus, 
  Computer, 
  Monitor, 
  Keyboard, 
  Mouse, 
  Cable, 
  Camera, 
  Barcode,
  MapPin,
  Calendar,
  User,
  ArrowRight,
  DollarSign,
  Hash,
  FileText,
  FolderPlus,
  Palette
} from "lucide-react"
import { supabase } from "@/lib/supabase"

// Interfaces para os dados reais
interface AssetCategory {
  id: string
  name: string
  description: string
  icon: string
  color: string
}

interface Asset {
  id: string
  code: string
  name: string
  model: string
  brand: string
  category_id: string
  unit_id: string
  responsible_id: string
  status: string
  acquisition_date: string
  purchase_value: number
  serial_number: string
  location_details: string
  notes: string
  created_at: string
  updated_at: string
  // Campos relacionados
  category_name?: string
  unit_name?: string
  responsible_name?: string
}

interface Unit {
  id: string
  name: string
  code: string
  address: string
  city: string
  state: string
  status: string
}

interface AssetMovement {
  id: string
  asset_id: string
  action: string
  from_unit_id: string
  to_unit_id: string
  from_responsible_id: string
  to_responsible_id: string
  notes: string
  performed_by: string
  performed_at: string
}

export default function InventarioPage() {
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("all")
  const [selectedAsset, setSelectedAsset] = useState<Asset | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)
  const [isAddAssetOpen, setIsAddAssetOpen] = useState(false)
  const [isAddCategoryOpen, setIsAddCategoryOpen] = useState(false)
  const [isAddUnitOpen, setIsAddUnitOpen] = useState(false)
  
  // Estados para dados reais
  const [categories, setCategories] = useState<AssetCategory[]>([])
  const [assets, setAssets] = useState<Asset[]>([])
  const [units, setUnits] = useState<Unit[]>([])
  const [users, setUsers] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [assetMovements, setAssetMovements] = useState<AssetMovement[]>([])
  
  // Estados para formulário de adicionar ativo
  const [newAsset, setNewAsset] = useState({
    code: '',
    name: '',
    model: '',
    brand: '',
    category_id: '',
    unit_id: '',
    responsible_id: '',
    status: 'active',
    acquisition_date: '',
    purchase_value: '',
    serial_number: '',
    location_details: '',
    notes: ''
  })

  // Estados para formulário de adicionar categoria
  const [newCategory, setNewCategory] = useState({
    name: '',
    description: '',
    icon: 'package',
    color: 'bg-blue-100 text-blue-800'
  })

  // Estados para formulário de adicionar unidade
  const [newUnit, setNewUnit] = useState({
    name: '',
    code: '',
    address: '',
    city: '',
    state: '',
    phone: '',
    status: 'active'
  })

  // Opções de ícones disponíveis
  const availableIcons = [
    { value: 'computer', label: 'Computador', icon: Computer },
    { value: 'monitor', label: 'Monitor', icon: Monitor },
    { value: 'keyboard', label: 'Teclado', icon: Keyboard },
    { value: 'mouse', label: 'Mouse', icon: Mouse },
    { value: 'cable', label: 'Cabo', icon: Cable },
    { value: 'camera', label: 'Câmera', icon: Camera },
    { value: 'barcode', label: 'Código de Barras', icon: Barcode },
    { value: 'package', label: 'Pacote', icon: Package }
  ]

  // Opções de cores disponíveis
  const availableColors = [
    { value: 'bg-blue-100 text-blue-800', label: 'Azul' },
    { value: 'bg-green-100 text-green-800', label: 'Verde' },
    { value: 'bg-purple-100 text-purple-800', label: 'Roxo' },
    { value: 'bg-orange-100 text-orange-800', label: 'Laranja' },
    { value: 'bg-red-100 text-red-800', label: 'Vermelho' },
    { value: 'bg-indigo-100 text-indigo-800', label: 'Índigo' },
    { value: 'bg-pink-100 text-pink-800', label: 'Rosa' },
    { value: 'bg-yellow-100 text-yellow-800', label: 'Amarelo' },
    { value: 'bg-gray-100 text-gray-800', label: 'Cinza' }
  ]

  // Buscar dados do banco
  const fetchData = async () => {
    try {
      setLoading(true)
      
      // Buscar categorias
      const { data: categoriesData, error: categoriesError } = await supabase
        .from('asset_categories')
        .select('*')
        .order('name', { ascending: true })
      
      if (categoriesError) {
        console.error('Erro ao buscar categorias:', categoriesError)
        setCategories([])
      } else {
        setCategories(categoriesData || [])
      }
      
      // Buscar unidades
      const { data: unitsData, error: unitsError } = await supabase
        .from('units')
        .select('*')
        .order('name', { ascending: true })
      
      if (unitsError) {
        console.error('Erro ao buscar unidades:', unitsError)
        setUnits([])
      } else {
        setUnits(unitsData || [])
      }
      
      // Buscar usuários (se necessário)
      let usersData: any[] = []
      try {
        const { data: users, error: usersError } = await supabase
          .from('users')
          .select('id, full_name')
          .order('full_name', { ascending: true })
        
        if (usersError) {
          console.warn('Usuários não disponíveis:', usersError.message)
        } else {
          usersData = users || []
        }
      } catch (error) {
        console.warn('Tabela users não disponível:', error)
      }
      
      setUsers(usersData)
      
      // Buscar ativos de forma simples
      try {
        const { data: assetsData, error: assetsError } = await supabase
          .from('assets')
          .select('*')
          .order('created_at', { ascending: false })
        
        if (assetsError) {
          console.error('Erro ao buscar ativos:', assetsError)
          setAssets([])
        } else {
          // Mapear dados dos ativos com informações das tabelas relacionadas
          const mappedAssets = (assetsData || []).map(asset => {
            const category = categoriesData?.find(c => c.id === asset.category_id)
            const unit = unitsData?.find(u => u.id === asset.unit_id)
            const user = usersData?.find(u => u.id === asset.responsible_id)
            
            return {
              ...asset,
              category_name: category?.name || 'Sem categoria',
              unit_name: unit?.name || 'Sem unidade',
              responsible_name: user?.full_name || 'Não atribuído'
            }
          })
          
          setAssets(mappedAssets)
        }
      } catch (error) {
        console.error('Erro ao buscar ativos:', error)
        setAssets([])
      }
      
    } catch (error) {
      console.error('Erro geral ao buscar dados:', error)
    } finally {
      setLoading(false)
    }
  }

  // Buscar dados ao carregar a página
  useEffect(() => {
    fetchData()
  }, [])

  // Funções auxiliares
  const formatDate = (dateString: string | null) => {
    if (!dateString) return 'N/A'
    return new Date(dateString).toLocaleDateString('pt-BR')
  }

  const formatCurrency = (value: number | null) => {
    if (value === null || value === undefined) return 'N/A'
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  // Função para obter ícone baseado no nome
  const getCategoryIcon = (iconName: string) => {
    const iconMap: { [key: string]: any } = {
      'computer': Computer,
      'monitor': Monitor,
      'keyboard': Keyboard,
      'mouse': Mouse,
      'cable': Cable,
      'camera': Camera,
      'barcode': Barcode,
      'package': Package
    }
    return iconMap[iconName] || Package
  }

  // Componente AssetCard
  const AssetCard = ({ asset, onViewDetails }: { asset: Asset, onViewDetails: () => void }) => {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
      >
        <Card className="hover:shadow-md transition-shadow cursor-pointer" onClick={onViewDetails}>
          <CardContent className="p-6">
            <div className="flex justify-between items-start mb-4">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <h3 className="font-semibold text-lg">{asset.name}</h3>
                  {asset.brand && <Badge variant="outline">{asset.brand}</Badge>}
                  <Badge variant={asset.status === 'active' ? 'default' : 'secondary'}>
                    {asset.status === 'active' ? 'Ativo' : asset.status}
                  </Badge>
                </div>
                <div className="grid grid-cols-2 gap-4 text-sm text-muted-foreground">
                  <div className="flex items-center gap-2">
                    <MapPin className="h-4 w-4" />
                    {asset.unit_name}
                  </div>
                  <div className="flex items-center gap-2">
                    <User className="h-4 w-4" />
                    {asset.responsible_name}
                  </div>
                </div>
              </div>
              <Button variant="outline" size="sm">
                <Eye className="h-4 w-4" />
              </Button>
            </div>
            
            <div className="flex justify-between items-center text-sm text-muted-foreground">
              <span className="font-mono">{asset.code}</span>
              <div className="flex items-center gap-4">
                {asset.acquisition_date && (
                  <span className="flex items-center gap-1">
                    <Calendar className="h-3 w-3" />
                    {formatDate(asset.acquisition_date)}
                  </span>
                )}
                {asset.purchase_value && (
                  <span className="flex items-center gap-1">
                    <DollarSign className="h-3 w-3" />
                    {formatCurrency(asset.purchase_value)}
                  </span>
                )}
              </div>
            </div>
          </CardContent>
        </Card>
      </motion.div>
    )
  }

  // Adicionar novo ativo
  const handleAddAsset = async () => {
    try {
      console.log('🔄 Tentando adicionar ativo:', newAsset)
      
      // Validar campos obrigatórios
      if (!newAsset.code || !newAsset.name || !newAsset.category_id || !newAsset.unit_id) {
        alert('Preencha todos os campos obrigatórios')
        return
      }

      // Preparar dados para inserção
      const assetData = {
        code: newAsset.code.trim(),
        name: newAsset.name.trim(),
        model: newAsset.model.trim() || null,
        brand: newAsset.brand.trim() || null,
        category_id: newAsset.category_id,
        unit_id: newAsset.unit_id,
        responsible_id: newAsset.responsible_id || null,
        status: newAsset.status,
        acquisition_date: newAsset.acquisition_date || null,
        purchase_value: newAsset.purchase_value ? parseFloat(newAsset.purchase_value.toString()) : null,
        serial_number: newAsset.serial_number.trim() || null,
        location_details: newAsset.location_details.trim() || null,
        notes: newAsset.notes.trim() || null
      }

      console.log('✅ Dados preparados:', assetData)

      // Verificar se o código já existe
      const { data: existingAsset, error: checkError } = await supabase
        .from('assets')
        .select('code')
        .eq('code', assetData.code)
        .single()

      if (checkError && checkError.code !== 'PGRST116') { // PGRST116 = no rows returned
        console.error('❌ Erro ao verificar código existente:', checkError)
        throw checkError
      }

      if (existingAsset) {
        alert('Já existe um ativo com este código. Escolha um código diferente.')
        return
      }

      console.log('✅ Código único, inserindo no banco...')

      const { data, error } = await supabase
        .from('assets')
        .insert([assetData])
        .select()

      if (error) {
        console.error('❌ Erro ao inserir ativo:', error)
        
        // Tratar erros específicos
        if (error.code === '23505') { // Unique violation
          alert('Erro: Este código de ativo já existe no sistema.')
        } else if (error.code === '23503') { // Foreign key violation
          alert('Erro: Categoria ou unidade selecionada não existe.')
        } else {
          alert(`Erro ao criar ativo: ${error.message}`)
        }
        
        throw error
      }

      console.log('✅ Ativo criado com sucesso:', data)

      // Limpar formulário e fechar modal
      setNewAsset({
        code: '',
        name: '',
        model: '',
        brand: '',
        category_id: '',
        unit_id: '',
        responsible_id: '',
        status: 'active',
        acquisition_date: '',
        purchase_value: '',
        serial_number: '',
        location_details: '',
        notes: ''
      })
      setIsAddAssetOpen(false)
      
      // Recarregar dados
      await fetchData()
      
      alert('Ativo criado com sucesso!')
      
    } catch (error) {
      console.error('❌ Erro ao adicionar ativo:', error)
      
      // Não mostrar alerta duplo se já foi mostrado acima
      const errorMessage = error instanceof Error ? error.message : String(error)
      if (!errorMessage.includes('código de ativo já existe') && 
          !errorMessage.includes('Categoria ou unidade selecionada')) {
        alert('Erro ao criar ativo. Verifique o console para mais detalhes.')
      }
    }
  }

  // Adicionar nova categoria
  const handleAddCategory = async () => {
    try {
      console.log('🔄 Tentando adicionar categoria:', newCategory)
      
      if (!newCategory.name) {
        alert('Nome da categoria é obrigatório')
        return
      }

      console.log('✅ Validação passou, inserindo no banco...')
      
      const { data, error } = await supabase
        .from('asset_categories')
        .insert([newCategory])
        .select()

      if (error) {
        console.error('❌ Erro ao inserir categoria:', error)
        alert(`Erro ao criar categoria: ${error.message}`)
        throw error
      }

      console.log('✅ Categoria criada com sucesso:', data)

      // Limpar formulário e fechar modal
      setNewCategory({
        name: '',
        description: '',
        icon: 'package',
        color: 'bg-blue-100 text-blue-800'
      })
      setIsAddCategoryOpen(false)
      
      // Recarregar dados
      await fetchData()
      
      alert('Categoria criada com sucesso!')
      
    } catch (error) {
      console.error('❌ Erro ao adicionar categoria:', error)
      alert('Erro ao criar categoria. Verifique o console para mais detalhes.')
    }
  }

  // Adicionar nova unidade
  const handleAddUnit = async () => {
    try {
      // Validar se o nome já existe
      const existingUnit = units.find(u => u.name.toLowerCase() === newUnit.name.toLowerCase())
      if (existingUnit) {
        alert('Já existe uma unidade com este nome. Escolha um nome diferente.')
        return
      }

      // Validar se o código já existe
      if (newUnit.code) {
        const existingCode = units.find(u => u.code.toLowerCase() === newUnit.code.toLowerCase())
        if (existingCode) {
          alert('Já existe uma unidade com este código. Escolha um código diferente.')
          return
        }
      }

      const { error } = await supabase
        .from('units')
        .insert([newUnit])

      if (error) throw error

      // Limpar formulário e fechar modal
      setNewUnit({
        name: '',
        code: '',
        address: '',
        city: '',
        state: '',
        phone: '',
        status: 'active'
      })
      setIsAddUnitOpen(false)
      
      // Recarregar dados
      fetchData()
      
      // Mostrar mensagem de sucesso
      alert('Unidade criada com sucesso!')
      
    } catch (error) {
      console.error('Erro ao adicionar unidade:', error)
      alert('Erro ao criar unidade. Tente novamente.')
    }
  }

  // Buscar histórico de movimentação
  const fetchAssetMovements = async (assetId: string) => {
    try {
      const { data, error } = await supabase
        .from('asset_movements')
        .select('*')
        .eq('asset_id', assetId)
        .order('performed_at', { ascending: false })
      
      if (error) throw error
      
      // Mapear dados das movimentações com informações das unidades
      const mappedMovements = (data || []).map(movement => {
        const fromUnit = units.find(u => u.id === movement.from_unit_id)
        const toUnit = units.find(u => u.id === movement.to_unit_id)
        
        return {
          ...movement,
          from_unit_name: fromUnit?.name || 'Unidade não encontrada',
          to_unit_name: toUnit?.name || 'Unidade não encontrada'
        }
      })
      
      setAssetMovements(mappedMovements)
    } catch (error) {
      console.error('Erro ao buscar movimentações:', error)
      setAssetMovements([])
    }
  }

  const handleCategoryChange = (category: string) => {
    setSelectedCategory(category)
    setSearchTerm("")
  }

  const handleViewDetails = (asset: Asset) => {
    setSelectedAsset(asset)
    setIsDetailOpen(true)
    fetchAssetMovements(asset.id)
  }

  // Contar ativos por categoria
  const getCategoryCount = (categoryId: string) => {
    if (categoryId === "all") return assets.length
    return assets.filter(asset => asset.category_id === categoryId).length
  }

  if (loading) {
    return (
      <div className="flex h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary mx-auto mb-4"></div>
            <p className="text-muted-foreground">Carregando inventário...</p>
          </div>
        </div>
      </div>
    )
  }

  // Verificar se as tabelas existem
  const hasTables = categories.length > 0 || units.length > 0

  if (!hasTables) {
    return (
      <div className="flex h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center max-w-md mx-auto p-8">
            <div className="w-24 h-24 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <Package className="w-12 h-12 text-red-600" />
            </div>
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Tabelas não encontradas</h2>
            <p className="text-gray-600 mb-6">
              As tabelas de inventário não foram encontradas no banco de dados. 
              Execute o script SQL para criar as tabelas necessárias.
            </p>
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 text-left">
              <h3 className="font-semibold text-blue-900 mb-2">Como resolver:</h3>
              <ol className="text-sm text-blue-800 space-y-1">
                <li>1. Acesse o SQL Editor do Supabase</li>
                <li>2. Execute o script: <code className="bg-blue-100 px-2 py-1 rounded">criar_tabelas_inventario_simples.sql</code></li>
                <li>3. Recarregue esta página</li>
              </ol>
            </div>
            <Button 
              onClick={() => window.location.reload()} 
              className="mt-6"
              variant="outline"
            >
              Tentar Novamente
            </Button>
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
          {/* Cabeçalho com perfil do usuário */}
          <div className="flex items-center justify-between mb-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <h1 className="text-3xl font-bold tracking-tight mb-2">Inventário de Ativos</h1>
              <p className="text-muted-foreground">
                Gerencie todos os ativos de TI da empresa
              </p>
            </motion.div>
            <div className="flex items-center gap-4">
              <Button onClick={() => setIsAddUnitOpen(true)} variant="outline" className="flex items-center gap-2">
                <MapPin className="h-4 w-4" />
                Nova Unidade
              </Button>
              <Button onClick={() => setIsAddCategoryOpen(true)} variant="outline" className="flex items-center gap-2">
                <FolderPlus className="h-4 w-4" />
                Nova Categoria
              </Button>
              <Button onClick={() => setIsAddAssetOpen(true)} className="flex items-center gap-2">
                <Plus className="h-4 w-4" />
                Adicionar Ativo
              </Button>
              <UserProfile />
            </div>
          </div>

          {/* Categorias */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-8"
          >
            {/* Categoria "Todos" */}
            <Card
              className={`cursor-pointer transition-all hover:shadow-md ${
                selectedCategory === "all" ? 'ring-2 ring-primary' : ''
              }`}
              onClick={() => handleCategoryChange("all")}
            >
              <CardContent className="p-4 text-center">
                <div className="inline-flex p-3 rounded-full bg-gray-100 text-gray-800 mb-3">
                  <Package className="h-6 w-6" />
                </div>
                <h3 className="font-semibold text-sm mb-1">Todos</h3>
                <p className="text-2xl font-bold text-primary">{getCategoryCount("all")}</p>
              </CardContent>
            </Card>

            {/* Categorias do banco */}
            {categories.map((category) => {
              const Icon = getCategoryIcon(category.icon)
              return (
                <Card
                  key={category.id}
                  className={`cursor-pointer transition-all hover:shadow-md ${
                    selectedCategory === category.id ? 'ring-2 ring-primary' : ''
                  }`}
                  onClick={() => handleCategoryChange(category.id)}
                >
                  <CardContent className="p-4 text-center">
                    <div className={`inline-flex p-3 rounded-full mb-3 ${category.color}`}>
                      <Icon className="h-6 w-6" />
                    </div>
                    <h3 className="font-semibold text-sm mb-1">{category.name}</h3>
                    <p className="text-2xl font-bold text-primary">{getCategoryCount(category.id)}</p>
                  </CardContent>
                </Card>
              )
            })}
          </motion.div>

          {/* Busca e filtros */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="flex gap-4 mb-6"
          >
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Buscar por nome, código, modelo, marca ou responsável..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
          </motion.div>

          {/* Lista de ativos */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Package className="h-5 w-5" />
                  {selectedCategory === "all" 
                    ? "Todos os Ativos" 
                    : categories.find(c => c.id === selectedCategory)?.name
                  } 
                  ({assets.filter(asset => asset.category_id === selectedCategory).length} itens)
                </CardTitle>
                <CardDescription>
                  Lista de todos os ativos da categoria selecionada
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4">
                  {assets.filter(asset => asset.category_id === selectedCategory).map((asset) => (
                    <AssetCard
                      key={asset.id}
                      asset={asset}
                      onViewDetails={() => handleViewDetails(asset)}
                    />
                  ))}
                  {assets.filter(asset => asset.category_id === selectedCategory).length === 0 && (
                    <div className="text-center py-8 text-muted-foreground">
                      Nenhum ativo encontrado para esta categoria
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>

      {/* Modal de detalhes */}
      <Dialog open={isDetailOpen} onOpenChange={setIsDetailOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          {selectedAsset && (
            <>
              <DialogHeader>
                <DialogTitle className="flex items-center gap-2">
                  <Package className="h-5 w-5" />
                  {selectedAsset.code} - {selectedAsset.name}
                </DialogTitle>
                <DialogDescription>
                  Detalhes completos do ativo
                </DialogDescription>
              </DialogHeader>
              
              <div className="space-y-6">
                {/* Informações básicas */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Nome</label>
                    <div className="mt-1 font-medium">{selectedAsset.name}</div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Modelo</label>
                    <div className="mt-1 font-medium">{selectedAsset.model || 'N/A'}</div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Marca</label>
                    <div className="mt-1 font-medium">{selectedAsset.brand || 'N/A'}</div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Categoria</label>
                    <div className="mt-1 font-medium">{selectedAsset.category_name}</div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Unidade</label>
                    <div className="mt-1 flex items-center gap-2">
                      <MapPin className="h-4 w-4" />
                      {selectedAsset.unit_name}
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Responsável</label>
                    <div className="mt-1 flex items-center gap-2">
                      <User className="h-4 w-4" />
                      {selectedAsset.responsible_name}
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Código de Inventário</label>
                    <div className="mt-1 font-mono">{selectedAsset.code}</div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Número de Série</label>
                    <div className="mt-1 font-mono">{selectedAsset.serial_number || 'N/A'}</div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Data de Aquisição</label>
                    <div className="mt-1 flex items-center gap-2">
                      <Calendar className="h-4 w-4" />
                      {formatDate(selectedAsset.acquisition_date)}
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Valor de Compra</label>
                    <div className="mt-1 flex items-center gap-2">
                      <DollarSign className="h-4 w-4" />
                      {formatCurrency(selectedAsset.purchase_value)}
                    </div>
                  </div>
                </div>

                {/* Status */}
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Status</label>
                  <div className="mt-1">
                    <Badge variant="default" className="bg-green-100 text-green-800">
                      {selectedAsset.status}
                    </Badge>
                  </div>
                </div>

                {/* Localização e Notas */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Localização Detalhada</label>
                    <div className="mt-1">{selectedAsset.location_details || 'N/A'}</div>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-muted-foreground">Observações</label>
                    <div className="mt-1">{selectedAsset.notes || 'N/A'}</div>
                  </div>
                </div>

                {/* Histórico de movimentação */}
                <div>
                  <label className="text-sm font-medium text-muted-foreground mb-3 block">
                    Histórico de Movimentação
                  </label>
                  <div className="space-y-3">
                    {assetMovements.length > 0 ? (
                      assetMovements.map((movement: any, index: number) => (
                        <div key={index} className="flex items-center gap-3 p-3 bg-muted rounded-md">
                          <div className="flex-shrink-0">
                            <div className="w-3 h-3 bg-primary rounded-full"></div>
                          </div>
                          <div className="flex-1">
                            <div className="flex justify-between items-start">
                              <span className="font-medium text-sm capitalize">{movement.action}</span>
                              <span className="text-xs text-muted-foreground">{formatDate(movement.performed_at)}</span>
                            </div>
                            <div className="flex items-center gap-2 text-sm text-muted-foreground mt-1">
                              {movement.from_unit_name && (
                                <>
                                  <MapPin className="h-3 w-3" />
                                  {movement.from_unit_name}
                                  <ArrowRight className="h-3 w-3" />
                                </>
                              )}
                              {movement.to_unit_name && (
                                <>
                                  <MapPin className="h-3 w-3" />
                                  {movement.to_unit_name}
                                </>
                              )}
                              {movement.notes && (
                                <>
                                  <FileText className="h-3 w-3" />
                                  {movement.notes}
                                </>
                              )}
                            </div>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-4 text-muted-foreground">
                        Nenhum histórico de movimentação encontrado
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* Modal de adicionar ativo */}
      <Dialog open={isAddAssetOpen} onOpenChange={setIsAddAssetOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Plus className="h-5 w-5" />
              Adicionar Novo Ativo
            </DialogTitle>
            <DialogDescription>
              Preencha as informações do novo ativo
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="code">Código de Inventário *</Label>
                <Input
                  id="code"
                  value={newAsset.code}
                  onChange={(e) => setNewAsset({...newAsset, code: e.target.value})}
                  placeholder="Ex: INV-PC-001"
                />
              </div>
              <div>
                <Label htmlFor="name">Nome do Ativo *</Label>
                <Input
                  id="name"
                  value={newAsset.name}
                  onChange={(e) => setNewAsset({...newAsset, name: e.target.value})}
                  placeholder="Ex: Desktop Dell OptiPlex"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="model">Modelo</Label>
                <Input
                  id="model"
                  value={newAsset.model}
                  onChange={(e) => setNewAsset({...newAsset, model: e.target.value})}
                  placeholder="Ex: OptiPlex 7090"
                />
              </div>
              <div>
                <Label htmlFor="brand">Marca</Label>
                <Input
                  id="brand"
                  value={newAsset.brand}
                  onChange={(e) => setNewAsset({...newAsset, brand: e.target.value})}
                  placeholder="Ex: Dell"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="category">Categoria *</Label>
                <Select value={newAsset.category_id} onValueChange={(value) => setNewAsset({...newAsset, category_id: value})}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione uma categoria" />
                  </SelectTrigger>
                  <SelectContent>
                    {categories.map((category) => (
                      <SelectItem key={category.id} value={category.id}>
                        {category.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="unit">Unidade *</Label>
                <Select value={newAsset.unit_id} onValueChange={(value) => setNewAsset({...newAsset, unit_id: value})}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione uma unidade" />
                  </SelectTrigger>
                  <SelectContent>
                    {units.map((unit) => (
                      <SelectItem key={unit.id} value={unit.id}>
                        {unit.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="responsible">Responsável</Label>
                <Select value={newAsset.responsible_id} onValueChange={(value) => setNewAsset({...newAsset, responsible_id: value})}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione um responsável (opcional)" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">Sem responsável</SelectItem>
                    {users.map((user) => (
                      <SelectItem key={user.id} value={user.id}>
                        {user.full_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="status">Status</Label>
                <Select value={newAsset.status} onValueChange={(value) => setNewAsset({...newAsset, status: value})}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="active">Ativo</SelectItem>
                    <SelectItem value="inactive">Inativo</SelectItem>
                    <SelectItem value="maintenance">Em Manutenção</SelectItem>
                    <SelectItem value="retired">Aposentado</SelectItem>
                    <SelectItem value="lost">Perdido</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="acquisition_date">Data de Aquisição</Label>
                <Input
                  id="acquisition_date"
                  type="date"
                  value={newAsset.acquisition_date}
                  onChange={(e) => setNewAsset({...newAsset, acquisition_date: e.target.value})}
                />
              </div>
              <div>
                <Label htmlFor="purchase_value">Valor de Compra</Label>
                <Input
                  id="purchase_value"
                  type="number"
                  step="0.01"
                  value={newAsset.purchase_value}
                  onChange={(e) => setNewAsset({...newAsset, purchase_value: e.target.value})}
                  placeholder="0.00"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="serial_number">Número de Série</Label>
                <Input
                  id="serial_number"
                  value={newAsset.serial_number}
                  onChange={(e) => setNewAsset({...newAsset, serial_number: e.target.value})}
                  placeholder="Ex: SN-DELL-001"
                />
              </div>
              <div>
                <Label htmlFor="location_details">Localização Detalhada</Label>
                <Input
                  id="location_details"
                  value={newAsset.location_details}
                  onChange={(e) => setNewAsset({...newAsset, location_details: e.target.value})}
                  placeholder="Ex: Sala TI - 2º Andar"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="notes">Observações</Label>
              <Textarea
                id="notes"
                value={newAsset.notes}
                onChange={(e) => setNewAsset({...newAsset, notes: e.target.value})}
                placeholder="Informações adicionais sobre o ativo..."
                rows={3}
              />
            </div>

            <div className="flex justify-end gap-3 pt-4">
              <Button variant="outline" onClick={() => setIsAddAssetOpen(false)}>
                Cancelar
              </Button>
              <Button onClick={handleAddAsset} disabled={!newAsset.code || !newAsset.name || !newAsset.category_id || !newAsset.unit_id}>
                {loading ? 'Adicionando...' : 'Adicionar Ativo'}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Modal de adicionar categoria */}
      <Dialog open={isAddCategoryOpen} onOpenChange={setIsAddCategoryOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <FolderPlus className="h-5 w-5" />
              Nova Categoria de Ativo
            </DialogTitle>
            <DialogDescription>
              Crie uma nova categoria para organizar os ativos do inventário
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <Label htmlFor="category_name">Nome da Categoria *</Label>
              <Input
                id="category_name"
                value={newCategory.name}
                onChange={(e) => setNewCategory({...newCategory, name: e.target.value})}
                placeholder="Ex: Servidores"
              />
            </div>

            <div>
              <Label htmlFor="category_description">Descrição</Label>
              <Textarea
                id="category_description"
                value={newCategory.description}
                onChange={(e) => setNewCategory({...newCategory, description: e.target.value})}
                placeholder="Descreva o tipo de ativos desta categoria..."
                rows={2}
              />
            </div>

            <div>
              <Label htmlFor="category_icon">Ícone</Label>
              <Select value={newCategory.icon} onValueChange={(value) => setNewCategory({...newCategory, icon: value})}>
                <SelectTrigger>
                  <SelectValue placeholder="Selecione um ícone" />
                </SelectTrigger>
                <SelectContent>
                  {availableIcons.map((iconOption) => {
                    const Icon = iconOption.icon
                    return (
                      <SelectItem key={iconOption.value} value={iconOption.value}>
                        <div className="flex items-center gap-2">
                          <Icon className="h-4 w-4" />
                          {iconOption.label}
                        </div>
                      </SelectItem>
                    )
                  })}
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label htmlFor="category_color">Cor</Label>
              <Select value={newCategory.color} onValueChange={(value) => setNewCategory({...newCategory, color: value})}>
                <SelectTrigger>
                  <SelectValue placeholder="Selecione uma cor" />
                </SelectTrigger>
                <SelectContent>
                  {availableColors.map((colorOption) => (
                    <SelectItem key={colorOption.value} value={colorOption.value}>
                      <div className="flex items-center gap-2">
                        <div className={`w-4 h-4 rounded-full ${colorOption.value.split(' ')[0]} ${colorOption.value.split(' ')[1]}`}></div>
                        {colorOption.label}
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="flex justify-end gap-3 pt-4">
              <Button variant="outline" onClick={() => setIsAddCategoryOpen(false)}>
                Cancelar
              </Button>
              <Button onClick={handleAddCategory} disabled={!newCategory.name}>
                Criar Categoria
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Modal de adicionar unidade */}
      <Dialog open={isAddUnitOpen} onOpenChange={setIsAddUnitOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <FolderPlus className="h-5 w-5" />
              Nova Unidade
            </DialogTitle>
            <DialogDescription>
              Crie uma nova unidade para armazenar os ativos
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <Label htmlFor="unit_name">Nome da Unidade *</Label>
              <Input
                id="unit_name"
                value={newUnit.name}
                onChange={(e) => setNewUnit({...newUnit, name: e.target.value})}
                placeholder="Ex: Unidade A"
              />
            </div>

            <div>
              <Label htmlFor="unit_code">Código da Unidade</Label>
              <Input
                id="unit_code"
                value={newUnit.code}
                onChange={(e) => setNewUnit({...newUnit, code: e.target.value})}
                placeholder="Ex: UNIDADE-A"
              />
            </div>

            <div>
              <Label htmlFor="unit_address">Endereço</Label>
              <Input
                id="unit_address"
                value={newUnit.address}
                onChange={(e) => setNewUnit({...newUnit, address: e.target.value})}
                placeholder="Ex: Rua das Flores, 123"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="unit_city">Cidade</Label>
                <Input
                  id="unit_city"
                  value={newUnit.city}
                  onChange={(e) => setNewUnit({...newUnit, city: e.target.value})}
                  placeholder="Ex: São Paulo"
                />
              </div>
              <div>
                <Label htmlFor="unit_state">Estado</Label>
                <Input
                  id="unit_state"
                  value={newUnit.state}
                  onChange={(e) => setNewUnit({...newUnit, state: e.target.value})}
                  placeholder="Ex: SP"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="unit_phone">Telefone</Label>
              <Input
                id="unit_phone"
                value={newUnit.phone}
                onChange={(e) => setNewUnit({...newUnit, phone: e.target.value})}
                placeholder="(11) 1234-5678"
              />
            </div>

            <div>
              <Label htmlFor="unit_status">Status</Label>
              <Select value={newUnit.status} onValueChange={(value) => setNewUnit({...newUnit, status: value})}>
                <SelectTrigger>
                  <SelectValue placeholder="Selecione um status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="active">Ativo</SelectItem>
                  <SelectItem value="inactive">Inativo</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="flex justify-end gap-3 pt-4">
              <Button variant="outline" onClick={() => setIsAddUnitOpen(false)}>
                Cancelar
              </Button>
              <Button onClick={handleAddUnit} disabled={!newUnit.name}>
                Criar Unidade
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
