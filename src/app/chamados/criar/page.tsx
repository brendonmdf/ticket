"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { useToast } from "@/hooks/use-toast"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { FileText, CheckCircle, AlertCircle, Clock } from "lucide-react"

const urgencyOptions = [
  { value: "baixa", label: "Baixa", color: "bg-green-100 text-green-800", icon: Clock },
  { value: "media", label: "Média", color: "bg-yellow-100 text-yellow-800", icon: AlertCircle },
  { value: "alta", label: "Alta", color: "bg-red-100 text-red-800", icon: AlertCircle },
]

const units = [
  "Loja Centro",
  "Loja Norte", 
  "Loja Sul",
  "Loja Leste",
  "Escritório Central",
  "Depósito",
  "Outro"
]

export default function CriarChamadoPage() {
  const [formData, setFormData] = useState({
    motivo: "",
    nome: "",
    unidade: "",
    urgencia: "",
    descricao: ""
  })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const { toast } = useToast()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSubmitting(true)
    
    // Simular envio
    setTimeout(() => {
      setIsSubmitting(false)
      toast({
        title: "✅ Ticket criado com sucesso!",
        description: "Seu chamado foi registrado e será atendido em breve.",
      })
      
      // Limpar formulário
      setFormData({
        motivo: "",
        nome: "",
        unidade: "",
        urgencia: "",
        descricao: ""
      })
    }, 2000)
  }

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-12 px-4">
      <div className="max-w-2xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-8"
        >
          <div className="flex justify-center mb-4">
            <div className="p-3 bg-primary rounded-full">
              <FileText className="h-8 w-8 text-white" />
            </div>
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Criar Novo Chamado
          </h1>
          <p className="text-gray-600">
            Preencha o formulário abaixo para abrir um ticket de suporte
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <Card className="shadow-xl">
            <CardHeader>
              <CardTitle>Informações do Chamado</CardTitle>
              <CardDescription>
                Descreva detalhadamente o problema para melhor atendimento
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Motivo do chamado */}
                <div className="space-y-2">
                  <label htmlFor="motivo" className="text-sm font-medium text-gray-700">
                    Motivo do Chamado *
                  </label>
                  <Input
                    id="motivo"
                    placeholder="Ex: Impressora não funciona, Internet lenta..."
                    value={formData.motivo}
                    onChange={(e) => handleChange("motivo", e.target.value)}
                    required
                    className="transition-all focus:ring-2 focus:ring-primary"
                  />
                </div>

                {/* Nome do solicitante */}
                <div className="space-y-2">
                  <label htmlFor="nome" className="text-sm font-medium text-gray-700">
                    Nome do Solicitante *
                  </label>
                  <Input
                    id="nome"
                    placeholder="Seu nome completo"
                    value={formData.nome}
                    onChange={(e) => handleChange("nome", e.target.value)}
                    required
                    className="transition-all focus:ring-2 focus:ring-primary"
                  />
                </div>

                {/* Unidade */}
                <div className="space-y-2">
                  <label htmlFor="unidade" className="text-sm font-medium text-gray-700">
                    Unidade *
                  </label>
                  <Select value={formData.unidade} onValueChange={(value) => handleChange("unidade", value)}>
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione sua unidade" />
                    </SelectTrigger>
                    <SelectContent>
                      {units.map((unit) => (
                        <SelectItem key={unit} value={unit}>
                          {unit}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Nível de urgência */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-gray-700">
                    Nível de Urgência *
                  </label>
                  <div className="grid grid-cols-3 gap-3">
                    {urgencyOptions.map((option) => {
                      const Icon = option.icon
                      return (
                        <button
                          key={option.value}
                          type="button"
                          onClick={() => handleChange("urgencia", option.value)}
                          className={`p-3 rounded-lg border-2 transition-all ${
                            formData.urgencia === option.value
                              ? "border-primary bg-primary/5"
                              : "border-gray-200 hover:border-gray-300"
                          }`}
                        >
                          <div className="flex flex-col items-center space-y-2">
                            <Icon className={`h-5 w-5 ${option.color.split(' ')[1]}`} />
                            <span className={`text-sm font-medium ${option.color.split(' ')[1]}`}>
                              {option.label}
                            </span>
                          </div>
                        </button>
                      )
                    })}
                  </div>
                </div>

                {/* Descrição detalhada */}
                <div className="space-y-2">
                  <label htmlFor="descricao" className="text-sm font-medium text-gray-700">
                    Descrição Detalhada *
                  </label>
                  <Textarea
                    id="descricao"
                    placeholder="Descreva o problema em detalhes, incluindo passos para reproduzir, mensagens de erro, etc."
                    value={formData.descricao}
                    onChange={(e) => handleChange("descricao", e.target.value)}
                    required
                    rows={4}
                    className="transition-all focus:ring-2 focus:ring-primary"
                  />
                </div>

                {/* Botão de envio */}
                <Button
                  type="submit"
                  className="w-full h-12 text-lg"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? (
                    <div className="flex items-center space-x-2">
                      <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                      <span>Enviando...</span>
                    </div>
                  ) : (
                    <div className="flex items-center space-x-2">
                      <FileText className="h-5 w-5" />
                      <span>Criar Chamado</span>
                    </div>
                  )}
                </Button>
              </form>
            </CardContent>
          </Card>
        </motion.div>

        {/* Informações adicionais */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="mt-8 text-center"
        >
          <p className="text-sm text-gray-600">
            Após o envio, você receberá um número de protocolo para acompanhamento
          </p>
        </motion.div>
      </div>
    </div>
  )
}
