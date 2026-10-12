<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';
require_once dirname(__DIR__) . '/utils/ReferenceGenerator.php';
require_once dirname(__DIR__) . '/middleware/auth.php';

class ReviewController {
    public static function getReviews(): void {
        $pdo = Database::getConnection();
        $barberId = $_GET['barber_id'] ?? null;

        $sql = "
            SELECT r.*, p.full_name as customer_name, p.avatar_url as customer_avatar
            FROM reviews r
            JOIN profiles p ON r.customer_id = p.id
            WHERE 1=1
        ";
        $params = [];

        if ($barberId) {
            $sql .= " AND r.barber_id = :bid";
            $params['bid'] = $barberId;
        }

        $sql .= " ORDER BY r.created_at DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $reviews = $stmt->fetchAll();

        foreach ($reviews as &$r) {
            $r['rating'] = (int)$r['rating'];
        }

        Response::json($reviews);
    }

    public static function create(): void {
        $user = AuthMiddleware::authenticate();
        $data = json_decode(file_get_contents('php://input'), true) ?? [];

        $appointmentId = $data['appointment_id'] ?? '';
        $rating = (int)($data['rating'] ?? 0);
        $comment = trim($data['comment'] ?? '');

        if (empty($appointmentId) || $rating < 1 || $rating > 5) {
            Response::error('Valid appointment_id and rating (1-5) are required.');
        }

        $pdo = Database::getConnection();

        // 1. Verify Appointment: must exist, belong to user, and be completed
        $stmt = $pdo->prepare("SELECT id, barber_id, customer_id, status FROM appointments WHERE id = :id");
        $stmt->execute(['id' => $appointmentId]);
        $apt = $stmt->fetch();

        if (!$apt) {
            Response::error('Appointment not found.', 404);
        }

        if ($apt['customer_id'] !== $user['sub']) {
            Response::error('You can only review your own appointments.', 403);
        }

        if ($apt['status'] !== 'completed') {
            Response::error('Reviews can only be submitted for completed appointments.', 400);
        }

        // 2. Check duplicate review
        $stmt = $pdo->prepare("SELECT id FROM reviews WHERE appointment_id = :aid");
        $stmt->execute(['aid' => $appointmentId]);
        if ($stmt->fetch()) {
            Response::error('You have already submitted a review for this appointment.', 409);
        }

        // 3. Insert Review
        $reviewId = ReferenceGenerator::uuid();
        $stmt = $pdo->prepare("
            INSERT INTO reviews (id, appointment_id, customer_id, barber_id, rating, comment, created_at)
            VALUES (:id, :aid, :cid, :bid, :rating, :comment, NOW())
        ");
        $stmt->execute([
            'id' => $reviewId,
            'aid' => $appointmentId,
            'cid' => $user['sub'],
            'bid' => $apt['barber_id'],
            'rating' => $rating,
            'comment' => !empty($comment) ? $comment : null,
        ]);

        // 4. Recalculate Barber Rating Dynamically
        $barberId = $apt['barber_id'];
        $calcStmt = $pdo->prepare("SELECT AVG(rating) as avg_rating, COUNT(*) as total_count FROM reviews WHERE barber_id = :bid");
        $calcStmt->execute(['bid' => $barberId]);
        $calc = $calcStmt->fetch();

        $avg = round((float)($calc['avg_rating'] ?? 0), 2);
        $total = (int)($calc['total_count'] ?? 0);

        $updateStmt = $pdo->prepare("UPDATE barbers SET rating_avg = :avg, total_reviews = :total WHERE id = :bid");
        $updateStmt->execute(['avg' => $avg, 'total' => $total, 'bid' => $barberId]);

        Response::json([
            'id' => $reviewId,
            'appointment_id' => $appointmentId,
            'customer_id' => $user['sub'],
            'barber_id' => $barberId,
            'rating' => $rating,
            'comment' => $comment,
            'created_at' => date('Y-m-d H:i:s'),
        ], 201);
    }
}
