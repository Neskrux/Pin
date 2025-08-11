'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Auth } from '@supabase/auth-ui-react'
import { ThemeSupa } from '@supabase/auth-ui-shared'
import { supabase } from '@/lib/supabase'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { MapPin } from 'lucide-react'

export default function LoginPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)

  const handleAuthStateChange = async (event: string, session: any) => {
    if (event === 'SIGNED_IN') {
      setLoading(true)
      // Redirecionar para o mapa após login
      router.push('/map')
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-primary rounded-full mb-4">
            <MapPin className="h-8 w-8 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900">PIN</h1>
          <p className="text-gray-600 mt-2">Descubra onde está todo mundo</p>
        </div>

        {/* Card de login */}
        <Card>
          <CardHeader className="text-center">
            <CardTitle>Entrar no PIN</CardTitle>
            <CardDescription>
              Faça login para começar a explorar locais e fazer check-ins
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Auth
              supabaseClient={supabase}
              appearance={{
                theme: ThemeSupa,
                variables: {
                  default: {
                    colors: {
                      brand: '#3b82f6',
                      brandAccent: '#2563eb',
                    },
                  },
                },
              }}
              providers={['google']}
              redirectTo={`${window.location.origin}/map`}
              onAuthStateChange={handleAuthStateChange}
              localization={{
                variables: {
                  sign_in: {
                    email_label: 'Email',
                    password_label: 'Senha',
                    button_label: 'Entrar',
                    loading_button_label: 'Entrando...',
                    social_provider_text: 'Entrar com {{provider}}',
                    link_text: 'Já tem uma conta? Entre aqui',
                  },
                  sign_up: {
                    email_label: 'Email',
                    password_label: 'Senha',
                    button_label: 'Criar conta',
                    loading_button_label: 'Criando conta...',
                    social_provider_text: 'Criar conta com {{provider}}',
                    link_text: 'Não tem uma conta? Cadastre-se',
                  },
                },
              }}
            />
          </CardContent>
        </Card>

        {/* Informações adicionais */}
        <div className="text-center mt-6 text-sm text-gray-600">
          <p>✨ Ganhe pontos fazendo check-ins</p>
          <p>🎁 Desbloqueie benefícios exclusivos</p>
          <p>👥 Descubra onde seus amigos estão</p>
        </div>
      </div>
    </div>
  )
} 