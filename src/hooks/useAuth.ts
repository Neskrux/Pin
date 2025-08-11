'use client'

import { useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import { User as AppUser } from '@/types'

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [appUser, setAppUser] = useState<AppUser | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Obter sessão atual
    const getSession = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      setUser(session?.user ?? null)
      
      if (session?.user) {
        await fetchAppUser(session.user.id)
      }
      
      setLoading(false)
    }

    getSession()

    // Escutar mudanças de autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        setUser(session?.user ?? null)
        
        if (session?.user) {
          await fetchAppUser(session.user.id)
        } else {
          setAppUser(null)
        }
        
        setLoading(false)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const fetchAppUser = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .single()

      if (error) {
        console.error('Erro ao buscar usuário:', error)
        return
      }

      setAppUser(data)
    } catch (error) {
      console.error('Erro ao buscar usuário:', error)
    }
  }

  const signOut = async () => {
    await supabase.auth.signOut()
  }

  const updateUser = async (updates: Partial<AppUser>) => {
    if (!user) return

    try {
      const { data, error } = await supabase
        .from('users')
        .update(updates)
        .eq('id', user.id)
        .select()
        .single()

      if (error) {
        console.error('Erro ao atualizar usuário:', error)
        return
      }

      setAppUser(data)
    } catch (error) {
      console.error('Erro ao atualizar usuário:', error)
    }
  }

  return {
    user,
    appUser,
    loading,
    signOut,
    updateUser,
    isAuthenticated: !!user
  }
} 