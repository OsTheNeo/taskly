import { createClient } from '@supabase/supabase-js';
import { supabaseConfig } from './config';

// Cliente de Supabase para el navegador (sin tipos estrictos para flexibilidad)
export const supabase = createClient(
  supabaseConfig.url,
  supabaseConfig.anonKey
);

// Helper para obtener el cliente
export function getSupabaseClient() {
  return supabase;
}
