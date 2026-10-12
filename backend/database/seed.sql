-- ==============================================================================
-- AFRO-BARBER SEED DATA (MySQL / MariaDB Compatible)
-- Password for all demo accounts: password123
-- Hash: $2y$10$eA32Yw0LzK1Q8f3cQG7Fte3w7I4J7v/P4lO0n3h4m/9w4z3x2q1u6
-- ==============================================================================

USE `Afro_Barber`;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Bole Flagship Branch
INSERT INTO `branches` (`id`, `name`, `slug`, `phone`, `email`, `address_line`, `city`, `subcity`, `latitude`, `longitude`, `is_active`) VALUES
('branch-bole-main', 'Afro-Barber Bole Flagship', 'bole-flagship', '+251911001122', 'bole@afrobarber.com', 'Cameroon St, Near Edna Mall, Bole', 'Addis Ababa', 'Bole', 8.99840000, 38.78810000, 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- 2. User Profiles (Admin, Barbers, Customer)
-- Note: In PHP password_hash('password123', PASSWORD_BCRYPT)
INSERT INTO `profiles` (`id`, `email`, `password_hash`, `full_name`, `phone`, `avatar_url`, `role`, `branch_id`, `is_active`) VALUES
('11111111-1111-1111-1111-111111111111', 'admin@afrobarber.com', '$2y$10$K38DWslzaiYZaWYOzn/KhO8IOkNzM6pNP46HJu7CezANVZ9KvnIM.', 'Afro-Barber Admin', '+251911000000', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80', 'admin', 'branch-bole-main', 1),
('22222222-2222-2222-2222-222222222222', 'mike@afrobarber.com', '$2y$10$K38DWslzaiYZaWYOzn/KhO8IOkNzM6pNP46HJu7CezANVZ9KvnIM.', 'Mike Tadesse', '+251911222222', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80', 'barber', 'branch-bole-main', 1),
('33333333-3333-3333-3333-333333333333', 'abel@afrobarber.com', '$2y$10$K38DWslzaiYZaWYOzn/KhO8IOkNzM6pNP46HJu7CezANVZ9KvnIM.', 'Abel Bekele', '+251911333333', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80', 'barber', 'branch-bole-main', 1),
('44444444-4444-4444-4444-444444444444', 'daniel@afrobarber.com', '$2y$10$K38DWslzaiYZaWYOzn/KhO8IOkNzM6pNP46HJu7CezANVZ9KvnIM.', 'Daniel Haile', '+251911444444', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&q=80', 'barber', 'branch-bole-main', 1),
('55555555-5555-5555-5555-555555555555', 'customer@afrobarber.com', '$2y$10$K38DWslzaiYZaWYOzn/KhO8IOkNzM6pNP46HJu7CezANVZ9KvnIM.', 'Kidus Alemu', '+251911234567', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&q=80', 'customer', 'branch-bole-main', 1)
ON DUPLICATE KEY UPDATE `full_name` = VALUES(`full_name`), `password_hash` = VALUES(`password_hash`);

-- 3. Service Categories
INSERT INTO `service_categories` (`id`, `name`, `description`, `icon_name`, `display_order`, `is_active`) VALUES
('cat-cuts', 'Haircuts & Styling', 'Master barber cuts, fades, line-ups and textures', 'scissors', 1, 1),
('cat-beard', 'Beard & Grooming', 'Precision shaping, hot towel shave & oil sculpt', 'beard', 2, 1),
('cat-treatments', 'Hair & Scalp Treatments', 'Scalp detox, deep conditioning, and washing', 'sparkles', 3, 1),
('cat-kids', 'Kids Cuts', 'Gentle, stylish cuts for the young kings', 'smile', 4, 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- 4. Services (STRICTLY NULL PRICES per master business requirement!)
INSERT INTO `services` (`id`, `category_id`, `name`, `description`, `price`, `duration_minutes`, `image_url`, `is_active`, `display_order`) VALUES
('srv-haircut', 'cat-cuts', 'Signature Haircut', 'Precision tailored haircut, razor-sharp edge up, neck shave & hot towel finish.', NULL, 45, 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80', 1, 1),
('srv-haircut-beard', 'cat-cuts', 'Haircut & Beard Sculpting', 'Full signature haircut combined with precision beard trim, oil treatment & razor line.', NULL, 60, 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80', 1, 2),
('srv-beard-trim', 'cat-beard', 'Beard Sculpt & Razor Shape', 'Detailed beard sculpting, line crisping with straight razor and essential oil massage.', NULL, 20, 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=600&q=80', 1, 3),
('srv-kids-cut', 'cat-kids', 'Kids Signature Cut', 'Gentle, modern, crisp styling for youngsters up to 12 years old.', NULL, 30, 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=600&q=80', 1, 4),
('srv-hair-wash', 'cat-treatments', 'Invigorating Wash & Scalp Care', 'Deep cleansing wash, tea tree scalp massage, and conditioning treatment.', NULL, 25, 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600&q=80', 1, 5)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- 5. Barbers (Mike: 4.90 rating/84 reviews, Abel: 4.80 rating/62 reviews, Daniel: 0.00 rating/0 reviews - New barber!)
INSERT INTO `barbers` (`id`, `branch_id`, `profile_id`, `name`, `avatar_url`, `bio`, `experience_years`, `rating_avg`, `total_reviews`, `portfolio_urls`, `is_active`) VALUES
('barber-mike', 'branch-bole-main', '22222222-2222-2222-2222-222222222222', 'Mike Tadesse', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80', 'Master fade architect with 7+ years experience specializing in afro textures, razor-sharp tapers, and textured crops.', 7, 4.90, 84, '["https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=600&q=80", "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=600&q=80"]', 1),
('barber-abel', 'branch-bole-main', '33333333-3333-3333-3333-333333333333', 'Abel Bekele', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80', 'Beard grooming artist and afro styling specialist. Precision detailing and hot towel relaxation cuts.', 5, 4.80, 62, '["https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&q=80", "https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=600&q=80"]', 1),
('barber-daniel', 'branch-bole-main', '44444444-4444-4444-4444-444444444444', 'Daniel Haile', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&q=80', 'Rising stylist trained in modern streetwear cuts, curly fades, and classic aesthetics.', 2, 0.00, 0, '["https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600&q=80"]', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- 6. Hairstyles
INSERT INTO `hairstyles` (`id`, `branch_id`, `name`, `description`, `category`, `recommended_service_id`, `is_featured`, `is_trending`, `is_active`, `display_order`) VALUES
('style-1', 'branch-bole-main', 'Low Drop Fade + Textured Sponge Top', 'Ultra-clean low drop fade tapering seamlessly around the ears with defined afro curl texture on top.', 'Low Fade', 'srv-haircut', 1, 1, 1, 1),
('style-2', 'branch-bole-main', 'Mid Skin Fade + Crisp Box Lineup', 'High-contrast mid skin fade with razor-straight frontal framing. Sharp, masculine, and symmetrical.', 'Mid Fade', 'srv-haircut', 1, 0, 1, 2),
('style-3', 'branch-bole-main', 'Temple Taper Fade + Geometric Beard', 'Refined temple & neckline taper keeping natural afro bulk with a seamlessly blended luxury beard.', 'Taper', 'srv-haircut-beard', 1, 1, 1, 3),
('style-4', 'branch-bole-main', 'Dreadlock Retwist + High Fade', 'Clean manicured loc retwist with a tight high fade accentuating the loc structure.', 'Dreads', 'srv-haircut', 0, 1, 1, 4),
('style-5', 'branch-bole-main', '360 Waves + Low Taper', 'Flawless 360 wave pattern with low temple and neck blowouts for a timeless luxury aesthetic.', 'Classic', 'srv-haircut', 0, 0, 1, 5),
('style-6', 'branch-bole-main', 'Full Beard Sculpt + Razor Detailing', 'Full-bodied beard groomed to perfection with symmetrical cheek arches and sharp neckline.', 'Beard', 'srv-beard-trim', 0, 1, 1, 6)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- 7. Hairstyle Media
INSERT INTO `hairstyle_media` (`id`, `hairstyle_id`, `media_url`, `media_type`, `thumbnail_url`, `display_order`) VALUES
('media-1-img', 'style-1', 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=300&q=80', 1),
('media-1-vid', 'style-1', 'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-a-machine-41094-large.mp4', 'video', 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=300&q=80', 2),
('media-2-img', 'style-2', 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=300&q=80', 1),
('media-3-img', 'style-3', 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=300&q=80', 1),
('media-4-img', 'style-4', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=300&q=80', 1),
('media-5-img', 'style-5', 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?w=300&q=80', 1),
('media-6-img', 'style-6', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80', 'image', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80', 1)
ON DUPLICATE KEY UPDATE `media_url` = VALUES(`media_url`);

-- 8. Business Hours (0=Sunday ... 6=Saturday)
INSERT INTO `business_hours` (`id`, `branch_id`, `day_of_week`, `open_time`, `close_time`, `is_closed`) VALUES
('bh-0', 'branch-bole-main', 0, '10:00:00', '18:00:00', 0),
('bh-1', 'branch-bole-main', 1, '09:00:00', '20:00:00', 0),
('bh-2', 'branch-bole-main', 2, '09:00:00', '20:00:00', 0),
('bh-3', 'branch-bole-main', 3, '09:00:00', '20:00:00', 0),
('bh-4', 'branch-bole-main', 4, '09:00:00', '20:00:00', 0),
('bh-5', 'branch-bole-main', 5, '09:00:00', '20:00:00', 0),
('bh-6', 'branch-bole-main', 6, '09:00:00', '20:00:00', 0)
ON DUPLICATE KEY UPDATE `open_time` = VALUES(`open_time`);

-- 9. Barber Schedules
INSERT INTO `barber_schedules` (`id`, `barber_id`, `day_of_week`, `start_time`, `end_time`, `is_working`) VALUES
('bs-m-1', 'barber-mike', 1, '09:00:00', '20:00:00', 1),
('bs-m-2', 'barber-mike', 2, '09:00:00', '20:00:00', 1),
('bs-m-3', 'barber-mike', 3, '09:00:00', '20:00:00', 1),
('bs-m-4', 'barber-mike', 4, '09:00:00', '20:00:00', 1),
('bs-m-5', 'barber-mike', 5, '09:00:00', '20:00:00', 1),
('bs-m-6', 'barber-mike', 6, '09:00:00', '20:00:00', 1),
('bs-m-0', 'barber-mike', 0, '10:00:00', '18:00:00', 1),
('bs-a-1', 'barber-abel', 1, '09:00:00', '20:00:00', 1),
('bs-a-2', 'barber-abel', 2, '09:00:00', '20:00:00', 1),
('bs-a-3', 'barber-abel', 3, '09:00:00', '20:00:00', 1),
('bs-a-4', 'barber-abel', 4, '09:00:00', '20:00:00', 1),
('bs-a-5', 'barber-abel', 5, '09:00:00', '20:00:00', 1),
('bs-a-6', 'barber-abel', 6, '09:00:00', '20:00:00', 1),
('bs-a-0', 'barber-abel', 0, '10:00:00', '18:00:00', 1),
('bs-d-1', 'barber-daniel', 1, '09:00:00', '20:00:00', 1),
('bs-d-2', 'barber-daniel', 2, '09:00:00', '20:00:00', 1),
('bs-d-3', 'barber-daniel', 3, '09:00:00', '20:00:00', 1),
('bs-d-4', 'barber-daniel', 4, '09:00:00', '20:00:00', 1),
('bs-d-5', 'barber-daniel', 5, '09:00:00', '20:00:00', 1),
('bs-d-6', 'barber-daniel', 6, '09:00:00', '20:00:00', 1),
('bs-d-0', 'barber-daniel', 0, '10:00:00', '18:00:00', 1)
ON DUPLICATE KEY UPDATE `is_working` = VALUES(`is_working`);

-- 10. Initial Appointments with AFB-YYYYMMDD-XXXXXX reference
INSERT INTO `appointments` (`id`, `appointment_reference`, `branch_id`, `customer_id`, `barber_id`, `service_id`, `hairstyle_id`, `appointment_date`, `start_time`, `end_time`, `status`, `price_snapshot`, `duration_snapshot`, `service_name_snapshot`, `notes`, `created_at`, `completed_at`) VALUES
('apt-1', 'AFB-20260822-X7K29P', 'branch-bole-main', '55555555-5555-5555-5555-555555555555', 'barber-mike', 'srv-haircut', 'style-1', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:30:00', '15:15:00', 'confirmed', NULL, 45, 'Signature Haircut', 'Keep the top curls natural', NOW(), NULL),
('apt-past-1', 'AFB-20260814-B8M42W', 'branch-bole-main', '55555555-5555-5555-5555-555555555555', 'barber-abel', 'srv-haircut-beard', 'style-3', DATE_SUB(CURDATE(), INTERVAL 7 DAY), '11:00:00', '12:00:00', 'completed', NULL, 60, 'Haircut & Beard Sculpting', NULL, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE `status` = VALUES(`status`);

-- 11. Initial Reviews
INSERT INTO `reviews` (`id`, `appointment_id`, `customer_id`, `barber_id`, `rating`, `comment`, `created_at`) VALUES
('rev-1', 'apt-past-1', '55555555-5555-5555-5555-555555555555', 'barber-abel', 5, 'Abel is an absolute master. The hot towel finish and temple taper were clean and sharp!', DATE_SUB(NOW(), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE `rating` = VALUES(`rating`);

-- 12. Initial Notifications
INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `is_read`, `data`, `created_at`) VALUES
('notif-1', '55555555-5555-5555-5555-555555555555', 'Appointment Confirmed! 💈', 'Your appointment (AFB-20260822-X7K29P) with Mike Tadesse for Signature Haircut is confirmed for tomorrow at 02:30 PM.', 'appointment_confirmed', 0, '{"appointment_id": "apt-1", "reference": "AFB-20260822-X7K29P"}', NOW()),
('notif-2', '55555555-5555-5555-5555-555555555555', 'Welcome to Afro-Barber', 'Discover our modern hairstyle gallery, choose your barber, and book your style in seconds.', 'welcome', 1, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`);

SET FOREIGN_KEY_CHECKS = 1;
