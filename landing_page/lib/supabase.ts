import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://rhqeocinbcsnkqhzgetw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJocWVvY2luYmNzbmtxaHpnZXR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MzIyNzAsImV4cCI6MjA5MjUwODI3MH0.N3u8vtAIrMPtYqYXKljk9aDjGasbSX54_R8q4V-TAhg';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
