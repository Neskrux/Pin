export const POINTS_SYSTEM = {
  CHECK_IN: 10,
  PHOTO_POST: 20,
  VIDEO_POST: 30,
  REVIEW: 15,
  LEVEL_UP_BONUS: 50
} as const

export const LEVELS = {
  1: 0,
  2: 50,
  3: 120,
  4: 200,
  5: 300,
  6: 420,
  7: 560,
  8: 720,
  9: 900,
  10: 1100
} as const

export const BENEFITS = {
  2: ['30% desconto em gins', '1 cerveja grátis por mês'],
  5: ['50% desconto em entrada', '2 bebidas grátis por mês'],
  10: ['Entrada grátis', 'Combo especial mensal'],
  20: ['VIP status', 'Descontos exclusivos'],
  50: ['Combo premium mensal', 'Acesso VIP total']
} as const

export const LOCATION_CATEGORIES = [
  { value: 'bar', label: 'Bar', icon: '🍺' },
  { value: 'restaurant', label: 'Restaurante', icon: '🍽️' },
  { value: 'club', label: 'Balada', icon: '🎵' },
  { value: 'event', label: 'Evento', icon: '🎪' },
  { value: 'cafe', label: 'Café', icon: '☕' },
  { value: 'shopping', label: 'Shopping', icon: '🛍️' },
  { value: 'entertainment', label: 'Entretenimento', icon: '🎮' },
  { value: 'other', label: 'Outro', icon: '📍' }
] as const

export const PEOPLE_COUNT_RANGES = [
  { label: 'Vazio (0-10)', min: 0, max: 10 },
  { label: 'Pouco movimento (10-50)', min: 10, max: 50 },
  { label: 'Movimento médio (50-100)', min: 50, max: 100 },
  { label: 'Cheio (100-200)', min: 100, max: 200 },
  { label: 'Lotado (200+)', min: 200, max: 999 }
] as const

export const PRIVACY_LEVELS = [
  { value: 'public', label: 'Público', icon: '🌍' },
  { value: 'friends', label: 'Amigos', icon: '👥' },
  { value: 'private', label: 'Privado', icon: '🔒' }
] as const

export const PARTNER_PLANS = {
  basic: {
    name: 'Básico',
    price: 50,
    features: ['Destaque por 20 minutos', 'Estatísticas básicas', 'Suporte por email']
  },
  premium: {
    name: 'Premium',
    price: 150,
    features: ['Destaque por 1 hora', 'Estatísticas avançadas', 'Suporte prioritário', 'Análise de público']
  }
} as const

export const MAP_CONFIG = {
  defaultZoom: 13,
  defaultCenter: { lat: -23.5505, lng: -46.6333 }, // São Paulo
  maxZoom: 18,
  minZoom: 10
} as const

export const NOTIFICATION_TYPES = {
  check_in: { icon: '📍', color: 'blue' },
  friend_request: { icon: '👥', color: 'green' },
  points_earned: { icon: '⭐', color: 'yellow' },
  level_up: { icon: '🎉', color: 'purple' },
  benefit_unlocked: { icon: '🎁', color: 'pink' },
  location_highlight: { icon: '🔥', color: 'red' }
} as const 