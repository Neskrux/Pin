'use client'

import { useEffect, useState, useRef } from 'react'
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet'
import { Icon } from 'leaflet'
import { supabase } from '@/lib/supabase'
import { Location, MapFilters } from '@/types'
import { LOCATION_CATEGORIES } from '@/utils/constants'
import { cn } from '@/utils/cn'

// Fix para ícones do Leaflet no Next.js
const customIcon = new Icon({
  iconUrl: '/marker-icon.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowUrl: '/marker-shadow.png',
  shadowSize: [41, 41]
})

const highlightedIcon = new Icon({
  iconUrl: '/marker-icon-red.png',
  iconSize: [35, 51],
  iconAnchor: [17, 51],
  popupAnchor: [1, -34],
  shadowUrl: '/marker-shadow.png',
  shadowSize: [51, 51]
})

interface LiveMapProps {
  filters: MapFilters
  onLocationClick: (location: Location) => void
  userLocation?: { lat: number; lng: number }
}

function MapUpdater({ userLocation }: { userLocation?: { lat: number; lng: number } }) {
  const map = useMap()
  
  useEffect(() => {
    if (userLocation) {
      map.setView([userLocation.lat, userLocation.lng], 15)
    }
  }, [userLocation, map])
  
  return null
}

export default function LiveMap({ filters, onLocationClick, userLocation }: LiveMapProps) {
  const [locations, setLocations] = useState<Location[]>([])
  const [loading, setLoading] = useState(true)
  const mapRef = useRef<any>(null)

  useEffect(() => {
    fetchLocations()
    
    // Inscrever para atualizações em tempo real
    const channel = supabase
      .channel('locations')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'locations' },
        () => {
          fetchLocations()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [filters])

  const fetchLocations = async () => {
    try {
      setLoading(true)
      
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
        console.error('Erro ao buscar locais:', error)
        return
      }

      setLocations(data || [])
    } catch (error) {
      console.error('Erro ao buscar locais:', error)
    } finally {
      setLoading(false)
    }
  }

  const getLocationIcon = (location: Location) => {
    return location.is_highlighted ? highlightedIcon : customIcon
  }

  const getPeopleCount = (location: Location) => {
    // Simular contagem de pessoas baseada em check-ins ativos
    // Na implementação real, isso viria de uma query agregada
    return Math.floor(Math.random() * 200) + 10
  }

  const getCategoryIcon = (category: string) => {
    const cat = LOCATION_CATEGORIES.find(c => c.value === category)
    return cat?.icon || '📍'
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    )
  }

  return (
    <div className="relative h-full w-full">
      <MapContainer
        ref={mapRef}
        center={userLocation || [-23.5505, -46.6333]}
        zoom={13}
        className="h-full w-full"
        style={{ height: '100%', width: '100%' }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        
        {userLocation && <MapUpdater userLocation={userLocation} />}
        
        {locations.map((location) => {
          const peopleCount = getLocationCount(location.id)
          
          return (
            <Marker
              key={location.id}
              position={[location.latitude, location.longitude]}
              icon={getLocationIcon(location)}
              eventHandlers={{
                click: () => onLocationClick(location),
              }}
            >
              <Popup>
                <div className="p-2">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="text-lg">{getCategoryIcon(location.category)}</span>
                    <h3 className="font-semibold text-sm">{location.name}</h3>
                  </div>
                  
                  {location.is_highlighted && (
                    <div className="bg-red-100 text-red-800 text-xs px-2 py-1 rounded mb-2">
                      🔥 Destaque
                    </div>
                  )}
                  
                  <div className="text-xs text-gray-600 mb-2">
                    {location.address}
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-medium">
                      👥 {peopleCount} pessoas
                    </span>
                    {location.average_price && (
                      <span className="text-xs text-green-600">
                        💰 R$ {location.average_price}
                      </span>
                    )}
                  </div>
                  
                  <button
                    onClick={() => onLocationClick(location)}
                    className="w-full mt-2 bg-primary text-primary-foreground text-xs py-1 px-2 rounded hover:bg-primary/90"
                  >
                    Ver detalhes
                  </button>
                </div>
              </Popup>
            </Marker>
          )
        })}
      </MapContainer>
    </div>
  )
}

// Função para obter contagem de pessoas em um local
async function getLocationCount(locationId: string): Promise<number> {
  try {
    const { count, error } = await supabase
      .from('check_ins')
      .select('*', { count: 'exact', head: true })
      .eq('location_id', locationId)
      .gte('created_at', new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()) // Últimas 2 horas

    if (error) {
      console.error('Erro ao contar check-ins:', error)
      return 0
    }

    return count || 0
  } catch (error) {
    console.error('Erro ao contar check-ins:', error)
    return 0
  }
} 