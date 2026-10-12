-- ============================================================
-- AFRO-BARBER: Safe Seed Data (No auth.users dependency)
-- Run this AFTER the 3 migration files.
-- This inserts: branch, categories, services, hairstyles,
--               media, business hours, and business settings.
-- Profiles & barbers are created via the app's register/admin screens.
-- ============================================================

DO $$
DECLARE
  v_branch_id   UUID := '00000000-0000-0000-0000-000000000001'::UUID;

  v_cat_cuts        UUID := 'a0000000-0000-0000-0000-000000000001'::UUID;
  v_cat_beard       UUID := 'a0000000-0000-0000-0000-000000000002'::UUID;
  v_cat_treatments  UUID := 'a0000000-0000-0000-0000-000000000003'::UUID;
  v_cat_kids        UUID := 'a0000000-0000-0000-0000-000000000004'::UUID;

  v_srv_haircut       UUID := 'b0000000-0000-0000-0000-000000000001'::UUID;
  v_srv_haircut_beard UUID := 'b0000000-0000-0000-0000-000000000002'::UUID;
  v_srv_beard_trim    UUID := 'b0000000-0000-0000-0000-000000000003'::UUID;
  v_srv_kids_cut      UUID := 'b0000000-0000-0000-0000-000000000004'::UUID;
  v_srv_hair_wash     UUID := 'b0000000-0000-0000-0000-000000000005'::UUID;

  v_style_1 UUID := 'd0000000-0000-0000-0000-000000000001'::UUID;
  v_style_2 UUID := 'd0000000-0000-0000-0000-000000000002'::UUID;
  v_style_3 UUID := 'd0000000-0000-0000-0000-000000000003'::UUID;
  v_style_4 UUID := 'd0000000-0000-0000-0000-000000000004'::UUID;
  v_style_5 UUID := 'd0000000-0000-0000-0000-000000000005'::UUID;
  v_style_6 UUID := 'd0000000-0000-0000-0000-000000000006'::UUID;
