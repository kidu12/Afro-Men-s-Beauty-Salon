-- AFRO MEN'S BEAUTY SALON: Migration 006 - Flexible Barbers Schema
-- Allows adding new barbers directly from Admin Panel without requiring an auth account.

-- 1. Make profile_id nullable so admin can add barbers without a separate auth user
ALTER TABLE public.barbers ALTER COLUMN profile_id DROP NOT NULL;

-- 2. Add direct name and avatar_url columns to barbers table
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 3. Backfill name and avatar_url from existing profiles
UPDATE public.barbers b
SET name = p.full_name,
    avatar_url = p.avatar_url
FROM public.profiles p
WHERE b.profile_id = p.id AND (b.name IS NULL OR b.avatar_url IS NULL);
