-- ============================================================
-- AFRO-BARBER: Migration 005 - Sync Website Barbers, Services & Schedules
-- This syncs the mobile app database with the website (barbershop).
-- ============================================================

-- 1. Relax profiles FK constraint on auth.users so staff/barber profiles can exist
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- 2. Update Branch info to match Website (Ayat Tebel Condominium)
UPDATE public.branches
SET 
  name = 'Afro Men''s Beauty Salon',
  address = 'Ayat Tebel Condominium, Addis Ababa, Ethiopia',
  phone = '+251913101492'
WHERE id = '00000000-0000-0000-0000-000000000001';

-- Ensure Business Hours are 09:00 to 21:00 every day
DELETE FROM public.business_hours WHERE branch_id = '00000000-0000-0000-0000-000000000001';
INSERT INTO public.business_hours (branch_id, day_of_week, open_time, close_time, is_closed)
VALUES
  ('00000000-0000-0000-0000-000000000001', 0, '09:00:00', '21:00:00', false),
  ('00000000-0000-0000-0000-000000000001', 1, '09:00:00', '21:00:00', false),
  ('00000000-0000-0000-0000-000000000001', 2, '09:00:00', '21:00:00', false),
  ('00000000-0000-0000-0000-000000000001', 3, '09:00:00', '21:00:00', false),
  ('00000000-0000-0000-0000-000000000001', 4, '09:00:00', '21:00:00', false),
  ('00000000-0000-0000-0000-000000000001', 5, '09:00:00', '21:00:00', false),
  ('00000000-0000-0000-0000-000000000001', 6, '09:00:00', '21:00:00', false);

-- 3. Sync Service Categories from Website
DELETE FROM public.service_categories WHERE branch_id = '00000000-0000-0000-0000-000000000001';
INSERT INTO public.service_categories (id, branch_id, name, description, icon_name, display_order)
VALUES
  ('a0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'PREMIUM', 'VIP & Home-to-Home Luxury Grooming', 'crown', 1),
  ('a0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'HAIR', 'Precision Haircuts & Fades', 'scissors', 2),
  ('a0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'HAIRCARE', 'Hair Wash & Conditioning', 'sparkles', 3),
  ('a0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'HAIR STYLE', 'Finger Coils (ከርል) & Creative Styles', 'style', 4);

-- 4. Sync Exact Services from Website
DELETE FROM public.services WHERE branch_id = '00000000-0000-0000-0000-000000000001';
INSERT INTO public.services (id, branch_id, category_id, name, description, price, duration_minutes, image_url, display_order, is_active)
VALUES
  ('b0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'VIP', 'for all hair cut styles', 3500.00, 60,
   'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', 1, true),

  ('b0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002',
   'Haircut', 'for all hair cut styles', 600.00, 30,
   'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', 2, true),

  ('b0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003',
   'Hair Cut With Hair Wash', 'Refreshing wash and cut', 700.00, 40,
   'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', 3, true),

  ('b0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000004',
   'Finger coils (ከርል)', 'Premium finger coils styling', 900.00, 45,
   'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', 4, true),

  ('b0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003',
   'Hair Wash', 'Refreshing wash, scalp massage, and towel dry.', 400.00, 30,
   'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', 5, true),

  ('b0000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000004',
   'Hair cut + Finger coils', 'ቁርጥ እና ከርል', 1400.00, 60,
   'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', 6, true),

  ('b0000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'Home to Home Service', 'Exclusive VIP service at your home with our dedicated specialist, Tedi.', 5000.00, 120,
   'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&q=80&w=600', 7, true);

-- 5. Insert Barber Profiles (John, Michael, David, Tedi)
INSERT INTO public.profiles (id, full_name, email, phone, role, avatar_url)
VALUES
  ('10000000-0000-0000-0000-000000000001', 'John', 'john@afrobarber.com', '+251911000001', 'barber', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=300'),
  ('10000000-0000-0000-0000-000000000002', 'Michael', 'michael@afrobarber.com', '+251911000002', 'barber', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=300'),
  ('10000000-0000-0000-0000-000000000003', 'David', 'david@afrobarber.com', '+251911000003', 'barber', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=300'),
  ('10000000-0000-0000-0000-000000000004', 'Tedi', 'tedi@afrobarber.com', '+251911000004', 'barber', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=300')
ON CONFLICT (id) DO UPDATE
SET full_name = EXCLUDED.full_name,
    avatar_url = EXCLUDED.avatar_url;

-- 6. Insert Barbers from Website
DELETE FROM public.barbers WHERE branch_id = '00000000-0000-0000-0000-000000000001';
INSERT INTO public.barbers (id, branch_id, profile_id, bio, experience_years, rating_avg, total_reviews, is_active)
VALUES
  ('c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001',
   'Master Barber specializing in classic cuts and modern fades.', 5, 4.90, 48, true),

  ('c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002',
   'Senior Stylist with 8+ years precision cutting experience.', 8, 4.95, 76, true),

  ('c0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003',
   'Expert in beard grooming, line-ups, and skin fades.', 6, 4.85, 34, true),

  ('c0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000004',
   'Home Service Specialist exclusively delivering VIP haircuts at your doorstep.', 7, 4.98, 92, true);

-- 7. Insert Weekly Schedules for all 4 barbers (Sunday 0 through Saturday 6)
DELETE FROM public.barber_schedules WHERE barber_id IN (
  'c0000000-0000-0000-0000-000000000001',
  'c0000000-0000-0000-0000-000000000002',
  'c0000000-0000-0000-0000-000000000003',
  'c0000000-0000-0000-0000-000000000004'
);

INSERT INTO public.barber_schedules (barber_id, day_of_week, start_time, end_time, is_working)
SELECT b.id, d.day, '09:00:00'::time, '21:00:00'::time, true
FROM (
  VALUES 
    ('c0000000-0000-0000-0000-000000000001'::uuid),
    ('c0000000-0000-0000-0000-000000000002'::uuid),
    ('c0000000-0000-0000-0000-000000000003'::uuid),
    ('c0000000-0000-0000-0000-000000000004'::uuid)
) AS b(id)
CROSS JOIN (
  VALUES (0), (1), (2), (3), (4), (5), (6)
) AS d(day);
