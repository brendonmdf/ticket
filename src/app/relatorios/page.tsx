"use client"

import { motion } from "framer-motion"
import { Sidebar } from "@/components/sidebar"
import { Card, CardContent } from "@/components/ui/card"
import { BarChart3, Construction } from "lucide-react"

export default function RelatoriosPage() {
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
            <div className="flex items-center gap-3 mb-4">
              <BarChart3 className="h-8 w-8 text-primary" />
              <h1 className="text-3xl font-bold tracking-tight">Relatórios</h1>
            </div>
            <p className="text-muted-foreground">
              Sistema de relatórios e análises do TI Management.
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <Card className="max-w-2xl mx-auto">
              <CardContent className="p-12 text-center">
                <Construction className="h-24 w-24 text-muted-foreground mx-auto mb-6" />
                <h2 className="text-2xl font-semibold mb-4">Função em Desenvolvimento</h2>
                <p className="text-muted-foreground text-lg">
                  Esta funcionalidade está sendo desenvolvida e estará disponível em breve.
                </p>
                <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
                  <p className="text-blue-800 text-sm">
                    <strong>Próximas funcionalidades:</strong> Relatórios de tickets, 
                    estatísticas de rede, análise de usuários e métricas de performance.
                  </p>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>
    </div>
  )
}
