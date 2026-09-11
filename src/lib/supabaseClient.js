import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://bgfhmxwpsihkqjhgrjbj.supabase.co'
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_eZL57fjrKO2ag3Lxy59uYA_Fn2U05xi'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
