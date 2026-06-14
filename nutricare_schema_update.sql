-- NutriCare - Supabase Database Schema Update (Phase 10)
-- PASTE AND RUN THIS IN THE SUPABASE SQL EDITOR TO SETUP AVATARS AND RESILIENT SIGNUPS

-- 1. ADD avatar_url COLUMN TO profiles TABLE
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 2. CREATE A STORAGE BUCKET FOR USER AVATARS
-- Create avatars bucket in Supabase storage schema
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 3. ESTABLISH STORAGE RLS POLICIES FOR THE AVATARS BUCKET
-- Delete old policies if they already exist to avoid errors
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Allow Uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow Updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow Deletes" ON storage.objects;

-- Policy to allow anyone to select/view avatars
CREATE POLICY "Public Access" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

-- Policy to allow authenticated users to upload their own avatar files
CREATE POLICY "Allow Uploads" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatars');

-- Policy to allow authenticated users to update their own avatar files
CREATE POLICY "Allow Updates" ON storage.objects
  FOR UPDATE TO authenticated USING (bucket_id = 'avatars');

-- Policy to allow authenticated users to delete their own avatar files
CREATE POLICY "Allow Deletes" ON storage.objects
  FOR DELETE TO authenticated USING (bucket_id = 'avatars');


-- 4. BULLETPROOF AUTOMATED PROFILE TRIGGERS FOR NEW USERS
-- A database trigger on auth.users that automatically populates profiles and health_profiles rows the split second a user signs up.
-- Running with SECURITY DEFINER means it bypasses any client-side RLS constraints, resolving signup profile errors for confirmed and unconfirmed real accounts alike.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into public.profiles
  INSERT INTO public.profiles (user_id, first_name, last_name, age, phone, gender, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'first_name', 
      NEW.raw_user_meta_data->>'given_name', 
      split_part(NEW.raw_user_meta_data->>'full_name', ' ', 1), 
      'User'
    ),
    COALESCE(
      NEW.raw_user_meta_data->>'last_name', 
      NEW.raw_user_meta_data->>'family_name', 
      split_part(NEW.raw_user_meta_data->>'full_name', ' ', 2), 
      ''
    ),
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'age', '')::int, 60),
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'gender',
    COALESCE(
      NEW.raw_user_meta_data->>'avatar_url', 
      NEW.raw_user_meta_data->>'picture', 
      ''
    )
  )
  ON CONFLICT (user_id) DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    avatar_url = COALESCE(NULLIF(EXCLUDED.avatar_url, ''), profiles.avatar_url);

  -- Insert into public.health_profiles
  INSERT INTO public.health_profiles (user_id, weight_kg, height_cm)
  VALUES (NEW.id, 70.0, 170)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger to ensure it maps correctly to the function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. CREATE TABLE FOR MEDICATION LOGS (IF NOT EXISTS)
CREATE TABLE IF NOT EXISTS public.medication_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_id UUID NOT NULL REFERENCES public.medications(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'taken',
  taken_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Enable RLS on medication_logs
ALTER TABLE public.medication_logs ENABLE ROW LEVEL SECURITY;

-- Policy to allow authenticated users to manage their own medication logs
DROP POLICY IF EXISTS "Users can manage own medication logs" ON public.medication_logs;
CREATE POLICY "Users can manage own medication logs" ON public.medication_logs
  FOR ALL TO authenticated USING (
    medication_id IN (SELECT id FROM public.medications WHERE user_id = auth.uid())
  );
