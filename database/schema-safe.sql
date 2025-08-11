-- Schema seguro para o aplicativo PIN
-- Execute este arquivo no Supabase SQL Editor
-- Este script verifica se as tabelas existem antes de criá-las

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Tabela de usuários (estende auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar_url TEXT,
  phone TEXT,
  points INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de locais
CREATE TABLE IF NOT EXISTS public.locations (
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
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de check-ins
CREATE TABLE IF NOT EXISTS public.check_ins (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE NOT NULL,
  privacy TEXT NOT NULL CHECK (privacy IN ('public', 'friends', 'private')) DEFAULT 'public',
  points_earned INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de PINs (posts com localização)
CREATE TABLE IF NOT EXISTS public.pins (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE NOT NULL,
  privacy TEXT NOT NULL CHECK (privacy IN ('public', 'friends', 'private')) DEFAULT 'public',
  content TEXT,
  media_urls TEXT[],
  media_type TEXT CHECK (media_type IN ('image', 'video')),
  points_earned INTEGER DEFAULT 20,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de avaliações
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  points_earned INTEGER DEFAULT 15,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, location_id)
);

-- Tabela de amizades
CREATE TABLE IF NOT EXISTS public.friendships (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  friend_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected')) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, friend_id),
  CHECK(user_id != friend_id)
);

-- Tabela de notificações
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('check_in', 'friend_request', 'points_earned', 'level_up', 'benefit_unlocked', 'location_highlight')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de assinaturas de parceiros
CREATE TABLE IF NOT EXISTS public.partner_subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  location_id UUID REFERENCES public.locations(id) ON DELETE CASCADE NOT NULL,
  plan TEXT NOT NULL CHECK (plan IN ('basic', 'premium')),
  status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'expired')) DEFAULT 'active',
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(location_id)
);

