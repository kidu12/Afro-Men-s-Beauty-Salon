-- AFRO MEN'S BEAUTY SALON: Migration 005 - Storage Buckets & Policies
-- Creates public buckets for avatars, hairstyles, services and configures RLS

-- 1. Create public buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('avatars', 'avatars', true),
  ('hairstyles', 'hairstyles', true),
  ('services', 'services', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Drop existing policies to prevent conflicts
DROP POLICY IF EXISTS "Public Avatars Access" ON storage.objects;
DROP POLICY IF EXISTS "Allow Uploads to Avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow Updates to Avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow Deletes from Avatars" ON storage.objects;

DROP POLICY IF EXISTS "Public Hairstyles Access" ON storage.objects;
DROP POLICY IF EXISTS "Allow Uploads to Hairstyles" ON storage.objects;

DROP POLICY IF EXISTS "Public Services Access" ON storage.objects;
DROP POLICY IF EXISTS "Allow Uploads to Services" ON storage.objects;

-- 3. Read access policies (publicly viewable)
CREATE POLICY "Public Avatars Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Public Hairstyles Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'hairstyles');

CREATE POLICY "Public Services Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'services');

-- 4. Upload access policies (allows authenticated users & admins to upload)
CREATE POLICY "Allow Uploads to Avatars"
ON storage.objects FOR INSERT
TO authenticated, anon
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Allow Updates to Avatars"
ON storage.objects FOR UPDATE
TO authenticated, anon
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Allow Deletes from Avatars"
ON storage.objects FOR DELETE
TO authenticated, anon
USING (bucket_id = 'avatars');

CREATE POLICY "Allow Uploads to Hairstyles"
ON storage.objects FOR INSERT
TO authenticated, anon
WITH CHECK (bucket_id = 'hairstyles');

CREATE POLICY "Allow Uploads to Services"
ON storage.objects FOR INSERT
TO authenticated, anon
WITH CHECK (bucket_id = 'services');
