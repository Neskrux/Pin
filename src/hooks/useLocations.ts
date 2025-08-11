'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { Location, MapFilters } from '@/types'

export function useLocations(filters: MapFilters) {
  const [locations, setLocations] = useState<Location[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchLocations()
  }, [filters])

  const fetchLocations = async () => {
    try {
      setLoading(true)
      setError(null)
      
      let query = supabase
        .from('locations')
        .select('*')
        .order('created_at', { ascending: false })

      // Aplicar filtros
      if (filters.categories.length > 0) {
        query = query.in('category', filters.categories)
      }

      if (filters.searchQuery) {
        query = query.ilike('name', `%${filters.searchQuery}%`)
      }

      const { data, error } = await query

      if (error) {
        setError('Erro ao buscar locais')
        console.error('Erro ao buscar locais:', error)
        return
      }

      setLocations(data || [])
    } catch (error) {
      setError('Erro ao buscar locais')
      console.error('Erro ao buscar locais:', error)
    } finally {
      setLoading(false)
    }
  }

  const getLocationById = async (id: string): Promise<Location | null> => {
    try {
      const { data, error } = await supabase
        .from('locations')
        .select('*')
        .eq('id', id)
        .single()

      if (error) {
        console.error('Erro ao buscar local:', error)
        return null
      }

      return data
    } catch (error) {
      console.error('Erro ao buscar local:', error)
      return null
    }
  }

  const createLocation = async (locationData: Omit<Location, 'id' | 'created_at' | 'updated_at'>) => {
    try {
      const { data, error } = await supabase
        .from('locations')
        .insert(locationData)
        .select()
        .single()

      if (error) {
        console.error('Erro ao criar local:', error)
        return null
      }

      setLocations(prev => [data, ...prev])
      return data
    } catch (error) {
      console.error('Erro ao criar local:', error)
      return null
    }
  }

  const updateLocation = async (id: string, updates: Partial<Location>) => {
    try {
      const { data, error } = await supabase
        .from('locations')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (error) {
        console.error('Erro ao atualizar local:', error)
        return null
      }

      setLocations(prev => 
        prev.map(location => 
          location.id === id ? data : location
        )
      )

      return data
    } catch (error) {
      console.error('Erro ao atualizar local:', error)
      return null
    }
  }

  const highlightLocation = async (id: string, duration: number = 20) => {
    const expiresAt = new Date(Date.now() + duration * 60 * 1000).toISOString()
    
    return updateLocation(id, {
      is_highlighted: true,
      highlight_expires_at: expiresAt
    })
  }

  return {
    locations,
    loading,
    error,
    fetchLocations,
    getLocationById,
    createLocation,
    updateLocation,
    highlightLocation
  }
} 