-- Índices para performance (só cria se não existirem)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_locations_category') THEN
    CREATE INDEX idx_locations_category ON public.locations(category);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_locations_coordinates') THEN
    CREATE INDEX idx_locations_coordinates ON public.locations(latitude, longitude);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_locations_highlighted') THEN
    CREATE INDEX idx_locations_highlighted ON public.locations(is_highlighted) WHERE is_highlighted = true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_check_ins_user_id') THEN
    CREATE INDEX idx_check_ins_user_id ON public.check_ins(user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_check_ins_location_id') THEN
    CREATE INDEX idx_check_ins_location_id ON public.check_ins(location_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_check_ins_created_at') THEN
    CREATE INDEX idx_check_ins_created_at ON public.check_ins(created_at);
  END IF;
  
  -- Removido o índice único problemático - será implementado via constraint na aplicação
  -- IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_check_ins_unique_daily') THEN
  --   CREATE UNIQUE INDEX idx_check_ins_unique_daily ON public.check_ins(user_id, location_id, DATE(created_at));
  -- END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_pins_user_id') THEN
    CREATE INDEX idx_pins_user_id ON public.pins(user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_pins_location_id') THEN
    CREATE INDEX idx_pins_location_id ON public.pins(location_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_pins_created_at') THEN
    CREATE INDEX idx_pins_created_at ON public.pins(created_at);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_reviews_location_id') THEN
    CREATE INDEX idx_reviews_location_id ON public.reviews(location_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_friendships_user_id') THEN
    CREATE INDEX idx_friendships_user_id ON public.friendships(user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_friendships_friend_id') THEN
    CREATE INDEX idx_friendships_friend_id ON public.friendships(friend_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_user_id') THEN
    CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_is_read') THEN
    CREATE INDEX idx_notifications_is_read ON public.notifications(is_read) WHERE is_read = false;
  END IF;
END $$;

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at (só cria se não existirem)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
    CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_locations_updated_at') THEN
    CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_check_ins_updated_at') THEN
    CREATE TRIGGER update_check_ins_updated_at BEFORE UPDATE ON public.check_ins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_pins_updated_at') THEN
    CREATE TRIGGER update_pins_updated_at BEFORE UPDATE ON public.pins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_reviews_updated_at') THEN
    CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_friendships_updated_at') THEN
    CREATE TRIGGER update_friendships_updated_at BEFORE UPDATE ON public.friendships FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- Função para criar usuário automaticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar usuário automaticamente (só cria se não existir)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created') THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
  END IF;
END $$;

-- Políticas RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_subscriptions ENABLE ROW LEVEL SECURITY;

-- Políticas para usuários (só cria se não existirem)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Usuários podem ver seus próprios dados') THEN
    CREATE POLICY "Usuários podem ver seus próprios dados" ON public.users FOR SELECT USING (auth.uid() = id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Usuários podem atualizar seus próprios dados') THEN
    CREATE POLICY "Usuários podem atualizar seus próprios dados" ON public.users FOR UPDATE USING (auth.uid() = id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Usuários podem ver perfis públicos') THEN
    CREATE POLICY "Usuários podem ver perfis públicos" ON public.users FOR SELECT USING (true);
  END IF;
END $$;

-- Políticas para locais
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'locations' AND policyname = 'Locais são visíveis para todos') THEN
    CREATE POLICY "Locais são visíveis para todos" ON public.locations FOR SELECT USING (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'locations' AND policyname = 'Apenas admins podem criar locais') THEN
    CREATE POLICY "Apenas admins podem criar locais" ON public.locations FOR INSERT WITH CHECK (false);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'locations' AND policyname = 'Apenas admins podem atualizar locais') THEN
    CREATE POLICY "Apenas admins podem atualizar locais" ON public.locations FOR UPDATE USING (false);
  END IF;
END $$;

-- Políticas para check-ins
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'check_ins' AND policyname = 'Usuários podem ver check-ins públicos') THEN
    CREATE POLICY "Usuários podem ver check-ins públicos" ON public.check_ins FOR SELECT USING (
      privacy = 'public' OR 
      user_id = auth.uid() OR
      (privacy = 'friends' AND EXISTS (
        SELECT 1 FROM public.friendships 
        WHERE (user_id = auth.uid() AND friend_id = check_ins.user_id AND status = 'accepted')
        OR (friend_id = auth.uid() AND user_id = check_ins.user_id AND status = 'accepted')
      ))
    );
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'check_ins' AND policyname = 'Usuários podem criar seus próprios check-ins') THEN
    CREATE POLICY "Usuários podem criar seus próprios check-ins" ON public.check_ins FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'check_ins' AND policyname = 'Usuários podem atualizar seus próprios check-ins') THEN
    CREATE POLICY "Usuários podem atualizar seus próprios check-ins" ON public.check_ins FOR UPDATE USING (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'check_ins' AND policyname = 'Usuários podem deletar seus próprios check-ins') THEN
    CREATE POLICY "Usuários podem deletar seus próprios check-ins" ON public.check_ins FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Políticas para PINs
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'pins' AND policyname = 'Usuários podem ver PINs públicos') THEN
    CREATE POLICY "Usuários podem ver PINs públicos" ON public.pins FOR SELECT USING (
      privacy = 'public' OR 
      user_id = auth.uid() OR
      (privacy = 'friends' AND EXISTS (
        SELECT 1 FROM public.friendships 
        WHERE (user_id = auth.uid() AND friend_id = pins.user_id AND status = 'accepted')
        OR (friend_id = auth.uid() AND user_id = pins.user_id AND status = 'accepted')
      ))
    );
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'pins' AND policyname = 'Usuários podem criar seus próprios PINs') THEN
    CREATE POLICY "Usuários podem criar seus próprios PINs" ON public.pins FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'pins' AND policyname = 'Usuários podem atualizar seus próprios PINs') THEN
    CREATE POLICY "Usuários podem atualizar seus próprios PINs" ON public.pins FOR UPDATE USING (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'pins' AND policyname = 'Usuários podem deletar seus próprios PINs') THEN
    CREATE POLICY "Usuários podem deletar seus próprios PINs" ON public.pins FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Políticas para avaliações
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'reviews' AND policyname = 'Avaliações são visíveis para todos') THEN
    CREATE POLICY "Avaliações são visíveis para todos" ON public.reviews FOR SELECT USING (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'reviews' AND policyname = 'Usuários podem criar suas próprias avaliações') THEN
    CREATE POLICY "Usuários podem criar suas próprias avaliações" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'reviews' AND policyname = 'Usuários podem atualizar suas próprias avaliações') THEN
    CREATE POLICY "Usuários podem atualizar suas próprias avaliações" ON public.reviews FOR UPDATE USING (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'reviews' AND policyname = 'Usuários podem deletar suas próprias avaliações') THEN
    CREATE POLICY "Usuários podem deletar suas próprias avaliações" ON public.reviews FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Políticas para amizades
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'friendships' AND policyname = 'Usuários podem ver suas amizades') THEN
    CREATE POLICY "Usuários podem ver suas amizades" ON public.friendships FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'friendships' AND policyname = 'Usuários podem criar solicitações de amizade') THEN
    CREATE POLICY "Usuários podem criar solicitações de amizade" ON public.friendships FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'friendships' AND policyname = 'Usuários podem atualizar suas amizades') THEN
    CREATE POLICY "Usuários podem atualizar suas amizades" ON public.friendships FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = friend_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'friendships' AND policyname = 'Usuários podem deletar suas amizades') THEN
    CREATE POLICY "Usuários podem deletar suas amizades" ON public.friendships FOR DELETE USING (auth.uid() = user_id OR auth.uid() = friend_id);
  END IF;
END $$;

