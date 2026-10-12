-- AFRO-BARBER SEED DATA
-- Default Branch, Service Categories, Services (with NULL prices per business spec), Barbers, Hairstyles, Media, Business Hours

DO $$
DECLARE
  v_branch_id UUID := '00000000-0000-0000-0000-000000000001'::UUID;
  v_admin_id UUID := '11111111-1111-1111-1111-111111111111'::UUID;
  v_mike_id UUID := '22222222-2222-2222-2222-222222222222'::UUID;
  v_abel_id UUID := '33333333-3333-3333-3333-333333333333'::UUID;
  v_daniel_id UUID := '44444444-4444-4444-4444-444444444444'::UUID;
  v_customer_id UUID := '55555555-5555-5555-5555-555555555555'::UUID;

  v_cat_cuts UUID := 'a0000000-0000-0000-0000-000000000001'::UUID;
  v_cat_beard UUID := 'a0000000-0000-0000-0000-000000000002'::UUID;
  v_cat_treatments UUID := 'a0000000-0000-0000-0000-000000000003'::UUID;
  v_cat_kids UUID := 'a0000000-0000-0000-0000-000000000004'::UUID;

  v_srv_haircut UUID := 'b0000000-0000-0000-0000-000000000001'::UUID;
  v_srv_haircut_beard UUID := 'b0000000-0000-0000-0000-000000000002'::UUID;
  v_srv_beard_trim UUID := 'b0000000-0000-0000-0000-000000000003'::UUID;
  v_srv_kids_cut UUID := 'b0000000-0000-0000-0000-000000000004'::UUID;
  v_srv_hair_wash UUID := 'b0000000-0000-0000-0000-000000000005'::UUID;

  v_barber_mike UUID := 'c0000000-0000-0000-0000-000000000001'::UUID;
  v_barber_abel UUID := 'c0000000-0000-0000-0000-000000000002'::UUID;
  v_barber_daniel UUID := 'c0000000-0000-0000-0000-000000000003'::UUID;

  v_style_1 UUID := 'd0000000-0000-0000-0000-000000000001'::UUID;
  v_style_2 UUID := 'd0000000-0000-0000-0000-000000000002'::UUID;
  v_style_3 UUID := 'd0000000-0000-0000-0000-000000000003'::UUID;
  v_style_4 UUID := 'd0000000-0000-0000-0000-000000000004'::UUID;
  v_style_5 UUID := 'd0000000-0000-0000-0000-000000000005'::UUID;
  v_style_6 UUID := 'd0000000-0000-0000-0000-000000000006'::UUID;
