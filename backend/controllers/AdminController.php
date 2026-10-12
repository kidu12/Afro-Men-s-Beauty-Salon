<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';
require_once dirname(__DIR__) . '/utils/ReferenceGenerator.php';
require_once dirname(__DIR__) . '/middleware/role.php';

class AdminController {
    public static function getDashboard(): void {
        RoleMiddleware::requireAdmin();
        $pdo = Database::getConnection();

        $today = date('Y-m-d');

        // 1. Appointments KPI Breakdown
        $stmt = $pdo->prepare("
            SELECT 
                COUNT(*) as total_appointments,
                SUM(CASE WHEN appointment_date = :today THEN 1 ELSE 0 END) as today_appointments,
                SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_count,
                SUM(CASE WHEN status IN ('confirmed', 'pending', 'checked_in', 'in_progress') THEN 1 ELSE 0 END) as upcoming_count,
                SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_count,
                SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) as no_show_count,
                SUM(CASE WHEN price_snapshot IS NOT NULL AND status = 'completed' THEN price_snapshot ELSE 0 END) as real_revenue,
                COUNT(DISTINCT customer_id) as active_clients
            FROM appointments
        ");
        $stmt->execute(['today' => $today]);
        $kpis = $stmt->fetch();

        // 2. Popular Services
        $svcStmt = $pdo->query("
            SELECT s.id, s.name, s.price, s.duration_minutes, COUNT(a.id) as booking_count
            FROM services s
            LEFT JOIN appointments a ON s.id = a.service_id
            WHERE s.is_active = 1 AND s.deleted_at IS NULL
            GROUP BY s.id
            ORDER BY booking_count DESC
            LIMIT 5
        ");
        $popularServices = $svcStmt->fetchAll();

        // 3. Top Barbers
        $barberStmt = $pdo->query("
            SELECT b.id, b.name, b.rating_avg, b.total_reviews, COUNT(a.id) as total_cuts
            FROM barbers b
            LEFT JOIN appointments a ON b.id = a.barber_id AND a.status = 'completed'
            WHERE b.is_active = 1
            GROUP BY b.id
            ORDER BY b.rating_avg DESC, total_cuts DESC
        ");
        $topBarbers = $barberStmt->fetchAll();

        Response::json([
            'kpis' => [
                'total_appointments' => (int)($kpis['total_appointments'] ?? 0),
                'today_appointments' => (int)($kpis['today_appointments'] ?? 0),
                'completed_count' => (int)($kpis['completed_count'] ?? 0),
                'upcoming_count' => (int)($kpis['upcoming_count'] ?? 0),
                'cancelled_count' => (int)($kpis['cancelled_count'] ?? 0),
                'no_show_count' => (int)($kpis['no_show_count'] ?? 0),
                'real_revenue' => (float)($kpis['real_revenue'] ?? 0.0),
                'active_clients' => (int)($kpis['active_clients'] ?? 0),
            ],
            'popular_services' => $popularServices,
            'top_barbers' => $topBarbers,
        ]);
    }

    public static function saveService(): void {
        RoleMiddleware::requireAdmin();
        $data = json_decode(file_get_contents('php://input'), true) ?? [];

        $id = $data['id'] ?? ReferenceGenerator::uuid();
        $categoryId = $data['category_id'] ?? 'cat-cuts';
        $name = trim($data['name'] ?? '');
        $description = trim($data['description'] ?? '');
        $price = isset($data['price']) && $data['price'] !== '' && $data['price'] !== null ? (float)$data['price'] : null; // Nullable!
        $duration = isset($data['duration_minutes']) ? (int)$data['duration_minutes'] : null;
        $imageUrl = $data['image_url'] ?? null;
        $displayOrder = (int)($data['display_order'] ?? 0);

        if (empty($name)) {
            Response::error('Service name is required.');
        }

        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("
            INSERT INTO services (id, category_id, name, description, price, duration_minutes, image_url, display_order, is_active, created_at)
            VALUES (:id, :cat_id, :name, :desc, :price, :duration, :img, :order, 1, NOW())
            ON DUPLICATE KEY UPDATE
                category_id = VALUES(category_id),
                name = VALUES(name),
                description = VALUES(description),
                price = VALUES(price),
                duration_minutes = VALUES(duration_minutes),
                image_url = VALUES(image_url),
                display_order = VALUES(display_order),
                updated_at = NOW()
        ");

        $stmt->execute([
            'id' => $id,
            'cat_id' => $categoryId,
            'name' => $name,
            'desc' => $description,
            'price' => $price,
            'duration' => $duration,
            'img' => $imageUrl,
            'order' => $displayOrder,
        ]);

        Response::json(['success' => true, 'id' => $id]);
    }

    public static function deleteService(string $id): void {
        RoleMiddleware::requireAdmin();
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("UPDATE services SET deleted_at = NOW(), is_active = 0 WHERE id = :id");
        $stmt->execute(['id' => $id]);

        Response::json(['success' => true]);
    }

    public static function saveBarber(): void {
        RoleMiddleware::requireAdmin();
        $data = json_decode(file_get_contents('php://input'), true) ?? [];

        $id = $data['id'] ?? ReferenceGenerator::uuid();
        $name = trim($data['name'] ?? '');
        $bio = trim($data['bio'] ?? '');
        $experienceYears = (int)($data['experience_years'] ?? 1);
        $avatarUrl = $data['avatar_url'] ?? null;
        $portfolioUrls = !empty($data['portfolio_urls']) ? json_encode($data['portfolio_urls']) : null;
        $branchId = $data['branch_id'] ?? 'branch-bole-main';

        if (empty($name)) {
            Response::error('Barber name is required.');
        }

        $pdo = Database::getConnection();

        // Check if profile exists, otherwise create a barber profile
        $stmt = $pdo->prepare("SELECT profile_id FROM barbers WHERE id = :id");
        $stmt->execute(['id' => $id]);
        $existing = $stmt->fetch();

        $profileId = $existing ? $existing['profile_id'] : ReferenceGenerator::uuid();

        if (!$existing) {
            $email = strtolower(str_replace(' ', '', $name)) . '@afrobarber.com';
            $pStmt = $pdo->prepare("
                INSERT INTO profiles (id, email, password_hash, full_name, role, branch_id, is_active, created_at)
                VALUES (:id, :email, :pass, :name, 'barber', :bid, 1, NOW())
            ");
            $pStmt->execute([
                'id' => $profileId,
                'email' => $email,
                'pass' => password_hash('password123', PASSWORD_BCRYPT),
                'name' => $name,
                'bid' => $branchId,
            ]);
        }

        $stmt = $pdo->prepare("
            INSERT INTO barbers (id, branch_id, profile_id, name, bio, experience_years, avatar_url, portfolio_urls, rating_avg, total_reviews, is_active, created_at)
            VALUES (:id, :bid, :pid, :name, :bio, :exp, :avatar, :portfolio, 0.00, 0, 1, NOW())
            ON DUPLICATE KEY UPDATE
                name = VALUES(name),
                bio = VALUES(bio),
                experience_years = VALUES(experience_years),
                avatar_url = VALUES(avatar_url),
                portfolio_urls = VALUES(portfolio_urls),
                updated_at = NOW()
        ");

        $stmt->execute([
            'id' => $id,
            'bid' => $branchId,
            'pid' => $profileId,
            'name' => $name,
            'bio' => $bio,
            'exp' => $experienceYears,
            'avatar' => $avatarUrl,
            'portfolio' => $portfolioUrls,
        ]);

        Response::json(['success' => true, 'id' => $id]);
    }

    public static function saveStyle(): void {
        RoleMiddleware::requireAdmin();
        $data = json_decode(file_get_contents('php://input'), true) ?? [];

        $id = $data['id'] ?? ReferenceGenerator::uuid();
        $name = trim($data['name'] ?? '');
        $description = trim($data['description'] ?? '');
        $category = trim($data['category'] ?? 'Classic');
        $serviceId = $data['recommended_service_id'] ?? 'srv-haircut';
        $isFeatured = !empty($data['is_featured']) ? 1 : 0;
        $isTrending = !empty($data['is_trending']) ? 1 : 0;
        $mediaList = $data['media'] ?? [];

        if (empty($name)) {
            Response::error('Style name is required.');
        }

        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("
            INSERT INTO hairstyles (id, branch_id, name, description, category, recommended_service_id, is_featured, is_trending, is_active, created_at)
            VALUES (:id, 'branch-bole-main', :name, :desc, :cat, :svc, :feat, :trend, 1, NOW())
            ON DUPLICATE KEY UPDATE
                name = VALUES(name),
                description = VALUES(description),
                category = VALUES(category),
                recommended_service_id = VALUES(recommended_service_id),
                is_featured = VALUES(is_featured),
                is_trending = VALUES(is_trending),
                updated_at = NOW()
        ");

        $stmt->execute([
            'id' => $id,
            'name' => $name,
            'desc' => $description,
            'cat' => $category,
            'svc' => $serviceId,
            'feat' => $isFeatured,
            'trend' => $isTrending,
        ]);

        // Insert media items
        if (!empty($mediaList)) {
            $delStmt = $pdo->prepare("DELETE FROM hairstyle_media WHERE hairstyle_id = :id");
            $delStmt->execute(['id' => $id]);

            $mStmt = $pdo->prepare("
                INSERT INTO hairstyle_media (id, hairstyle_id, media_url, media_type, thumbnail_url, display_order, created_at)
                VALUES (:id, :hid, :url, :type, :thumb, :order, NOW())
            ");

            foreach ($mediaList as $index => $m) {
                $mStmt->execute([
                    'id' => $m['id'] ?? ReferenceGenerator::uuid(),
                    'hid' => $id,
                    'url' => $m['media_url'] ?? '',
                    'type' => $m['media_type'] ?? 'image',
                    'thumb' => $m['thumbnail_url'] ?? null,
                    'order' => $index + 1,
                ]);
            }
        }

        Response::json(['success' => true, 'id' => $id]);
    }

    public static function getBarberDaysOff(string $barberId): void {
        RoleMiddleware::requireAdmin();
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("SELECT * FROM barber_days_off WHERE barber_id = :bid ORDER BY off_date DESC");
        $stmt->execute(['bid' => $barberId]);
        Response::json($stmt->fetchAll());
    }

    public static function addBarberDayOff(string $barberId): void {
        RoleMiddleware::requireAdmin();
        $data = json_decode(file_get_contents('php://input'), true) ?? [];
        $offDate = $data['off_date'] ?? '';
        $reason = $data['reason'] ?? '';

        if (empty($offDate)) {
            Response::error('off_date is required.');
        }

        $pdo = Database::getConnection();
        $id = ReferenceGenerator::uuid();
        $stmt = $pdo->prepare("
            INSERT INTO barber_days_off (id, barber_id, off_date, reason, created_at)
            VALUES (:id, :bid, :off_date, :reason, NOW())
        ");
        $stmt->execute([
            'id' => $id,
            'bid' => $barberId,
            'off_date' => $offDate,
            'reason' => $reason,
        ]);

        Response::json(['success' => true, 'id' => $id], 201);
    }

    public static function deleteBarberDayOff(string $barberId, string $dayOffId): void {
        RoleMiddleware::requireAdmin();
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("DELETE FROM barber_days_off WHERE id = :id AND barber_id = :bid");
        $stmt->execute(['id' => $dayOffId, 'bid' => $barberId]);
        Response::json(['success' => true]);
    }
}
