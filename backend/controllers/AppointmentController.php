<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';
require_once dirname(__DIR__) . '/middleware/auth.php';
require_once dirname(__DIR__) . '/services/BookingService.php';
require_once dirname(__DIR__) . '/services/AvailabilityService.php';

class AppointmentController {
    public static function getAvailability(): void {
        $barberId = $_GET['barber_id'] ?? '';
        $serviceId = $_GET['service_id'] ?? '';
        $date = $_GET['date'] ?? '';

        if (empty($barberId) || empty($serviceId) || empty($date)) {
            Response::error('barber_id, service_id, and date are required parameters.');
        }

        $slots = AvailabilityService::getAvailableSlots($barberId, $serviceId, $date);
        Response::json($slots);
    }

    public static function create(): void {
        $user = AuthMiddleware::authenticate();
        $data = json_decode(file_get_contents('php://input'), true) ?? [];

        $data['customer_id'] = $user['sub'];

        if (empty($data['barber_id']) || empty($data['service_id']) || empty($data['appointment_date']) || empty($data['start_time'])) {
            Response::error('barber_id, service_id, appointment_date, and start_time are required.');
        }

        try {
            $appointment = BookingService::createAppointment($data);
            Response::json($appointment, 201);
        } catch (RuntimeException $e) {
            Response::error($e->getMessage(), $e->getCode() ?: 409);
        } catch (InvalidArgumentException $e) {
            Response::error($e->getMessage(), 400);
        } catch (Throwable $e) {
            Response::error('Failed to create appointment. Please try again.', 500, $e->getMessage());
        }
    }

    public static function list(): void {
        $user = AuthMiddleware::authenticate();
        $pdo = Database::getConnection();

        $customerId = $_GET['customer_id'] ?? null;
        $barberId = $_GET['barber_id'] ?? null;

        // If customer role, strictly confine to their own appointments
        if ($user['role'] === 'customer') {
            $customerId = $user['sub'];
        }

        $sql = "
            SELECT a.*, 
                   cp.full_name as customer_name, cp.phone as customer_phone, cp.avatar_url as customer_avatar,
                   bp.full_name as barber_name, bp.avatar_url as barber_avatar,
                   h.name as hairstyle_name
            FROM appointments a
            JOIN profiles cp ON a.customer_id = cp.id
            JOIN barbers b ON a.barber_id = b.id
            JOIN profiles bp ON b.profile_id = bp.id
            LEFT JOIN hairstyles h ON a.hairstyle_id = h.id
            WHERE 1=1
        ";
        $params = [];

        if ($customerId) {
            $sql .= " AND a.customer_id = :cid";
            $params['cid'] = $customerId;
        }

        if ($barberId) {
            $sql .= " AND a.barber_id = :bid";
            $params['bid'] = $barberId;
        }

        $sql .= " ORDER BY a.appointment_date DESC, a.start_time DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $appointments = $stmt->fetchAll();

        foreach ($appointments as &$a) {
            $a['price_snapshot'] = $a['price_snapshot'] !== null ? (float)$a['price_snapshot'] : null;
            $a['duration_snapshot'] = $a['duration_snapshot'] !== null ? (int)$a['duration_snapshot'] : null;
        }

        Response::json($appointments);
    }

    public static function getById(string $id): void {
        $user = AuthMiddleware::authenticate();
        $pdo = Database::getConnection();

        $stmt = $pdo->prepare("
            SELECT a.*, 
                   cp.full_name as customer_name, cp.phone as customer_phone, cp.avatar_url as customer_avatar,
                   bp.full_name as barber_name, bp.avatar_url as barber_avatar,
                   h.name as hairstyle_name
            FROM appointments a
            JOIN profiles cp ON a.customer_id = cp.id
            JOIN barbers b ON a.barber_id = b.id
            JOIN profiles bp ON b.profile_id = bp.id
            LEFT JOIN hairstyles h ON a.hairstyle_id = h.id
            WHERE a.id = :id
        ");
        $stmt->execute(['id' => $id]);
        $apt = $stmt->fetch();

        if (!$apt) {
            Response::error('Appointment not found.', 404);
        }

        // Authorization check: customer can only view own appointment
        if ($user['role'] === 'customer' && $apt['customer_id'] !== $user['sub']) {
            Response::error('Access denied.', 403);
        }

        // Fetch status history
        $hStmt = $pdo->prepare("SELECT * FROM appointment_status_history WHERE appointment_id = :id ORDER BY created_at ASC");
        $hStmt->execute(['id' => $id]);
        $apt['status_history'] = $hStmt->fetchAll();

        $apt['price_snapshot'] = $apt['price_snapshot'] !== null ? (float)$apt['price_snapshot'] : null;
        $apt['duration_snapshot'] = $apt['duration_snapshot'] !== null ? (int)$apt['duration_snapshot'] : null;

        Response::json($apt);
    }

    public static function cancel(string $id): void {
        $user = AuthMiddleware::authenticate();
        try {
            $res = BookingService::updateStatus($id, 'cancelled', $user['sub'], 'Cancelled by user');
            Response::json($res);
        } catch (Throwable $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    public static function updateStatus(string $id, string $status): void {
        $user = AuthMiddleware::authenticate();
        try {
            $res = BookingService::updateStatus($id, $status, $user['sub']);
            Response::json($res);
        } catch (Throwable $e) {
            Response::error($e->getMessage(), 400);
        }
    }
}