BEGIN
  -- 1. Insert Branch
  INSERT INTO public.branches (id, name, slug, address, phone, timezone, latitude, longitude)
  VALUES (v_branch_id, 'Afro-Barber Bole Flagship', 'bole-flagship', 'Bole Medhanialem, Edna Mall Rd, Addis Ababa', '+251911223344', 'Africa/Addis_Ababa', 8.9984, 38.7891)
  ON CONFLICT (id) DO NOTHING;

  -- 2. Insert Profiles
  INSERT INTO public.profiles (id, full_name, email, phone, role, avatar_url)
  VALUES
    (v_admin_id, 'Shop Admin', 'admin@afrobarber.com', '+251911000001', 'admin', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80'),
    (v_mike_id, 'Mike Tadesse', 'mike@afrobarber.com', '+251911000002', 'barber', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80'),
    (v_abel_id, 'Abel Bekele', 'abel@afrobarber.com', '+251911000003', 'barber', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80'),
    (v_daniel_id, 'Daniel Haile', 'daniel@afrobarber.com', '+251911000004', 'barber', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&q=80'),
    (v_customer_id, 'Kidus Alemu', 'customer@afrobarber.com', '+251911000005', 'customer', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&q=80')
  ON CONFLICT (id) DO NOTHING;

  -- 3. Insert Barbers (All barbers rated 5.0 with experience)
  INSERT INTO public.barbers (id, branch_id, profile_id, bio, experience_years, rating_avg, total_reviews, portfolio_urls)
  VALUES
    (v_barber_mike, v_branch_id, v_mike_id, 'Master fade architect with 7+ years of experience specializing in afro textures, razor sharp tapers, and textured crops.', 7, 5.00, 84, ARRAY['https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=600&q=80']),
    (v_barber_abel, v_branch_id, v_abel_id, 'Beard grooming artist and afro styling specialist. Precision detailing and hot towel relaxation cuts.', 5, 5.00, 62, ARRAY['https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80']),
    (v_barber_daniel, v_branch_id, v_daniel_id, 'Rising stylist trained in modern streetwear cuts, curly fades, and classic aesthetics.', 2, 5.00, 14, ARRAY['https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80'])
  ON CONFLICT (id) DO NOTHING;

  -- 4. Insert Service Categories
  INSERT INTO public.service_categories (id, branch_id, name, description, icon_name, display_order)
  VALUES
    (v_cat_cuts, v_branch_id, 'Haircuts & Styling', 'Master barber cuts, fades, line-ups and textures', 'scissors', 1),
    (v_cat_beard, v_branch_id, 'Beard & Facial Grooming', 'Precision shaping, hot towel shave, and beard sculpting', 'beard', 2),
    (v_cat_treatments, v_branch_id, 'Hair & Scalp Treatments', 'Scalp detox, deep conditioning, and washing', 'sparkles', 3),
    (v_cat_kids, v_branch_id, 'Kids Cuts', 'Patient, stylish cuts for the young kings', 'smile', 4)
  ON CONFLICT (id) DO NOTHING;

  -- 5. Insert Services (strictly NULL prices per business spec!)
  INSERT INTO public.services (id, branch_id, category_id, name, description, price, duration_minutes, image_url, display_order)
  VALUES
    (v_srv_haircut, v_branch_id, v_cat_cuts, 'Signature Haircut', 'Precision tailored haircut, razor-sharp edge up, neck shave & hot towel finish.', NULL, 45, 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80', 1),
    (v_srv_haircut_beard, v_branch_id, v_cat_cuts, 'Haircut & Beard Sculpting', 'Full signature haircut combined with precision beard trim, oil treatment & razor line.', NULL, 60, 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80', 2),
    (v_srv_beard_trim, v_branch_id, v_cat_beard, 'Beard Sculpt & Razor Shape', 'Detailed beard sculpting, line crisping with straight razor and essential oil massage.', NULL, 20, 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=600&q=80', 3),
    (v_srv_kids_cut, v_branch_id, v_cat_kids, 'Kids Signature Cut', 'Gentle, modern, crisp styling for youngsters up to 12 years old.', NULL, 30, 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=600&q=80', 4),
    (v_srv_hair_wash, v_branch_id, v_cat_treatments, 'Invigorating Wash & Scalp Care', 'Deep cleansing wash, tea tree scalp massage, and conditioning treatment.', NULL, 20, 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600&q=80', 5)
  ON CONFLICT (id) DO NOTHING;

  -- 6. Insert Hairstyles
  INSERT INTO public.hairstyles (id, branch_id, name, description, category, recommended_service_id, is_featured, is_trending, display_order)
  VALUES
    (v_style_1, v_branch_id, 'Low Drop Fade + Textured Sponge Top', 'Ultra-clean low drop fade tapering seamlessly around the ears with defined afro curl texture on top.', 'Low Fade', v_srv_haircut, true, true, 1),
    (v_style_2, v_branch_id, 'Mid Skin Fade + Crisp Box Lineup', 'High-contrast mid skin fade with razor-straight frontal framing. Sharp, masculine, and symmetrical.', 'Mid Fade', v_srv_haircut, true, false, 2),
    (v_style_3, v_branch_id, 'Temple Taper Fade + Geometric Beard', 'Refined temple & neckline taper keeping natural afro bulk with a seamlessly blended luxury beard.', 'Taper', v_srv_haircut_beard, true, true, 3),
    (v_style_4, v_branch_id, 'Dreadlock Retwist + High Fade', 'Clean manicured loc retwist with a tight high fade accentuating the loc structure.', 'Dreads', v_srv_haircut, false, true, 4),
    (v_style_5, v_branch_id, '360 Waves + Low Taper', 'Flawless 360 wave pattern with low temple and neck blowouts for a timeless luxury aesthetic.', 'Classic', v_srv_haircut, false, false, 5),
    (v_style_6, v_branch_id, 'Full Beard Sculpt + Razor Detailing', 'Full-bodied beard groomed to perfection with symmetrical cheek arches and sharp neckline.', 'Beard', v_srv_beard_trim, false, true, 6)
  ON CONFLICT (id) DO NOTHING;

  -- 7. Insert Hairstyle Media (High quality photography & video demo links)
  INSERT INTO public.hairstyle_media (hairstyle_id, media_url, media_type, thumbnail_url, display_order)
  VALUES
    (v_style_1, 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=300&q=80', 1),
    (v_style_1, 'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-a-machine-41094-large.mp4', 'video', 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=300&q=80', 2),
    (v_style_2, 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=300&q=80', 1),
    (v_style_3, 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=300&q=80', 1),
    (v_style_4, 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=300&q=80', 1),
    (v_style_5, 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=300&q=80', 1),
    (v_style_6, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80', 1)
  ON CONFLICT DO NOTHING;

  -- 8. Insert Business Hours (0 = Sun, 1 = Mon ... 6 = Sat)
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

  -- 9. Insert Barber Schedules
  FOR i IN 1..6 LOOP
    INSERT INTO public.barber_schedules (barber_id, day_of_week, start_time, end_time, is_working)
    VALUES
      (v_barber_mike, i, '09:00:00', '19:00:00', true),
      (v_barber_abel, i, '10:00:00', '20:00:00', true),
      (v_barber_daniel, i, '09:00:00', '18:00:00', true)
    ON CONFLICT (barber_id, day_of_week) DO NOTHING;
  END LOOP;

  -- Sunday schedule for Mike & Abel
  INSERT INTO public.barber_schedules (barber_id, day_of_week, start_time, end_time, is_working)
  VALUES
    (v_barber_mike, 0, '10:00:00', '18:00:00', true),
    (v_barber_abel, 0, '10:00:00', '18:00:00', false),
    (v_barber_daniel, 0, '10:00:00', '18:00:00', true)
  ON CONFLICT (barber_id, day_of_week) DO NOTHING;

  -- 10. Business Settings
  INSERT INTO public.business_settings (branch_id, setting_key, setting_value)
  VALUES
    (v_branch_id, 'cancellation_allowed_hours', '2'::jsonb),
    (v_branch_id, 'reschedule_allowed_hours', '2'::jsonb),
    (v_branch_id, 'reminder_intervals_hours', '[24, 2]'::jsonb)
  ON CONFLICT (branch_id, setting_key) DO NOTHING;

END $$;
