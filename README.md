# Kyndo - Sistema de Gestão de TI

Sistema completo para gerenciamento de infraestrutura de TI, incluindo inventário, tickets de suporte, gestão de usuários e monitoramento de rede.

## 🚀 Funcionalidades

- **Dashboard** - Visão geral do sistema
- **Inventário** - Gestão de equipamentos e ativos
- **Tickets** - Sistema de chamados e suporte
- **Usuários** - Gestão de usuários e permissões
- **Rede** - Monitoramento de infraestrutura
- **Relatórios** - Análises e métricas
- **Configurações** - Personalização do sistema

## 🎨 Interface

### Tela de Login
- **Design moderno** com imagem de data center no lado esquerdo
- **Responsivo** para desktop e mobile
- **Gradientes azuis** que combinam com o tema tecnológico
- **Fallback visual** caso a imagem não carregue

### Layout Responsivo
- **Desktop**: Imagem de data center em tela cheia no lado esquerdo
- **Mobile**: Imagem compacta no topo com formulário abaixo
- **Adaptação automática** para diferentes tamanhos de tela

## 📱 Como Usar

1. **Clone o repositório**
2. **Instale as dependências**: `npm install`
3. **Configure o Supabase** (veja `CONFIGURACAO_SUPABASE.md`)
4. **Adicione a imagem de data center** (veja `public/README-IMAGENS.md`)
5. **Execute**: `npm run dev`

## 🖼️ Configuração de Imagens

Para a tela de login funcionar corretamente, você precisa adicionar uma imagem de data center:

1. **Baixe uma imagem** de data center moderna (1920x1080 ou maior)
2. **Salve como** `datacenter-bg.jpg` na pasta `public/`
3. **Formatos suportados**: JPG, PNG, WebP

Veja `public/README-IMAGENS.md` para instruções detalhadas.

## 🛠️ Tecnologias

- **Frontend**: Next.js 14, React, TypeScript
- **UI**: Tailwind CSS, Shadcn/ui
- **Backend**: Supabase (PostgreSQL, Auth, RLS)
- **Deploy**: Vercel, Supabase

## 📚 Documentação

- `CONFIGURACAO_SUPABASE.md` - Configuração do banco de dados
- `SISTEMA_USUARIOS_README.md` - Gestão de usuários
- `SOLUCAO_CHAMADOS_README.md` - Sistema de tickets
- `MONITORAMENTO_REAL.md` - Monitoramento em tempo real
- `PRODUCAO_LOCAL.md` - Deploy local para produção

## 🔧 Desenvolvimento

```bash
# Instalar dependências
npm install

# Executar em desenvolvimento
npm run dev

# Build para produção
npm run build

# Executar testes
npm test
```

## 📄 Licença

Este projeto é privado e proprietário da Kyndo.
