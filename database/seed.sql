-- Dados de exemplo para o aplicativo PIN
-- Execute este arquivo no SQL Editor do Supabase após executar schema.sql

-- Inserir locais de exemplo
INSERT INTO public.locations (id, name, description, address, latitude, longitude, category, average_price, opening_hours, phone, website, is_partner, is_highlighted) VALUES
-- Bares
('550e8400-e29b-41d4-a716-446655440001', 'Bar do Zé', 'Bar tradicional com petiscos e cerveja gelada', 'Rua das Flores, 123 - Centro', -23.5505, -46.6333, 'bar', 25.00, '18:00-02:00', '(11) 99999-0001', 'https://bardoze.com', true, true),
('550e8400-e29b-41d4-a716-446655440002', 'Pub Irlandês', 'Pub com música ao vivo e cervejas importadas', 'Av. Paulista, 1000 - Bela Vista', -23.5630, -46.6544, 'bar', 45.00, '19:00-01:00', '(11) 99999-0002', 'https://pubirlandes.com', true, false),
('550e8400-e29b-41d4-a716-446655440003', 'Cantina Italiana', 'Cantina familiar com massas e vinhos', 'Rua Augusta, 500 - Consolação', -23.5489, -46.6388, 'restaurant', 35.00, '12:00-23:00', '(11) 99999-0003', 'https://cantinaitaliana.com', false, false),

-- Restaurantes
('550e8400-e29b-41d4-a716-446655440004', 'Sushi Bar', 'Restaurante japonês com sushi fresco', 'Rua Oscar Freire, 200 - Jardins', -23.5670, -46.6680, 'restaurant', 80.00, '12:00-23:00', '(11) 99999-0004', 'https://sushibar.com', true, true),
('550e8400-e29b-41d4-a716-446655440005', 'Churrascaria', 'Churrascaria rodízio com carnes nobres', 'Av. Brigadeiro Faria Lima, 1500 - Pinheiros', -23.5670, -46.6880, 'restaurant', 120.00, '12:00-00:00', '(11) 99999-0005', 'https://churrascaria.com', true, false),
('550e8400-e29b-41d4-a716-446655440006', 'Pizzaria', 'Pizzaria artesanal com forno a lenha', 'Rua dos Pinheiros, 800 - Pinheiros', -23.5670, -46.6980, 'restaurant', 40.00, '18:00-23:00', '(11) 99999-0006', 'https://pizzaria.com', false, false),

-- Cafés
('550e8400-e29b-41d4-a716-446655440007', 'Café Especial', 'Café de origem com métodos especiais', 'Rua Harmonia, 300 - Vila Madalena', -23.5670, -46.7080, 'cafe', 15.00, '07:00-20:00', '(11) 99999-0007', 'https://cafeespecial.com', true, false),
('550e8400-e29b-41d4-a716-446655440008', 'Padaria Artesanal', 'Padaria com pães artesanais e café', 'Rua Teodoro Sampaio, 400 - Pinheiros', -23.5670, -46.7180, 'cafe', 12.00, '06:00-22:00', '(11) 99999-0008', 'https://padariaartesanal.com', false, false),

-- Entretenimento
('550e8400-e29b-41d4-a716-446655440009', 'Cinema Multiplex', 'Cinema com 8 salas e tecnologia IMAX', 'Shopping Cidade São Paulo - Centro', -23.5505, -46.6333, 'entertainment', 30.00, '14:00-23:00', '(11) 99999-0009', 'https://cinema.com', true, false),
('550e8400-e29b-41d4-a716-446655440010', 'Casa de Shows', 'Casa de shows com música ao vivo', 'Rua 13 de Maio, 100 - Bela Vista', -23.5630, -46.6544, 'entertainment', 50.00, '20:00-02:00', '(11) 99999-0010', 'https://casadeshows.com', true, true),

-- Shopping
('550e8400-e29b-41d4-a716-446655440011', 'Shopping Center', 'Shopping com 200 lojas e praça de alimentação', 'Av. Paulista, 2000 - Bela Vista', -23.5630, -46.6544, 'shopping', 0.00, '10:00-22:00', '(11) 99999-0011', 'https://shoppingcenter.com', true, false),

