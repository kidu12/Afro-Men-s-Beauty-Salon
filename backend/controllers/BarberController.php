<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';
require_once dirname(__DIR__) . '/middleware/auth.php';

class BarberController {
    public static function getBarbers(): void {
        $includeInactive = false;
        try {
            $user = AuthMiddleware::authenticate();
            if ($user && $user['role'] === 'admin') {
                $includeInactive = true;
            }
        } catch (Throwable $e) {}

        $pdo = Database::getConnection();
        $sql = "SELECT * FROM barbers";
        if (!$includeInactive) {
            $sql .= " WHERE is_active = 1";
        }
        $sql .= " ORDER BY rating_avg DESC, total_reviews DESC";

        $stmt = $pdo->query($sql);
        $barbers = $stmt->fetchAll();

        foreach ($barbers as &$b) {
            $b['experience_years'] = (int)$b['experience_years'];
            $b['rating_avg'] = (float)$b['rating_avg'];
            $b['total_reviews'] = (int)$b['total_reviews'];
            $b['is_active'] = (bool)$b['is_active'];
            $b['portfolio_urls'] = !empty($b['portfolio_urls']) ? json_decode($b['portfolio_urls'], true) : [];
        }

        Response::json($barbers);
    }

    public static function getBarberById(string $id): void {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("SELECT * FROM barbers WHERE id = :id AND is_active = 1");
        $stmt->execute(['id' => $id]);
        $barber = $stmt->fetch();

        if (!$barber) {
            Response::error('Barber not found.', 404);
        }

        $barber['experience_years'] = (int)$barber['experience_years'];
        $barber['rating_avg'] = (float)$barber['rating_avg'];
        $barber['total_reviews'] = (int)$barber['total_reviews'];
        $barber['is_active'] = (bool)$barber['is_active'];
        $barber['portfolio_urls'] = !empty($barber['portfolio_urls']) ? json_decode($barber['portfolio_urls'], true) : [];

        Response::json($barber);
    }

    public static function getTodayAppointments(): void {
        $user = AuthMiddleware::authenticate();
        $pdo = Database::getConnection();

        // If barber, look up barber_id from profile
        $barberId = null;
        if ($user['role'] === 'barber') {
            $stmt = $pdo->prepare("SELECT id FROM barbers WHERE profile_id = :pid");
            $stmt->execute(['pid' => $user['sub']]);
            $barber = $stmt->fetch();
            if ($barber) {
                $barberId = $barber['id'];
            }
        } elseif (isset($_GET['barber_id'])) {
            $barberId = $_GET['barber_id'];
        }

        $today = date('Y-m-d');
        $sql = "
            SELECT a.*, p.full_name as customer_name, p.phone as customer_phone, p.avatar_url as customer_avatar
            FROM appointments a
            JOIN profiles p ON a.customer_id = p.id
            WHERE a.appointment_date = :today
        ";
        $params = ['today' => $today];

        if ($barberId) {
            $sql .= " AND a.barber_id = :bid";
            $params['bid'] = $barberId;
        }

        $sql .= " ORDER BY a.start_time ASC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $appointments = $stmt->fetchAll();

        foreach ($appointments as &$a) {
            $a['price_snapshot'] = $a['price_snapshot'] !== null ? (float)$a['price_snapshot'] : null;
            $a['duration_snapshot'] = $a['duration_snapshot'] !== null ? (int)$a['duration_snapshot'] : null;
        }

        Response::json($appointments);
    }
}
