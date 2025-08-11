# PIN - Descubra onde está todo mundo

Um aplicativo web para descobrir locais, fazer check-ins e encontrar amigos em tempo real.

## 🚀 Funcionalidades

- **Mapa em tempo real** com localização de pessoas e eventos
- **Sistema de check-ins** com pontos e gamificação
- **Filtros inteligentes** por categoria e quantidade de pessoas
- **Sistema de amigos** para ver onde estão seus conhecidos
- **Timeline ao vivo** com fotos e vídeos dos locais
- **Sistema de pontos** com benefícios exclusivos
- **Estabelecimentos parceiros** com destaque no mapa
- **Painel administrativo** para moderação

## 🛠️ Stack Tecnológica

- **Frontend**: Next.js 15 (App Router)
- **Linguagem**: TypeScript
- **Backend**: Supabase (Auth, Realtime, Database, Storage)
- **Estilização**: TailwindCSS
- **Mapa**: Leaflet.js
- **Validação**: Zod
- **UI Components**: Radix UI + shadcn/ui

## 📦 Instalação

### Pré-requisitos

- Node.js 18+ 
- npm ou yarn
- Conta no Supabase

### 1. Clone o repositório

```bash
git clone <repository-url>
cd pin-app
```

### 2. Instale as dependências

```bash
npm install
```

### 3. Configure as variáveis de ambiente

Copie o arquivo de exemplo:

```bash
cp env.example .env.local
```

Edite o arquivo `.env.local` com suas credenciais do Supabase:

```env
NEXT_PUBLIC_SUPABASE_URL=sua_url_do_supabase
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_chave_anonima_do_supabase
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 4. Configure o Supabase

#### 4.1. Crie um projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Crie um novo projeto
3. Anote a URL e a chave anônima

#### 4.2. Configure o banco de dados

Execute os seguintes comandos SQL no editor SQL do Supabase:

```sql
-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de usuários (estendida)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar_url TEXT,
  phone TEXT,
  points INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de locais
CREATE TABLE public.locations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('bar', 'restaurant', 'club', 'event', 'cafe', 'shopping', 'entertainment', 'other')),
  average_price DECIMAL(10, 2),
  opening_hours TEXT,
  phone TEXT,
  website TEXT,
  is_partner BOOLEAN DEFAULT FALSE,
  is_highlighted BOOLEAN DEFAULT FALSE,
  highlight_expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de check-ins
CREATE TABLE public.check_ins (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE,
  privacy TEXT NOT NULL CHECK (privacy IN ('public', 'friends', 'private')),
  points_earned INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de pins (posts com mídia)
CREATE TABLE public.pins (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE,
  privacy TEXT NOT NULL CHECK (privacy IN ('public', 'friends', 'private')),
  content TEXT,
  media_urls TEXT[],
  media_type TEXT CHECK (media_type IN ('image', 'video')),
  points_earned INTEGER DEFAULT 20,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de avaliações
CREATE TABLE public.reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  points_earned INTEGER DEFAULT 15,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de amizades
CREATE TABLE public.friendships (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  friend_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- Tabela de notificações
CREATE TABLE public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('check_in', 'friend_request', 'points_earned', 'level_up', 'benefit_unlocked', 'location_highlight')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de assinaturas de parceiros
CREATE TABLE public.partner_subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE,
  plan TEXT NOT NULL CHECK (plan IN ('basic', 'premium')),
  status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'expired')),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_check_ins_user_id ON public.check_ins(user_id);
CREATE INDEX idx_check_ins_location_id ON public.check_ins(location_id);
CREATE INDEX idx_check_ins_created_at ON public.check_ins(created_at);
CREATE INDEX idx_pins_location_id ON public.pins(location_id);
CREATE INDEX idx_pins_created_at ON public.pins(created_at);
CREATE INDEX idx_locations_category ON public.locations(category);
CREATE INDEX idx_locations_coordinates ON public.locations(latitude, longitude);

-- Função para atualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar timestamps
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_pins_updated_at BEFORE UPDATE ON public.pins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_friendships_updated_at BEFORE UPDATE ON public.friendships FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_subscriptions ENABLE ROW LEVEL SECURITY;

-- Políticas RLS básicas (ajuste conforme necessário)
CREATE POLICY "Users can view their own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Locations are viewable by everyone" ON public.locations FOR SELECT USING (true);
CREATE POLICY "Only admins can insert locations" ON public.locations FOR INSERT WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE level >= 10));

