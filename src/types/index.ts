export interface User {
  id: string
  email: string
  name?: string
  avatar_url?: string
  phone?: string
  points: number
  level: number
  created_at: string
  updated_at: string
}

export interface Location {
  id: string
  name: string
  description?: string
  address: string
  latitude: number
  longitude: number
  category: LocationCategory
  average_price?: number
  opening_hours?: string
  phone?: string
  website?: string
  is_partner: boolean
  is_highlighted: boolean
  highlight_expires_at?: string
  created_at: string
  updated_at: string
}

export interface Pin {
  id: string
  user_id: string
  location_id: string
  privacy: PrivacyLevel
  content?: string
  media_urls?: string[]
  media_type?: 'image' | 'video'
  points_earned: number
  created_at: string
  updated_at: string
  user?: User
  location?: Location
}

export interface CheckIn {
  id: string
  user_id: string
  location_id: string
  privacy: PrivacyLevel
  points_earned: number
  created_at: string
  user?: User
  location?: Location
}

export interface Review {
  id: string
  user_id: string
  location_id: string
  rating: number
  comment?: string
  points_earned: number
  created_at: string
  user?: User
}

export interface Friendship {
  id: string
  user_id: string
  friend_id: string
  status: 'pending' | 'accepted' | 'rejected'
  created_at: string
  updated_at: string
  user?: User
  friend?: User
}

export interface Notification {
  id: string
  user_id: string
  type: NotificationType
  title: string
  message: string
  data?: Record<string, any>
  is_read: boolean
  created_at: string
}

export interface PartnerSubscription {
  id: string
  location_id: string
  plan: 'basic' | 'premium'
  status: 'active' | 'cancelled' | 'expired'
  expires_at: string
  created_at: string
  location?: Location
}

export type LocationCategory = 
  | 'bar' 
  | 'restaurant' 
  | 'club' 
  | 'event' 
  | 'cafe' 
  | 'shopping' 
  | 'entertainment' 
  | 'other'

export type PrivacyLevel = 'public' | 'friends' | 'private'

export type NotificationType = 
  | 'check_in' 
  | 'friend_request' 
  | 'points_earned' 
  | 'level_up' 
  | 'benefit_unlocked' 
  | 'location_highlight'

export interface MapFilters {
  categories: LocationCategory[]
  peopleCount: {
    min: number
    max: number
  }
  searchQuery: string
  showOnlyFriends: boolean
}

export interface LocationStats {
  total_checkins: number
  current_people: number
  average_rating: number
  total_reviews: number
  photos_count: number
  videos_count: number
}

export interface UserStats {
  total_points: number
  monthly_points: number
  total_checkins: number
  total_pins: number
  total_reviews: number
  level: number
  rank: number
} 