-- Script para limpar o banco de dados (CUIDADO!)
-- Execute apenas se quiser começar do zero

-- Desabilitar RLS temporariamente
ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_subscriptions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pins DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.check_ins DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- Deletar dados (em ordem para respeitar foreign keys)
DELETE FROM public.notifications;
DELETE FROM public.partner_subscriptions;
DELETE FROM public.friendships;
DELETE FROM public.reviews;
DELETE FROM public.pins;
DELETE FROM public.check_ins;
DELETE FROM public.locations;
DELETE FROM public.users;

-- Dropar triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_locations_updated_at ON public.locations;
DROP TRIGGER IF EXISTS update_check_ins_updated_at ON public.check_ins;
DROP TRIGGER IF EXISTS update_pins_updated_at ON public.pins;
DROP TRIGGER IF EXISTS update_reviews_updated_at ON public.reviews;
DROP TRIGGER IF EXISTS update_friendships_updated_at ON public.friendships;

-- Dropar funções
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS get_user_friends(UUID);
DROP FUNCTION IF EXISTS get_location_stats(UUID);
DROP FUNCTION IF EXISTS get_user_timeline(UUID, INTEGER);

-- Dropar tabelas
DROP TABLE IF EXISTS public.notifications;
DROP TABLE IF EXISTS public.partner_subscriptions;
DROP TABLE IF EXISTS public.friendships;
DROP TABLE IF EXISTS public.reviews;
DROP TABLE IF EXISTS public.pins;
DROP TABLE IF EXISTS public.check_ins;
DROP TABLE IF EXISTS public.locations;
DROP TABLE IF EXISTS public.users;

-- Dropar extensões (opcional)
-- DROP EXTENSION IF EXISTS "postgis";
-- DROP EXTENSION IF EXISTS "uuid-ossp";

-- Mensagem de confirmação
SELECT 'Banco de dados limpo com sucesso!' as status; 