CREATE POLICY "Check-ins are viewable based on privacy" ON public.check_ins FOR SELECT USING (
  privacy = 'public' OR 
  (privacy = 'friends' AND EXISTS (
    SELECT 1 FROM public.friendships 
    WHERE (user_id = auth.uid() AND friend_id = check_ins.user_id AND status = 'accepted')
       OR (friend_id = auth.uid() AND user_id = check_ins.user_id AND status = 'accepted')
  )) OR 
  check_ins.user_id = auth.uid()
);
CREATE POLICY "Users can insert their own check-ins" ON public.check_ins FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Função para criar usuário automaticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, avatar_url)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'avatar_url');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar usuário automaticamente
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 5. Execute o projeto

```bash
npm run dev
```

Acesse [http://localhost:3000](http://localhost:3000)

## 🏗️ Estrutura do Projeto

```
src/
├── app/                    # App Router do Next.js
│   ├── (auth)/            # Rotas de autenticação
│   ├── (dashboard)/       # Rotas protegidas
│   ├── map/               # Página do mapa
│   ├── locations/         # Páginas de locais
│   ├── profile/           # Perfil do usuário
│   ├── feed/              # Feed de amigos
│   └── admin/             # Painel administrativo
├── components/            # Componentes reutilizáveis
│   ├── ui/               # Componentes base (shadcn/ui)
│   ├── map/              # Componentes do mapa
│   └── auth/             # Componentes de autenticação
├── lib/                  # Configurações e utilitários
├── hooks/                # Custom hooks
├── types/                # Tipos TypeScript
└── utils/                # Funções utilitárias
```

## 🎮 Sistema de Gamificação

### Pontos por Ação
- **Check-in**: +10 pontos
- **Foto**: +20 pontos  
- **Vídeo**: +30 pontos
- **Avaliação**: +15 pontos
- **Bônus de nível**: +50 pontos

### Benefícios por Nível
- **Nível 2**: 30% desconto em gins, 1 cerveja grátis/mês
- **Nível 5**: 50% desconto em entrada, 2 bebidas grátis/mês
- **Nível 10**: Entrada grátis, combo especial mensal
- **Nível 20**: Status VIP, descontos exclusivos
- **Nível 50**: Combo premium mensal, acesso VIP total

## 🔧 Configurações Adicionais

### Google Maps API (Opcional)

Para usar o Google Maps ao invés do OpenStreetMap:

1. Obtenha uma chave da API do Google Maps
2. Adicione no `.env.local`:
```env
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=sua_chave_aqui
```

### Supabase Edge Functions

Para funcionalidades avançadas, crie Edge Functions no Supabase:

```bash
supabase functions new reset-monthly-points
supabase functions new send-notifications
```

## 🚀 Deploy

### Vercel (Recomendado)

1. Conecte seu repositório ao Vercel
2. Configure as variáveis de ambiente
3. Deploy automático

### Outras plataformas

O projeto é compatível com qualquer plataforma que suporte Next.js.

## 📱 Funcionalidades Futuras

- [ ] PWA (Progressive Web App)
- [ ] Notificações push
- [ ] Integração com redes sociais
- [ ] Sistema de eventos em tempo real
- [ ] Analytics avançado
- [ ] Múltiplas cidades
- [ ] Sistema de badges
- [ ] Marketplace de benefícios

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

Para suporte, envie um email para [seu-email@exemplo.com](mailto:seu-email@exemplo.com) ou abra uma issue no GitHub. 