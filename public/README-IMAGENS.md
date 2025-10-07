# Configuração de Imagens

## Imagem de Data Center para Login

Para adicionar a imagem de data center na tela de login, você tem **duas opções**:

## 🖼️ Opção 1: Imagem Local (Recomendado)

1. **Baixe uma imagem de data center** de alta qualidade (recomendado: 1920x1080 ou maior)
2. **Salve a imagem** na pasta `public/` com o nome `datacenter-bg.jpg`
3. **Formatos suportados**: JPG, PNG, WebP

### Características recomendadas para a imagem:
- **Tema**: Data center moderno com servidores, racks e infraestrutura tecnológica
- **Cores**: Tons de azul, preto e cinza (para combinar com o tema da aplicação)
- **Estilo**: Profissional, tecnológico, com boa iluminação
- **Resolução**: Mínimo 1920x1080 para boa qualidade em telas grandes

### Exemplo de busca:
Procure por termos como:
- "data center server room"
- "server rack infrastructure"
- "modern data center technology"
- "server room blue lights"

### Sites recomendados para imagens gratuitas:
- Unsplash
- Pexels
- Pixabay
- Freepik

### Sites para imagens premium:
- Shutterstock
- iStock
- Adobe Stock

## 🌐 Opção 2: Imagem Online (Temporário)

Se você não quiser baixar uma imagem agora, pode usar uma URL online. A aplicação já está configurada com uma imagem do Unsplash como exemplo.

**Para usar sua própria imagem online:**
1. Faça upload da imagem para um serviço como Imgur, Cloudinary ou similar
2. Copie a URL da imagem
3. Substitua no arquivo `src/app/page.tsx`:

```tsx
// Altere esta linha:
src="https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=1920&h=1080&fit=crop&auto=format"

// Para sua URL:
src="https://sua-url-da-imagem.jpg"
```

## ⚠️ Resolução de Problemas

### Erro: "The requested resource isn't a valid image"
**Causa**: O arquivo `datacenter-bg.jpg` não existe na pasta `public/`
**Solução**: 
- Adicione a imagem na pasta `public/` com o nome correto, OU
- Use uma URL online válida

### Imagem não carrega
**Causa**: Problemas de rede ou URL inválida
**Solução**: A aplicação tem fallback automático para gradiente azul

## 📁 Estrutura de arquivos:
```
public/
├── datacenter-bg.jpg  ← Adicione sua imagem aqui (Opção 1)
├── favicon.ico
├── manifest.json
└── README-IMAGENS.md
```

## 🚀 Como Testar

1. **Com imagem local**: Adicione `datacenter-bg.jpg` na pasta `public/`
2. **Com imagem online**: Use uma URL válida no código
3. **Execute**: `npm run dev`
4. **Acesse**: A tela de login para ver o resultado

Após configurar corretamente, a imagem aparecerá automaticamente no lado esquerdo da tela de login.