-- Políticas para notificações
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Usuários podem ver suas próprias notificações') THEN
    CREATE POLICY "Usuários podem ver suas próprias notificações" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Sistema pode criar notificações') THEN
    CREATE POLICY "Sistema pode criar notificações" ON public.notifications FOR INSERT WITH CHECK (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Usuários podem atualizar suas próprias notificações') THEN
    CREATE POLICY "Usuários podem atualizar suas próprias notificações" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Usuários podem deletar suas próprias notificações') THEN
    CREATE POLICY "Usuários podem deletar suas próprias notificações" ON public.notifications FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Políticas para assinaturas de parceiros
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'partner_subscriptions' AND policyname = 'Assinaturas são visíveis para todos') THEN
    CREATE POLICY "Assinaturas são visíveis para todos" ON public.partner_subscriptions FOR SELECT USING (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'partner_subscriptions' AND policyname = 'Apenas admins podem gerenciar assinaturas') THEN
    CREATE POLICY "Apenas admins podem gerenciar assinaturas" ON public.partner_subscriptions FOR ALL USING (false);
  END IF;
END $$;

-- Função para buscar amigos de um usuário
CREATE OR REPLACE FUNCTION get_user_friends(user_uuid UUID)
RETURNS TABLE (
  friend_id UUID,
  friend_name TEXT,
  friend_avatar_url TEXT,
  friend_level INTEGER,
  friendship_created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.name,
    u.avatar_url,
    u.level,
    f.created_at
  FROM public.friendships f
  JOIN public.users u ON (
    CASE 
      WHEN f.user_id = user_uuid THEN u.id = f.friend_id
      ELSE u.id = f.user_id
    END
  )
  WHERE (f.user_id = user_uuid OR f.friend_id = user_uuid)
    AND f.status = 'accepted'
  ORDER BY f.created_at DESC;
END;
$$;

-- Função para calcular estatísticas de um local
CREATE OR REPLACE FUNCTION get_location_stats(location_uuid UUID)
RETURNS TABLE (
  total_checkins BIGINT,
  checkins_today BIGINT,
  current_people BIGINT,
  average_rating DECIMAL,
  total_reviews BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*) FROM public.check_ins WHERE location_id = location_uuid) as total_checkins,
    (SELECT COUNT(*) FROM public.check_ins WHERE location_id = location_uuid AND DATE(created_at) = CURRENT_DATE) as checkins_today,
    (SELECT COUNT(*) FROM public.check_ins WHERE location_id = location_uuid AND created_at > NOW() - INTERVAL '4 hours') as current_people,
    (SELECT COALESCE(AVG(rating), 0) FROM public.reviews WHERE location_id = location_uuid) as average_rating,
    (SELECT COUNT(*) FROM public.reviews WHERE location_id = location_uuid) as total_reviews;
END;
$$;

-- Função para buscar timeline de um usuário
CREATE OR REPLACE FUNCTION get_user_timeline(user_uuid UUID, limit_count INTEGER DEFAULT 20)
RETURNS TABLE (
  id UUID,
  type TEXT,
  user_id UUID,
  user_name TEXT,
  user_avatar_url TEXT,
  location_id UUID,
  location_name TEXT,
  content TEXT,
  media_urls TEXT[],
  rating INTEGER,
  created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  (
    SELECT 
      c.id,
      'checkin'::TEXT as type,
      c.user_id,
      u.name as user_name,
      u.avatar_url as user_avatar_url,
      c.location_id,
      l.name as location_name,
      NULL::TEXT as content,
      NULL::TEXT[] as media_urls,
      NULL::INTEGER as rating,
      c.created_at
    FROM public.check_ins c
    JOIN public.users u ON u.id = c.user_id
    JOIN public.locations l ON l.id = c.location_id
    WHERE c.user_id = user_uuid AND c.privacy = 'public'
  )
  UNION ALL
  (
    SELECT 
      p.id,
      'pin'::TEXT as type,
      p.user_id,
      u.name as user_name,
      u.avatar_url as user_avatar_url,
      p.location_id,
      l.name as location_name,
      p.content,
      p.media_urls,
      NULL::INTEGER as rating,
      p.created_at
    FROM public.pins p
    JOIN public.users u ON u.id = p.user_id
    JOIN public.locations l ON l.id = p.location_id
    WHERE p.user_id = user_uuid AND p.privacy = 'public'
  )
  UNION ALL
  (
    SELECT 
      r.id,
      'review'::TEXT as type,
      r.user_id,
      u.name as user_name,
      u.avatar_url as user_avatar_url,
      r.location_id,
      l.name as location_name,
      r.comment as content,
      NULL::TEXT[] as media_urls,
      r.rating,
      r.created_at
    FROM public.reviews r
    JOIN public.users u ON u.id = r.user_id
    JOIN public.locations l ON l.id = r.location_id
    WHERE r.user_id = user_uuid
  )
  ORDER BY created_at DESC
  LIMIT limit_count;
END;
$$; 