-- Eventos
('550e8400-e29b-41d4-a716-446655440012', 'Festival de Música', 'Festival de música eletrônica', 'Parque Ibirapuera - Ibirapuera', -23.5870, -46.6580, 'event', 150.00, '16:00-02:00', '(11) 99999-0012', 'https://festival.com', true, true),
('550e8400-e29b-41d4-a716-446655440013', 'Feira Gastronômica', 'Feira com food trucks e cervejas artesanais', 'Parque Villa-Lobos - Alto de Pinheiros', -23.5670, -46.7280, 'event', 25.00, '12:00-20:00', '(11) 99999-0013', 'https://feiragastronomica.com', false, false),

-- Outros
('550e8400-e29b-41d4-a716-446655440014', 'Espaço Coworking', 'Espaço de coworking com café e salas de reunião', 'Rua Fradique Coutinho, 500 - Pinheiros', -23.5670, -46.6880, 'other', 0.00, '08:00-20:00', '(11) 99999-0014', 'https://coworking.com', false, false),
('550e8400-e29b-41d4-a716-446655440015', 'Academia', 'Academia 24h com equipamentos modernos', 'Rua Cardeal Arcoverde, 300 - Pinheiros', -23.5670, -46.6980, 'other', 0.00, '24h', '(11) 99999-0015', 'https://academia.com', true, false);

-- Inserir usuários de exemplo (serão criados automaticamente quando fizerem login)
-- Os usuários serão criados automaticamente pelo trigger handle_new_user()

-- Inserir check-ins de exemplo (apenas para demonstração)
-- Nota: Estes check-ins serão criados quando os usuários fizerem login e check-in

-- Inserir PINs de exemplo (apenas para demonstração)
-- Nota: Estes PINs serão criados quando os usuários fizerem login e criarem PINs

-- Inserir avaliações de exemplo (apenas para demonstração)
-- Nota: Estas avaliações serão criadas quando os usuários fizerem login e avaliarem

-- Inserir amizades de exemplo (apenas para demonstração)
-- Nota: Estas amizades serão criadas quando os usuários fizerem login e se conectarem

-- Inserir notificações de exemplo (apenas para demonstração)
-- Nota: Estas notificações serão criadas automaticamente pelo sistema

-- Inserir assinaturas de parceiros de exemplo
INSERT INTO public.partner_subscriptions (location_id, plan, status, expires_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'premium', 'active', NOW() + INTERVAL '1 year'),
('550e8400-e29b-41d4-a716-446655440002', 'basic', 'active', NOW() + INTERVAL '6 months'),
('550e8400-e29b-41d4-a716-446655440004', 'premium', 'active', NOW() + INTERVAL '1 year'),
('550e8400-e29b-41d4-a716-446655440005', 'premium', 'active', NOW() + INTERVAL '1 year'),
('550e8400-e29b-41d4-a716-446655440007', 'basic', 'active', NOW() + INTERVAL '3 months'),
('550e8400-e29b-41d4-a716-446655440009', 'premium', 'active', NOW() + INTERVAL '1 year'),
('550e8400-e29b-41d4-a716-446655440010', 'premium', 'active', NOW() + INTERVAL '1 year'),
('550e8400-e29b-41d4-a716-446655440011', 'premium', 'active', NOW() + INTERVAL '1 year'),
('550e8400-e29b-41d4-a716-446655440012', 'premium', 'active', NOW() + INTERVAL '6 months'),
('550e8400-e29b-41d4-a716-446655440015', 'basic', 'active', NOW() + INTERVAL '3 months');

-- Comentário final
-- Os dados de exemplo acima criam 15 locais diferentes com categorias variadas
-- Alguns locais são parceiros (is_partner = true) e alguns estão destacados (is_highlighted = true)
-- As assinaturas de parceiros estão configuradas com diferentes planos e prazos
-- Quando os usuários fizerem login, poderão fazer check-ins, criar PINs e interagir com estes locais 