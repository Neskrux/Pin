# 🚨 Como resolver o erro "Invalid URL"

## O que aconteceu?

O erro `Runtime TypeError: Invalid URL` acontece porque as **variáveis de ambiente do Supabase não estão configuradas**. O projeto precisa se conectar ao Supabase para funcionar.

## ✅ Solução Rápida

### 1. Acesse a página de configuração
Quando você executar `npm run dev`, será automaticamente redirecionado para: 
**http://localhost:3000/setup**

### 2. Siga os passos na página de setup
A página `/setup` irá te guiar através de todo o processo:

1. **Criar projeto no Supabase** (gratuito)
2. **Copiar URL e chave** do projeto
3. **Gerar arquivo .env.local** automaticamente
4. **Executar scripts SQL** no banco

### 3. Passos manuais (se preferir)

#### 3.1. Crie um projeto no Supabase
1. Acesse https://supabase.com
2. Faça login/cadastro (gratuito)
3. Clique em "New Project"
4. Escolha um nome e senha para o banco
5. Aguarde a criação (2-3 minutos)

#### 3.2. Copie as credenciais
1. No painel do Supabase, vá em **Settings → API**
2. Copie:
   - **URL** (algo como: `https://abc123.supabase.co`)
   - **anon/public key** (um token longo começando com `eyJ...`)

#### 3.3. Crie o arquivo .env.local
Na **raiz do projeto** `pin-app/`, crie o arquivo `.env.local`:

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://abc123.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

#### 3.4. Execute os scripts SQL
1. No Supabase, vá em **SQL Editor**
2. Execute primeiro: `database/schema.sql` (cria tabelas)
3. Execute depois: `database/seed.sql` (dados de exemplo)

#### 3.5. Reinicie o servidor
```bash
# Pare o servidor (Ctrl+C) e execute novamente:
npm run dev
```

## 🎯 Resultado Esperado

Depois da configuração:
- ✅ Login funcionará
- ✅ Mapa carregará com dados
- ✅ Check-ins funcionarão
- ✅ Sistema de pontos ativo

## 🆘 Ainda com problemas?

### Erro comum 1: "Table doesn't exist"
**Solução**: Execute o arquivo `database/schema.sql` no SQL Editor do Supabase

### Erro comum 2: "RLS policy violation"  
**Solução**: As políticas RLS estão no `schema.sql` - execute-o completamente

### Erro comum 3: Variáveis não carregam
**Solução**: 
1. Certifique-se que o arquivo se chama exatamente `.env.local`
2. Reinicie o servidor (`npm run dev`)
3. Verifique se não há espaços extras nas variáveis

## 📞 Debug

Para verificar se as variáveis estão carregando:
```bash
# No terminal onde roda o servidor, você deve ver:
# ⚠️  Supabase environment variables are not configured! (se não configurado)
# OU o servidor iniciará normalmente (se configurado)
```

---

**🚀 Após configurar tudo, você terá um aplicativo completo funcionando com mapa, check-ins, gamificação e muito mais!** 