'use client'

import { useState } from 'react'
import { Search, Filter, Users, MapPin } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { MapFilters as MapFiltersType, LocationCategory } from '@/types'
import { LOCATION_CATEGORIES, PEOPLE_COUNT_RANGES } from '@/utils/constants'
import { cn } from '@/utils/cn'

interface MapFiltersProps {
  filters: MapFiltersType
  onFiltersChange: (filters: MapFiltersType) => void
}

export default function MapFilters({ filters, onFiltersChange }: MapFiltersProps) {
  const [isExpanded, setIsExpanded] = useState(false)

  const handleCategoryToggle = (category: LocationCategory) => {
    const newCategories = filters.categories.includes(category)
      ? filters.categories.filter(c => c !== category)
      : [...filters.categories, category]
    
    onFiltersChange({
      ...filters,
      categories: newCategories
    })
  }

  const handlePeopleCountChange = (min: number, max: number) => {
    onFiltersChange({
      ...filters,
      peopleCount: { min, max }
    })
  }

  const handleSearchChange = (query: string) => {
    onFiltersChange({
      ...filters,
      searchQuery: query
    })
  }

  const handleFriendsToggle = () => {
    onFiltersChange({
      ...filters,
      showOnlyFriends: !filters.showOnlyFriends
    })
  }

  const clearFilters = () => {
    onFiltersChange({
      categories: [],
      peopleCount: { min: 0, max: 999 },
      searchQuery: '',
      showOnlyFriends: false
    })
  }

  const activeFiltersCount = 
    filters.categories.length + 
    (filters.searchQuery ? 1 : 0) + 
    (filters.showOnlyFriends ? 1 : 0) +
    ((filters.peopleCount.min > 0 || filters.peopleCount.max < 999) ? 1 : 0)

  return (
    <div className="absolute top-4 left-4 right-4 z-10 bg-white rounded-lg shadow-lg border">
      {/* Barra de pesquisa principal */}
      <div className="p-4 border-b">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <Input
            placeholder="Buscar locais..."
            value={filters.searchQuery}
            onChange={(e) => handleSearchChange(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      {/* Botão de filtros */}
      <div className="p-4">
        <div className="flex items-center justify-between">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setIsExpanded(!isExpanded)}
            className="flex items-center gap-2"
          >
            <Filter className="h-4 w-4" />
            Filtros
            {activeFiltersCount > 0 && (
              <span className="bg-primary text-primary-foreground text-xs rounded-full px-2 py-1">
                {activeFiltersCount}
              </span>
            )}
          </Button>

          {activeFiltersCount > 0 && (
            <Button
              variant="ghost"
              size="sm"
              onClick={clearFilters}
              className="text-gray-500 hover:text-gray-700"
            >
              Limpar
            </Button>
          )}
        </div>

        {/* Filtros expandidos */}
        {isExpanded && (
          <div className="mt-4 space-y-4">
            {/* Categorias */}
            <div>
              <h3 className="text-sm font-medium mb-2 flex items-center gap-2">
                <MapPin className="h-4 w-4" />
                Categorias
              </h3>
              <div className="grid grid-cols-2 gap-2">
                {LOCATION_CATEGORIES.map((category) => (
                  <Button
                    key={category.value}
                    variant={filters.categories.includes(category.value as LocationCategory) ? "default" : "outline"}
                    size="sm"
                    onClick={() => handleCategoryToggle(category.value as LocationCategory)}
                    className="justify-start text-xs"
                  >
                    <span className="mr-2">{category.icon}</span>
                    {category.label}
                  </Button>
                ))}
              </div>
            </div>

            {/* Quantidade de pessoas */}
            <div>
              <h3 className="text-sm font-medium mb-2 flex items-center gap-2">
                <Users className="h-4 w-4" />
                Quantidade de pessoas
              </h3>
              <div className="space-y-2">
                {PEOPLE_COUNT_RANGES.map((range) => (
                  <Button
                    key={range.label}
                    variant={
                      filters.peopleCount.min === range.min && filters.peopleCount.max === range.max
                        ? "default"
                        : "outline"
                    }
                    size="sm"
                    onClick={() => handlePeopleCountChange(range.min, range.max)}
                    className="w-full justify-start text-xs"
                  >
                    {range.label}
                  </Button>
                ))}
              </div>
            </div>

            {/* Filtro de amigos */}
            <div>
              <Button
                variant={filters.showOnlyFriends ? "default" : "outline"}
                size="sm"
                onClick={handleFriendsToggle}
                className="w-full justify-start text-xs"
              >
                👥 Mostrar apenas amigos
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
} 