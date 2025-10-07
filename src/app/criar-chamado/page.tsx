"use client"

import React, { useState } from "react"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Ticket, User, Building2, AlertCircle, CheckCircle, Clock, MapPin } from "lucide-react"
import { createClient } from "@supabase/supabase-js"
import { useToast } from "@/hooks/use-toast"

// Configuração do Supabase (apenas para inserção de tickets)
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

// Verificar se as variáveis de ambiente estão configuradas
if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Variáveis de ambiente do Supabase não configuradas:', {
    NEXT_PUBLIC_SUPABASE_URL: supabaseUrl,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: supabaseAnonKey ? '***' : 'não configurada'
  })
}

const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '')

export default function CriarChamadoPage() {
  const [formData, setFormData] = useState({
    nome: "",
    email: "",
    telefone: "",
    unidade: "",
    titulo: "",
    descricao: "",
    prioridade: "medium",
    categoria: "geral"
  })
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [debugInfo, setDebugInfo] = useState("")
  const { toast } = useToast()
  const [logoSrc, setLogoSrc] = useState<string>("/logo.png")

  // Debug: Verificar configuração do Supabase
  React.useEffect(() => {
    const debug = {
      supabaseUrl: supabaseUrl ? 'Configurada' : 'Não configurada',
      supabaseAnonKey: supabaseAnonKey ? 'Configurada' : 'Não configurada',
      envCheck: {
        NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL ? 'Sim' : 'Não',
        NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ? 'Sim' : 'Não'
      }
    }
    setDebugInfo(JSON.stringify(debug, null, 2))
    console.log('Debug Supabase:', debug)
  }, [])

  // Debug: Mostrar informações de configuração (apenas em desenvolvimento)
  const showDebug = process.env.NODE_ENV === 'development'

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      // Validar campos obrigatórios
      if (!formData.nome || !formData.email || !formData.titulo || !formData.descricao) {
        toast({
          title: "Campos obrigatórios",
          description: "Por favor, preencha todos os campos obrigatórios.",
          variant: "destructive"
        })
        setLoading(false)
        return
      }

      // Gerar número único do ticket
      const ticketNumber = `TKT-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`

      // Preparar dados do ticket
      const ticketData = {
        ticket_number: ticketNumber,
        title: formData.titulo,
        description: formData.descricao,
        priority: formData.prioridade,
        status: 'open',
        category: formData.categoria,
        requester_name: formData.nome,
        requester_email: formData.email,
        requester_phone: formData.telefone || null,
        unit_name: formData.unidade || null,
        source: 'external_form',
        created_at: new Date().toISOString()
      }

      console.log('Dados do ticket sendo enviados:', ticketData)

      // Criar o ticket no banco
      const { data, error } = await supabase
        .from('tickets')
        .insert([ticketData])
        .select()

      if (error) {
        console.error('Erro ao criar ticket:', error)
        console.error('Detalhes do erro:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code
        })
        toast({
          title: "Erro ao criar chamado",
          description: `Erro: ${error.message || 'Não foi possível criar o chamado'}`,
          variant: "destructive"
        })
        return
      }

      setSuccess(true)
      toast({
        title: "Chamado criado com sucesso!",
        description: `Seu ticket ${ticketNumber} foi registrado.`,
      })

      // Limpar formulário
      setFormData({
        nome: "",
        email: "",
        telefone: "",
        unidade: "",
        titulo: "",
        descricao: "",
        prioridade: "medium",
        categoria: "geral"
      })

    } catch (error) {
      console.error('Erro:', error)
      toast({
        title: "Erro inesperado",
        description: "Ocorreu um erro. Tente novamente.",
        variant: "destructive"
      })
    } finally {
      setLoading(false)
    }
  }

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  if (success) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center p-4">
        <Card className="w-full max-w-md text-center">
          <CardContent className="pt-6">
            <div className="flex justify-center mb-4">
              <div className="p-3 bg-green-100 rounded-full">
                <CheckCircle className="h-8 w-8 text-green-600" />
              </div>
            </div>
            <h2 className="text-2xl font-bold text-green-800 mb-2">
              Chamado Criado com Sucesso!
            </h2>
            <p className="text-gray-600 mb-6">
              Seu ticket foi registrado em nosso sistema. Nossa equipe entrará em contato em breve.
            </p>
            <Button 
              onClick={() => setSuccess(false)}
              className="w-full bg-blue-600 hover:bg-blue-700"
            >
              Criar Novo Chamado
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="h-8 w-8 rounded-lg overflow-hidden bg-white flex items-center justify-center">
                <Image
                  src={logoSrc}
                  alt="Logo da empresa"
                  width={32}
                  height={32}
                  className="object-contain"
                  onError={() => setLogoSrc("/favicon.ico")}
                  priority
                />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Sistema de Chamados</h1>
                <p className="text-sm text-gray-600">Crie seu chamado de forma rápida e simples</p>
              </div>
            </div>
            <Badge variant="outline" className="text-blue-600 border-blue-200">
              <Clock className="h-3 w-3 mr-1" />
              Resposta em até 24h
            </Badge>
          </div>
        </div>
      </div>

      {/* Conteúdo Principal */}
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Formulário */}
          <div className="lg:col-span-2">
            <Card className="shadow-lg">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Ticket className="h-5 w-5" />
                  Criar Novo Chamado
                </CardTitle>
                <CardDescription>
                  Preencha os dados abaixo para abrir um chamado técnico
                </CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit} className="space-y-6">
                  {/* Informações Pessoais */}
                  <div className="space-y-4">
                    <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
                      <User className="h-4 w-4" />
                      Informações Pessoais
                    </h3>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <label htmlFor="nome" className="text-sm font-medium">
                          Nome Completo *
                        </label>
                        <Input
                          id="nome"
                          value={formData.nome}
                          onChange={(e) => handleInputChange('nome', e.target.value)}
                          required
                          placeholder="Seu nome completo"
                        />
                      </div>
                      <div className="space-y-2">
                        <label htmlFor="email" className="text-sm font-medium">
                          Email *
                        </label>
                        <Input
                          id="email"
                          type="email"
                          value={formData.email}
                          onChange={(e) => handleInputChange('email', e.target.value)}
                          required
                          placeholder="seu@email.com"
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <label htmlFor="telefone" className="text-sm font-medium">
                        Telefone
                      </label>
                      <Input
                        id="telefone"
                        value={formData.telefone}
                        onChange={(e) => handleInputChange('telefone', e.target.value)}
                        placeholder="(19) 99990-9999"
                      />
                    </div>
                  </div>

                  {/* Informações da Unidade */}
                  <div className="space-y-4">
                    <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
                      <Building2 className="h-4 w-4" />
                      Localização
                    </h3>
                    <div className="space-y-2">
                      <label htmlFor="unidade" className="text-sm font-medium">
                        Unidade/Loja *
                      </label>
                      <Input
                        id="unidade"
                        value={formData.unidade}
                        onChange={(e) => handleInputChange('unidade', e.target.value)}
                        required
                        placeholder="Nome da unidade ou endereço"
                      />
                    </div>
                  </div>

                  {/* Detalhes do Chamado */}
                  <div className="space-y-4">
                    <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
                      <AlertCircle className="h-4 w-4" />
                      Detalhes do Chamado
                    </h3>
                    <div className="space-y-2">
                      <label htmlFor="titulo" className="text-sm font-medium">
                        Título do Problema *
                      </label>
                      <Input
                        id="titulo"
                        value={formData.titulo}
                        onChange={(e) => handleInputChange('titulo', e.target.value)}
                        required
                        placeholder="Descreva brevemente o problema"
                      />
                    </div>
                    <div className="space-y-2">
                      <label htmlFor="descricao" className="text-sm font-medium">
                        Descrição Detalhada *
                      </label>
                      <Textarea
                        id="descricao"
                        value={formData.descricao}
                        onChange={(e) => handleInputChange('descricao', e.target.value)}
                        required
                        placeholder="Descreva detalhadamente o problema, incluindo passos para reproduzir, mensagens de erro, etc."
                        rows={4}
                      />
                    </div>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <label htmlFor="prioridade" className="text-sm font-medium">
                          Prioridade
                        </label>
                        <Select
                          value={formData.prioridade}
                          onValueChange={(value) => handleInputChange('prioridade', value)}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="low">Baixa</SelectItem>
                            <SelectItem value="medium">Média</SelectItem>
                            <SelectItem value="high">Alta</SelectItem>
                            <SelectItem value="critical">Crítica</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="space-y-2">
                        <label htmlFor="categoria" className="text-sm font-medium">
                          Categoria
                        </label>
                        <Select
                          value={formData.categoria}
                          onValueChange={(value) => handleInputChange('categoria', value)}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="hardware">Hardware</SelectItem>
                            <SelectItem value="software">Software</SelectItem>
                            <SelectItem value="network">Rede</SelectItem>
                            <SelectItem value="access">Acesso/Usuário</SelectItem>
                            <SelectItem value="geral">Geral</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                  </div>

                  {/* Botão de Envio */}
                  <Button
                    type="submit"
                    className="w-full bg-blue-600 hover:bg-blue-700 text-lg py-3"
                    disabled={loading}
                  >
                    {loading ? (
                      <div className="flex items-center gap-2">
                        <div className="h-5 w-5 animate-spin rounded-full border-2 border-white border-t-transparent" />
                        Criando Chamado...
                      </div>
                    ) : (
                      "Criar Chamado"
                    )}
                  </Button>
                </form>
              </CardContent>
            </Card>
          </div>

          {/* Sidebar com Informações */}
          <div className="space-y-6">
            {/* Card de Informações */}
            <Card className="bg-blue-50 border-blue-200">
              <CardHeader>
                <CardTitle className="text-blue-900 flex items-center gap-2">
                  <MapPin className="h-5 w-5" />
                  Como Funciona
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <div className="flex items-start gap-3">
                    <div className="p-1 bg-blue-600 rounded-full mt-1">
                      <div className="h-2 w-2 bg-white rounded-full" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-blue-900">1. Preencha o Formulário</p>
                      <p className="text-xs text-blue-700">Forneça todas as informações necessárias</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="p-1 bg-blue-600 rounded-full mt-1">
                      <div className="h-2 w-2 bg-white rounded-full" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-blue-900">2. Ticket é Criado</p>
                      <p className="text-xs text-blue-700">Sistema gera número único de acompanhamento</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="p-1 bg-blue-600 rounded-full mt-1">
                      <div className="h-2 w-2 bg-white rounded-full" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-blue-900">3. Equipe Atende</p>
                      <p className="text-xs text-blue-700">Técnicos analisam e entram em contato</p>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Card de Contato */}
            <Card className="bg-gray-50 border-gray-200">
              <CardHeader>
                <CardTitle className="text-gray-900">Precisa de Ajuda?</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-600 mb-3">
                  Se tiver dúvidas sobre como criar um chamado ou precisar de suporte urgente:
                </p>
                <div className="space-y-2 text-sm">
                  <p className="flex items-center gap-2">
                    <span className="font-medium">Email:</span>
                    <span className="text-blue-600">ti@bemtefaz.com.br</span>
                  </p>
                  <p className="flex items-center gap-2">
                    <span className="font-medium">Telefone:</span>
                    <span className="text-blue-600">(19) 99990-4443</span>
                  </p>
                </div>
              </CardContent>
            </Card>

            {/* Card de Estatísticas */}
            <Card className="bg-green-50 border-green-200">
              <CardHeader>
                <CardTitle className="text-green-900">Nossos Números</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-green-700">Tempo Médio de Resposta</span>
                    <Badge variant="secondary" className="bg-green-100 text-green-800">
                      &lt; 2 horas
                    </Badge>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-green-700">Chamados Resolvidos</span>
                    <Badge variant="secondary" className="bg-green-100 text-green-800">
                      98%
                    </Badge>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-green-700">Satisfação</span>
                    <Badge variant="secondary" className="bg-green-100 text-green-800">
                      4.8/5
                    </Badge>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Debug Info - Apenas em desenvolvimento */}
            {showDebug && (
              <Card className="bg-yellow-50 border-yellow-200">
                <CardHeader>
                  <CardTitle className="text-yellow-900 text-sm">Debug Info</CardTitle>
                </CardHeader>
                <CardContent>
                  <pre className="text-xs text-yellow-800 bg-yellow-100 p-2 rounded overflow-auto">
                    {debugInfo}
                  </pre>
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
