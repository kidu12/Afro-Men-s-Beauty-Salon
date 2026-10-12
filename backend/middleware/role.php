<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once dirname(__DIR__) . '/utils/Response.php';

class RoleMiddleware {
    public static function requireRole(string ...$allowedRoles): array {
        $user = AuthMiddleware::authenticate();

        if (!in_array($user['role'] ?? '', $allowedRoles, true)) {
            Response::error('Access denied. Insufficient permissions for this role.', 403);
        }

        return $user;
    }

    public static function requireAdmin(): array {
        return self::requireRole('admin');
    }

    public static function requireBarber(): array {
        return self::requireRole('barber', 'admin');
    }
}
