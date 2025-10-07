"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { UserProfile } from "@/components/user-profile"
import {
  BarChart3,
  FileText,
  Home,
  Network,
  Package,
  Settings,
  Users,
} from "lucide-react"

const sidebarItems = [
  {
    title: "Dashboard",
    href: "/dashboard",
    icon: Home,
  },
  {
    title: "Chamados",
    href: "/chamados",
    icon: FileText,
  },
  {
    title: "Inventário",
    href: "/inventario",
    icon: Package,
  },
  {
    title: "Rede",
    href: "/rede",
    icon: Network,
  },
  {
    title: "Relatórios",
    href: "/relatorios",
    icon: BarChart3,
  },
  {
    title: "Usuários",
    href: "/usuarios",
    icon: Users,
  },
  {
    title: "Configurações",
    href: "/configuracoes",
    icon: Settings,
  },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <div className="flex h-full w-64 flex-col bg-background border-r">
      <div className="flex h-16 items-center border-b px-6">
        <div className="flex items-center gap-3">
          <div className="relative w-8 h-8">
            {/* Logo inspirado no nó geométrico com 6 elementos entrelaçados */}
            <svg viewBox="0 0 32 32" className="w-full h-full">
              {/* Elemento 1 - Faixa superior direita */}
              <path 
                d="M16 8 Q20 8 24 12 Q24 16 20 20 Q16 20 12 16 Q12 12 16 8 Z" 
                fill="url(#gradient1)" 
                className="drop-shadow-sm"
              />
              
              {/* Elemento 2 - Faixa superior esquerda */}
              <path 
                d="M16 8 Q12 8 8 12 Q8 16 12 20 Q16 20 20 16 Q20 12 16 8 Z" 
                fill="url(#gradient2)" 
                className="drop-shadow-sm"
              />
              
              {/* Elemento 3 - Faixa direita */}
              <path 
                d="M24 12 Q28 16 24 20 Q20 20 16 16 Q16 12 20 8 Q24 8 24 12 Z" 
                fill="url(#gradient1)" 
                className="drop-shadow-sm"
              />
              
              {/* Elemento 4 - Faixa esquerda */}
              <path 
                d="M8 12 Q4 16 8 20 Q12 20 16 16 Q16 12 12 8 Q8 8 8 12 Z" 
                fill="url(#gradient2)" 
                className="drop-shadow-sm"
              />
              
              {/* Elemento 5 - Faixa inferior direita */}
              <path 
                d="M16 24 Q20 24 24 20 Q20 16 16 16 Q12 16 8 20 Q12 24 16 24 Z" 
                fill="url(#gradient1)" 
                className="drop-shadow-sm"
              />
              
              {/* Elemento 6 - Faixa inferior esquerda */}
              <path 
                d="M16 24 Q12 24 8 20 Q12 16 16 16 Q20 16 24 20 Q20 24 16 24 Z" 
                fill="url(#gradient2)" 
                className="drop-shadow-sm"
              />
              
              {/* Gradientes */}
              <defs>
                <linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="#9333ea" />
                  <stop offset="100%" stopColor="#3b82f6" />
                </linearGradient>
                <linearGradient id="gradient2" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="#7c3aed" />
                  <stop offset="100%" stopColor="#1d4ed8" />
                </linearGradient>
              </defs>
            </svg>
          </div>
          <h1 className="text-xl font-bold text-primary">Kyndo</h1>
        </div>
      </div>
      <nav className="flex-1 space-y-1 p-4">
        {sidebarItems.map((item) => {
          const Icon = item.icon
          const isActive = pathname === item.href
          
          return (
            <Link key={item.href} href={item.href}>
              <Button
                variant={isActive ? "secondary" : "ghost"}
                className={cn(
                  "w-full justify-start gap-3",
                  isActive && "bg-secondary text-secondary-foreground"
                )}
              >
                <Icon className="h-4 w-4" />
                {item.title}
              </Button>
            </Link>
          )
        })}
      </nav>
      <div className="border-t p-4">
        <UserProfile />
      </div>
    </div>
  )
}
