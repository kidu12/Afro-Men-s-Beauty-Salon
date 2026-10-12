<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';
require_once dirname(__DIR__) . '/middleware/auth.php';

class NotificationController {
    public static function getNotifications(): void {
        $user = AuthMiddleware::authenticate();
        $pdo = Database::getConnection();

        $stmt = $pdo->prepare("SELECT * FROM notifications WHERE user_id = :uid ORDER BY created_at DESC");
        $stmt->execute(['uid' => $user['sub']]);
        $notifications = $stmt->fetchAll();

        foreach ($notifications as &$n) {
            $n['is_read'] = (bool)$n['is_read'];
            $n['data'] = !empty($n['data']) ? json_decode($n['data'], true) : [];
        }

        Response::json($notifications);
    }

    public static function markAsRead(string $id): void {
        $user = AuthMiddleware::authenticate();
        $pdo = Database::getConnection();

        $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1 WHERE id = :id AND user_id = :uid");
        $stmt->execute(['id' => $id, 'uid' => $user['sub']]);

        Response::json(['success' => true]);
    }

    public static function markAllAsRead(): void {
        $user = AuthMiddleware::authenticate();
        $pdo = Database::getConnection();

        $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = :uid");
        $stmt->execute(['uid' => $user['sub']]);

        Response::json(['success' => true]);
    }
}
