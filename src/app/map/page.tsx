'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import dynamic from 'next/dynamic'
import LiveMap from '@/components/map/LiveMap'
import MapFilters from '@/components/map/MapFilters'
import { MapFilters as MapFiltersType, Location } from '@/types'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { MapPin, Users, Star, Clock } from 'lucide-react'

// Importação dinâmica do mapa para evitar problemas de SSR
const MapWithNoSSR = dynamic(() => import('@/components/map/LiveMap'), {
  ssr: false,
  loading: () => (
    <div className="flex items-center justify-center h-full">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>
  )
})

export default function MapPage() {
  const router = useRouter()
  const [filters, setFilters] = useState<MapFiltersType>({
    categories: [],
    peopleCount: { min: 0, max: 999 },
    searchQuery: '',
    showOnlyFriends: false
  })
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null)
  const [selectedLocation, setSelectedLocation] = useState<Location | null>(null)

  useEffect(() => {
    // Obter localização do usuário
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setUserLocation({
            lat: position.coords.latitude,
            lng: position.coords.longitude
          })
        },
        (error) => {
          console.error('Erro ao obter localização:', error)
          // Usar localização padrão (São Paulo)
          setUserLocation({ lat: -23.5505, lng: -46.6333 })
        }
      )
    }
  }, [])

  const handleLocationClick = (location: Location) => {
    setSelectedLocation(location)
  }

  const handleCheckIn = () => {
    if (selectedLocation) {
      router.push(`/locations/${selectedLocation.id}`)
    }
  }

  const formatTime = (dateString: string) => {
    return new Date(dateString).toLocaleTimeString('pt-BR', {
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="h-screen flex flex-col">
      {/* Header */}
      <div className="bg-white border-b px-4 py-3 flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold">PIN - Mapa ao Vivo</h1>
          <p className="text-sm text-gray-600">Descubra onde está todo mundo</p>
        </div>
        
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm">
            <Users className="h-4 w-4 mr-2" />
            Amigos
          </Button>
          <Button variant="outline" size="sm">
            <Star className="h-4 w-4 mr-2" />
            Favoritos
          </Button>
        </div>
      </div>

      {/* Mapa */}
      <div className="flex-1 relative">
        <MapWithNoSSR
          filters={filters}
          onLocationClick={handleLocationClick}
          userLocation={userLocation || undefined}
        />
        
        <MapFilters
          filters={filters}
          onFiltersChange={setFilters}
        />
      </div>

      {/* Painel de local selecionado */}
      {selectedLocation && (
        <div className="absolute bottom-4 left-4 right-4 z-20">
          <Card>
            <CardContent className="p-4">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <MapPin className="h-4 w-4 text-primary" />
                    <h3 className="font-semibold text-lg">{selectedLocation.name}</h3>
                  </div>
                  
                  <p className="text-sm text-gray-600 mb-2">
                    {selectedLocation.address}
                  </p>
                  
                  <div className="flex items-center gap-4 text-sm text-gray-500">
                    {selectedLocation.average_price && (
                      <span>💰 R$ {selectedLocation.average_price}</span>
                    )}
                    {selectedLocation.opening_hours && (
                      <span className="flex items-center gap-1">
                        <Clock className="h-3 w-3" />
                        {selectedLocation.opening_hours}
                      </span>
                    )}
                  </div>
                </div>
                
                <div className="flex flex-col items-end gap-2">
                  <Button onClick={handleCheckIn} size="sm">
                    Fazer Check-in
                  </Button>
                  <Button 
                    variant="outline" 
                    size="sm"
                    onClick={() => router.push(`/locations/${selectedLocation.id}`)}
                  >
                    Ver detalhes
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  )
} 