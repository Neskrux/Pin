import { z } from 'zod'

export const userSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  email: z.string().email('Email inválido'),
  phone: z.string().optional(),
  avatar_url: z.string().url().optional()
})

export const locationSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  description: z.string().optional(),
  address: z.string().min(5, 'Endereço deve ter pelo menos 5 caracteres'),
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  category: z.enum(['bar', 'restaurant', 'club', 'event', 'cafe', 'shopping', 'entertainment', 'other']),
  average_price: z.number().min(0).optional(),
  opening_hours: z.string().optional(),
  phone: z.string().optional(),
  website: z.string().url().optional()
})

export const pinSchema = z.object({
  location_id: z.string().uuid(),
  privacy: z.enum(['public', 'friends', 'private']),
  content: z.string().max(500, 'Conteúdo deve ter no máximo 500 caracteres').optional(),
  media_urls: z.array(z.string().url()).optional()
})

export const checkInSchema = z.object({
  location_id: z.string().uuid(),
  privacy: z.enum(['public', 'friends', 'private'])
})

export const reviewSchema = z.object({
  location_id: z.string().uuid(),
  rating: z.number().min(1).max(5),
  comment: z.string().max(500, 'Comentário deve ter no máximo 500 caracteres').optional()
})

export const friendshipSchema = z.object({
  friend_id: z.string().uuid()
})

export const mapFiltersSchema = z.object({
  categories: z.array(z.enum(['bar', 'restaurant', 'club', 'event', 'cafe', 'shopping', 'entertainment', 'other'])),
  peopleCount: z.object({
    min: z.number().min(0),
    max: z.number().min(0)
  }),
  searchQuery: z.string(),
  showOnlyFriends: z.boolean()
})

export const partnerSubscriptionSchema = z.object({
  location_id: z.string().uuid(),
  plan: z.enum(['basic', 'premium'])
})

export type UserFormData = z.infer<typeof userSchema>
export type LocationFormData = z.infer<typeof locationSchema>
export type PinFormData = z.infer<typeof pinSchema>
export type CheckInFormData = z.infer<typeof checkInSchema>
export type ReviewFormData = z.infer<typeof reviewSchema>
export type FriendshipFormData = z.infer<typeof friendshipSchema>
export type MapFiltersFormData = z.infer<typeof mapFiltersSchema>
export type PartnerSubscriptionFormData = z.infer<typeof partnerSubscriptionSchema> 