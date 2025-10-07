"use client"

import { useState } from "react"
import { useAuth } from "@/hooks/useAuth"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Server } from "lucide-react"

export default function LoginPage() {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const { signIn, loading, error, clearError } = useAuth()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    clearError()
    
    const result = await signIn(email, password)
    
    if (!result.success) {
      // O erro já é gerenciado pelo hook useAuth
      console.error('Erro no login:', result.error)
    }
  }

  return (
    <div className="min-h-screen flex flex-col lg:flex-row">
      {/* Lado esquerdo - Imagem de datacenter */}
      <div className="lg:hidden h-48 bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900 relative overflow-hidden">
        <div className="absolute inset-0 bg-black/40" />
        
        {/* Imagem de fundo de datacenter para mobile */}
        <div className="absolute inset-0">
          <Image
            src="/datacenter-bg.jpg?v=1"
            alt="Data Center de alta tecnologia com servidores e infraestrutura moderna"
            fill
            className="object-cover opacity-85"
            priority
            onLoad={() => {
              console.log('✅ Imagem mobile carregada com sucesso');
            }}
            onError={(e) => {
              console.log('❌ Erro ao carregar imagem mobile:', e);
              const target = e.target as HTMLImageElement;
              target.style.display = 'none';
            }}
          />
        </div>
        
        {/* Fallback gradiente para mobile */}
        <div className="absolute inset-0 bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900" />
        
        {/* Overlay para mobile */}
        <div className="absolute inset-0 bg-gradient-to-br from-blue-900/70 via-blue-800/50 to-indigo-900/70" />
        
        {/* Indicador de debug */}
        <div data-fallback="mobile" className="absolute top-2 left-2 z-20 bg-black/50 text-white text-xs px-2 py-1 rounded">
          Mobile - Fallback Ativo
        </div>
        
        <div className="relative z-10 flex flex-col justify-center items-center text-white p-6">
          <div className="text-center">
            <div className="flex justify-center mb-4">
              <div className="p-3 bg-white/20 rounded-full backdrop-blur-sm">
                <Server className="h-10 w-10" />
              </div>
            </div>
            <h1 className="text-2xl font-bold mb-2">Kyndo</h1>
            <p className="text-sm text-blue-100 max-w-xs">
              Gerencie sua infraestrutura de TI com eficiência
            </p>
          </div>
        </div>
      </div>

      {/* Lado esquerdo - Imagem de datacenter para desktop */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900 relative overflow-hidden">
        <div className="absolute inset-0 bg-black/30" />
        
        {/* Imagem de fundo de datacenter */}
        <div className="absolute inset-0">
          <Image
            src="/datacenter-bg.jpg?v=1"
            alt="Data Center de alta tecnologia com servidores e infraestrutura moderna"
            fill
            className="object-cover opacity-85"
            priority
            onLoad={() => {
              console.log('✅ Imagem desktop carregada com sucesso');
            }}
            onError={(e) => {
              console.log('❌ Erro ao carregar imagem desktop:', e);
              const target = e.target as HTMLImageElement;
              target.style.display = 'none';
            }}
          />
        </div>
        
        {/* Fallback gradiente caso a imagem não carregue */}
        <div className="absolute inset-0 bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900" />
        
        {/* Overlay com gradiente azul para combinar com a imagem */}
        <div className="absolute inset-0 bg-gradient-to-br from-blue-900/70 via-blue-800/50 to-indigo-900/70" />
        
        <div className="relative z-10 flex flex-col justify-center items-center text-white p-12">
          <div className="text-center">
            <div className="flex justify-center mb-6">
              <div className="p-4 bg-white/20 rounded-full backdrop-blur-sm">
                <Server className="h-16 w-16" />
              </div>
            </div>
            <h1 className="text-4xl font-bold mb-4">Kyndo</h1>
            <p className="text-xl text-blue-100 max-w-md">
              Gerencie sua infraestrutura de TI com eficiência e controle total
            </p>
          </div>
        </div>
      </div>

      {/* Lado direito - Formulário */}
      <div className="flex-1 flex items-center justify-center p-8 bg-gray-50">
        <div className="w-full max-w-md">
          <Card className="shadow-xl">
            <CardHeader className="text-center">
              <div className="flex justify-center mb-4">
                <div className="p-3 bg-blue-600 rounded-full">
                  <Server className="h-8 w-8 text-white" />
                </div>
              </div>
              <CardTitle className="text-2xl">Bem-vindo de volta</CardTitle>
              <CardDescription>
                Faça login para acessar sua plataforma de gestão de TI
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                {/* Mensagem de erro */}
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-md">
                    <p className="text-sm text-red-600">{error}</p>
                  </div>
                )}

                <div className="space-y-2">
                  <label htmlFor="email" className="text-sm font-medium">
                    Email
                  </label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="seu@email.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="w-full"
                    disabled={loading}
                  />
                </div>
                <div className="space-y-2">
                  <label htmlFor="password" className="text-sm font-medium">
                    Senha
                  </label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    className="w-full"
                    disabled={loading}
                  />
                </div>
                <Button
                  type="submit"
                  className="w-full bg-blue-600 hover:bg-blue-700"
                  disabled={loading}
                >
                  {loading ? (
                    <div className="flex items-center gap-2">
                      <div className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                      Entrando...
                    </div>
                  ) : (
                    "Entrar"
                  )}
                </Button>
              </form>
              
              <div className="mt-6 text-center space-y-3">
                <p className="text-sm text-gray-600">
                  Use suas credenciais do Supabase
                </p>
                <div className="pt-3 border-t border-gray-200">
                  <p className="text-sm text-gray-500 mb-2">
                    Não tem acesso ao sistema?
                  </p>
                  <Button
                    variant="outline"
                    className="w-full text-blue-600 border-blue-200 hover:bg-blue-50"
                    onClick={() => window.location.href = '/criar-chamado'}
                  >
                    Criar Chamado Externo
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
