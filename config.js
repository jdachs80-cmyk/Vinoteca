// Configuración de Supabase. Ambos valores están en Supabase > Project Settings > API.
// La "anon key" es pública por diseño: la seguridad la ponen las reglas (RLS) de supabase/schema.sql.
window.VINOTECA_CONFIG = {
  url: '',      // p. ej. 'https://abcdefgh.supabase.co'
  anonKey: ''   // la clave "anon public"
};
