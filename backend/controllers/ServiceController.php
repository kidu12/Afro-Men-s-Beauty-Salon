<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';

class ServiceController {
    public static function getCategories(): void {
        $pdo = Database::getConnection();
        $stmt = $pdo->query("SELECT * FROM service_categories WHERE is_active = 1 ORDER BY display_order ASC");
        $categories = $stmt->fetchAll();

        foreach ($categories as &$c) {
            $c['display_order'] = (int)$c['display_order'];
            $c['is_active'] = (bool)$c['is_active'];
        }

        Response::json($categories);
    }

    public static function getServices(): void {
        $pdo = Database::getConnection();
        $categoryId = $_GET['category_id'] ?? null;

        $sql = "SELECT * FROM services WHERE is_active = 1 AND deleted_at IS NULL";
        $params = [];

        if ($categoryId) {
            $sql .= " AND category_id = :cat_id";
            $params['cat_id'] = $categoryId;
        }

        $sql .= " ORDER BY display_order ASC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $services = $stmt->fetchAll();

        foreach ($services as &$s) {
            $s['price'] = $s['price'] !== null ? (float)$s['price'] : null; // Strictly preserve NULL!
            $s['duration_minutes'] = $s['duration_minutes'] !== null ? (int)$s['duration_minutes'] : null;
            $s['is_active'] = (bool)$s['is_active'];
            $s['display_order'] = (int)$s['display_order'];
        }

        Response::json($services);
    }

    public static function getServiceById(string $id): void {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("SELECT * FROM services WHERE id = :id AND deleted_at IS NULL");
        $stmt->execute(['id' => $id]);
        $service = $stmt->fetch();

        if (!$service) {
            Response::error('Service not found.', 404);
        }

        $service['price'] = $service['price'] !== null ? (float)$service['price'] : null;
        $service['duration_minutes'] = $service['duration_minutes'] !== null ? (int)$service['duration_minutes'] : null;
        $service['is_active'] = (bool)$service['is_active'];
        $service['display_order'] = (int)$service['display_order'];

        Response::json($service);
    }
}