BEGIN

  -- ── 1. Branch ───────────────────────────────────────────────────────────
  INSERT INTO public.branches (id, name, slug, address, phone, timezone, latitude, longitude)
  VALUES (
    v_branch_id,
    'Afro-Barber Bole Flagship',
    'bole-flagship',
    'Bole Medhanialem, Edna Mall Rd, Addis Ababa',
    '+251911223344',
    'Africa/Addis_Ababa',
    8.9984,
    38.7891
  )
  ON CONFLICT (id) DO NOTHING;

  -- ── 2. Service Categories ───────────────────────────────────────────────
  INSERT INTO public.service_categories (id, branch_id, name, description, icon_name, display_order)
  VALUES
    (v_cat_cuts,       v_branch_id, 'Haircuts & Styling',        'Master barber cuts, fades, line-ups and textures',              'scissors',  1),
    (v_cat_beard,      v_branch_id, 'Beard & Facial Grooming',   'Precision shaping, hot towel shave, and beard sculpting',        'beard',     2),
    (v_cat_treatments, v_branch_id, 'Hair & Scalp Treatments',   'Scalp detox, deep conditioning, and washing',                   'sparkles',  3),
    (v_cat_kids,       v_branch_id, 'Kids Cuts',                 'Patient, stylish cuts for the young kings',                     'smile',     4)
  ON CONFLICT (id) DO NOTHING;

  -- ── 3. Services (prices are NULL per business spec) ─────────────────────
  INSERT INTO public.services (id, branch_id, category_id, name, description, price, duration_minutes, image_url, display_order)
  VALUES
    (v_srv_haircut,       v_branch_id, v_cat_cuts,       'Signature Haircut',
      'Precision tailored haircut, razor-sharp edge up, neck shave & hot towel finish.',
      NULL, 45, 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80', 1),

    (v_srv_haircut_beard, v_branch_id, v_cat_cuts,       'Haircut & Beard Sculpting',
      'Full signature haircut combined with precision beard trim, oil treatment & razor line.',
      NULL, 60, 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80', 2),

    (v_srv_beard_trim,    v_branch_id, v_cat_beard,      'Beard Sculpt & Razor Shape',
      'Detailed beard sculpting, line crisping with straight razor and essential oil massage.',
      NULL, 20, 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=600&q=80', 3),

    (v_srv_kids_cut,      v_branch_id, v_cat_kids,       'Kids Signature Cut',
      'Gentle, modern, crisp styling for youngsters up to 12 years old.',
      NULL, 30, 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=600&q=80', 4),

    (v_srv_hair_wash,     v_branch_id, v_cat_treatments, 'Invigorating Wash & Scalp Care',
      'Deep cleansing wash, tea tree scalp massage, and conditioning treatment.',
      NULL, 20, 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600&q=80', 5)
  ON CONFLICT (id) DO NOTHING;

  -- ── 4. Hairstyles ────────────────────────────────────────────────────────
  INSERT INTO public.hairstyles (id, branch_id, name, description, category, recommended_service_id, is_featured, is_trending, display_order)
  VALUES
    (v_style_1, v_branch_id, 'Low Drop Fade + Textured Sponge Top',
      'Ultra-clean low drop fade tapering seamlessly around the ears with defined afro curl texture on top.',
      'Low Fade', v_srv_haircut, true, true, 1),

    (v_style_2, v_branch_id, 'Mid Skin Fade + Crisp Box Lineup',
      'High-contrast mid skin fade with razor-straight frontal framing. Sharp, masculine, and symmetrical.',
      'Mid Fade', v_srv_haircut, true, false, 2),

    (v_style_3, v_branch_id, 'Temple Taper Fade + Geometric Beard',
      'Refined temple & neckline taper keeping natural afro bulk with a seamlessly blended luxury beard.',
      'Taper', v_srv_haircut_beard, true, true, 3),

    (v_style_4, v_branch_id, 'Dreadlock Retwist + High Fade',
      'Clean manicured loc retwist with a tight high fade accentuating the loc structure.',
      'Dreads', v_srv_haircut, false, true, 4),

    (v_style_5, v_branch_id, '360 Waves + Low Taper',
      'Flawless 360 wave pattern with low temple and neck blowouts for a timeless luxury aesthetic.',
      'Classic', v_srv_haircut, false, false, 5),

    (v_style_6, v_branch_id, 'Full Beard Sculpt + Razor Detailing',
      'Full-bodied beard groomed to perfection with symmetrical cheek arches and sharp neckline.',
      'Beard', v_srv_beard_trim, false, true, 6)
  ON CONFLICT (id) DO NOTHING;

  -- ── 5. Hairstyle Media ───────────────────────────────────────────────────
  INSERT INTO public.hairstyle_media (hairstyle_id, media_url, media_type, thumbnail_url, display_order)
  VALUES
    (v_style_1, 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800&q=80',  'image', 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=300&q=80', 1),
    (v_style_1, 'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-a-machine-41094-large.mp4', 'video', 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=300&q=80', 2),
    (v_style_2, 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80',  'image', 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=300&q=80', 1),
    (v_style_3, 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800&q=80',  'image', 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=300&q=80', 1),
    (v_style_4, 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80',  'image', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=300&q=80', 1),
    (v_style_5, 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=800&q=80',  'image', 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=300&q=80', 1),
    (v_style_6, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',  'image', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80', 1)
  ON CONFLICT DO NOTHING;

  -- ── 6. Business Hours (0=Sun … 6=Sat) ───────────────────────────────────
  INSERT INTO public.business_hours (branch_id, day_of_week, open_time, close_time, is_closed)
  VALUES
    (v_branch_id, 0, '10:00:00', '18:00:00', false),
    (v_branch_id, 1, '09:00:00', '20:00:00', false),
    (v_branch_id, 2, '09:00:00', '20:00:00', false),
    (v_branch_id, 3, '09:00:00', '20:00:00', false),
    (v_branch_id, 4, '09:00:00', '20:00:00', false),
    (v_branch_id, 5, '09:00:00', '20:00:00', false),
    (v_branch_id, 6, '09:00:00', '20:00:00', false)
  ON CONFLICT (branch_id, day_of_week) DO NOTHING;

  -- ── 7. Business Settings ─────────────────────────────────────────────────
  INSERT INTO public.business_settings (branch_id, setting_key, setting_value)
  VALUES
    (v_branch_id, 'cancellation_allowed_hours',  '2'::jsonb),
    (v_branch_id, 'reschedule_allowed_hours',    '2'::jsonb),
    (v_branch_id, 'reminder_intervals_hours',    '[24, 2]'::jsonb)
  ON CONFLICT (branch_id, setting_key) DO NOTHING;

END $$;
