-- ==============================================================================
-- AFRO-BARBER DATABASE SCHEMA (MySQL 8.0+ / MariaDB Compatible)
-- Database Name: Afro_Barber
-- Timezone assumption: Africa/Addis_Ababa (UTC+3)
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `Afro_Barber` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `Afro_Barber`;

-- Disable Foreign Key Checks during table creation
SET FOREIGN_KEY_CHECKS = 0;

-- 1. BRANCHES (Multi-Branch Ready)
DROP TABLE IF EXISTS `branches`;
CREATE TABLE `branches` (
    `id` VARCHAR(36) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(100) UNIQUE NOT NULL,
    `phone` VARCHAR(20),
    `email` VARCHAR(100),
    `address_line` VARCHAR(255) NOT NULL,
    `city` VARCHAR(100) NOT NULL DEFAULT 'Addis Ababa',
    `subcity` VARCHAR(100) NOT NULL DEFAULT 'Bole',
    `latitude` DECIMAL(10, 8),
    `longitude` DECIMAL(11, 8),
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. USER PROFILES & AUTHENTICATION
DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
    `id` VARCHAR(36) PRIMARY KEY,
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `full_name` VARCHAR(150) NOT NULL,
    `phone` VARCHAR(20),
    `avatar_url` TEXT,
    `role` ENUM('customer', 'barber', 'admin') NOT NULL DEFAULT 'customer',
    `branch_id` VARCHAR(36),
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_profiles_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. SERVICE CATEGORIES
DROP TABLE IF EXISTS `service_categories`;
CREATE TABLE `service_categories` (
    `id` VARCHAR(36) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `icon_name` VARCHAR(50),
    `display_order` INT NOT NULL DEFAULT 0,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. SERVICES (Price & Duration are Nullable per master requirements!)
DROP TABLE IF EXISTS `services`;
CREATE TABLE `services` (
    `id` VARCHAR(36) PRIMARY KEY,
    `category_id` VARCHAR(36) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `price` DECIMAL(10, 2) NULL, -- Strictly NULLABLE! Never replace with 0
    `duration_minutes` INT NULL, -- NULLABLE! Booking requires > 0
    `image_url` TEXT,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `display_order` INT NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    CONSTRAINT `fk_services_category` FOREIGN KEY (`category_id`) REFERENCES `service_categories` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. BARBERS
DROP TABLE IF EXISTS `barbers`;
CREATE TABLE `barbers` (
    `id` VARCHAR(36) PRIMARY KEY,
    `branch_id` VARCHAR(36),
    `profile_id` VARCHAR(36) UNIQUE NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `avatar_url` TEXT,
    `bio` TEXT,
    `experience_years` INT NOT NULL DEFAULT 1,
    `rating_avg` DECIMAL(3, 2) NOT NULL DEFAULT 0.00, -- Starts at 0.00 for new barbers!
    `total_reviews` INT NOT NULL DEFAULT 0,
    `portfolio_urls` JSON,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_barbers_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_barbers_profile` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. HAIRSTYLES
DROP TABLE IF EXISTS `hairstyles`;
CREATE TABLE `hairstyles` (
    `id` VARCHAR(36) PRIMARY KEY,
    `branch_id` VARCHAR(36),
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `category` VARCHAR(50) NOT NULL,
    `recommended_service_id` VARCHAR(36),
    `is_featured` BOOLEAN NOT NULL DEFAULT FALSE,
    `is_trending` BOOLEAN NOT NULL DEFAULT FALSE,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `display_order` INT NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_hairstyles_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_hairstyles_service` FOREIGN KEY (`recommended_service_id`) REFERENCES `services` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. HAIRSTYLE MEDIA (Photos & Videos)
DROP TABLE IF EXISTS `hairstyle_media`;
CREATE TABLE `hairstyle_media` (
    `id` VARCHAR(36) PRIMARY KEY,
    `hairstyle_id` VARCHAR(36) NOT NULL,
    `media_url` TEXT NOT NULL,
    `media_type` ENUM('image', 'video') NOT NULL DEFAULT 'image',
    `thumbnail_url` TEXT,
    `display_order` INT NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_media_hairstyle` FOREIGN KEY (`hairstyle_id`) REFERENCES `hairstyles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. BUSINESS HOURS
DROP TABLE IF EXISTS `business_hours`;
CREATE TABLE `business_hours` (
    `id` VARCHAR(36) PRIMARY KEY,
    `branch_id` VARCHAR(36) NOT NULL,
    `day_of_week` TINYINT NOT NULL COMMENT '0=Sunday, 1=Monday ... 6=Saturday',
    `open_time` TIME NOT NULL,
    `close_time` TIME NOT NULL,
    `is_closed` BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE KEY `uk_branch_day` (`branch_id`, `day_of_week`),
    CONSTRAINT `fk_hours_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. BARBER SCHEDULES
DROP TABLE IF EXISTS `barber_schedules`;
CREATE TABLE `barber_schedules` (
    `id` VARCHAR(36) PRIMARY KEY,
    `barber_id` VARCHAR(36) NOT NULL,
    `day_of_week` TINYINT NOT NULL,
    `start_time` TIME NOT NULL,
    `end_time` TIME NOT NULL,
    `is_working` BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY `uk_barber_day` (`barber_id`, `day_of_week`),
    CONSTRAINT `fk_schedules_barber` FOREIGN KEY (`barber_id`) REFERENCES `barbers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. BARBER DAYS OFF
DROP TABLE IF EXISTS `barber_days_off`;
CREATE TABLE `barber_days_off` (
    `id` VARCHAR(36) PRIMARY KEY,
    `barber_id` VARCHAR(36) NOT NULL,
    `off_date` DATE NOT NULL,
    `reason` VARCHAR(255),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_barber_off_date` (`barber_id`, `off_date`),
    CONSTRAINT `fk_daysoff_barber` FOREIGN KEY (`barber_id`) REFERENCES `barbers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. SPECIAL CLOSURES
DROP TABLE IF EXISTS `special_closures`;
CREATE TABLE `special_closures` (
    `id` VARCHAR(36) PRIMARY KEY,
    `branch_id` VARCHAR(36) NOT NULL,
    `closure_date` DATE NOT NULL,
    `reason` VARCHAR(255),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_branch_closure` (`branch_id`, `closure_date`),
    CONSTRAINT `fk_closures_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. APPOINTMENTS (Atomic Double-Booking Protected)
DROP TABLE IF EXISTS `appointments`;
CREATE TABLE `appointments` (
    `id` VARCHAR(36) PRIMARY KEY,
    `appointment_reference` VARCHAR(50) UNIQUE NOT NULL, -- e.g. 'AFB-20260821-X7K29P'
    `branch_id` VARCHAR(36),
    `customer_id` VARCHAR(36) NOT NULL,
    `barber_id` VARCHAR(36) NOT NULL,
    `service_id` VARCHAR(36) NOT NULL,
    `hairstyle_id` VARCHAR(36) NULL,
    `appointment_date` DATE NOT NULL,
    `start_time` TIME NOT NULL,
    `end_time` TIME NOT NULL,
    `status` ENUM('pending', 'confirmed', 'checked_in', 'in_progress', 'completed', 'cancelled', 'no_show') NOT NULL DEFAULT 'confirmed',
    `price_snapshot` DECIMAL(10, 2) NULL, -- Snapshots price at booking
    `duration_snapshot` INT NULL,
    `service_name_snapshot` VARCHAR(150) NOT NULL,
    `notes` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `cancelled_at` DATETIME NULL,
    `completed_at` DATETIME NULL,
    INDEX `idx_barber_date` (`barber_id`, `appointment_date`, `status`),
    INDEX `idx_customer` (`customer_id`, `appointment_date`),
    INDEX `idx_reference` (`appointment_reference`),
    CONSTRAINT `fk_apt_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_apt_customer` FOREIGN KEY (`customer_id`) REFERENCES `profiles` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_apt_barber` FOREIGN KEY (`barber_id`) REFERENCES `barbers` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_apt_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_apt_hairstyle` FOREIGN KEY (`hairstyle_id`) REFERENCES `hairstyles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. APPOINTMENT STATUS HISTORY (Audit Trail)
DROP TABLE IF EXISTS `appointment_status_history`;
CREATE TABLE `appointment_status_history` (
    `id` VARCHAR(36) PRIMARY KEY,
    `appointment_id` VARCHAR(36) NOT NULL,
    `previous_status` VARCHAR(30) NULL,
    `new_status` VARCHAR(30) NOT NULL,
    `changed_by` VARCHAR(36) NOT NULL,
    `reason` VARCHAR(255),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_history_apt` (`appointment_id`),
    CONSTRAINT `fk_history_apt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. REVIEWS
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
    `id` VARCHAR(36) PRIMARY KEY,
    `appointment_id` VARCHAR(36) UNIQUE NOT NULL,
    `customer_id` VARCHAR(36) NOT NULL,
    `barber_id` VARCHAR(36) NOT NULL,
    `rating` TINYINT NOT NULL COMMENT '1 to 5',
    `comment` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_reviews_barber` (`barber_id`),
    CONSTRAINT `fk_reviews_apt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_customer` FOREIGN KEY (`customer_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_barber` FOREIGN KEY (`barber_id`) REFERENCES `barbers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. FAVORITES
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites` (
    `id` VARCHAR(36) PRIMARY KEY,
    `user_id` VARCHAR(36) NOT NULL,
    `item_type` ENUM('style', 'barber', 'service') NOT NULL,
    `item_id` VARCHAR(36) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_fav` (`user_id`, `item_type`, `item_id`),
    CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16. NOTIFICATIONS
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
    `id` VARCHAR(36) PRIMARY KEY,
    `user_id` VARCHAR(36) NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `message` TEXT NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `is_read` BOOLEAN NOT NULL DEFAULT FALSE,
    `data` JSON,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_notif_user` (`user_id`, `is_read`),
    CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
