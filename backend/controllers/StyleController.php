<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';

class StyleController {
    public static function getStyles(): void {
        $pdo = Database::getConnection();

        $category = $_GET['category'] ?? null;
        $isFeatured = isset($_GET['featured']) ? (bool)$_GET['featured'] : null;
        $isTrending = isset($_GET['trending']) ? (bool)$_GET['trending'] : null;

        $sql = "SELECT * FROM hairstyles WHERE is_active = 1";
        $params = [];

        if ($category && $category !== 'All') {
            $sql .= " AND category LIKE :category";
            $params['category'] = "%$category%";
        }

        if ($isFeatured !== null) {
            $sql .= " AND is_featured = :featured";
            $params['featured'] = $isFeatured ? 1 : 0;
        }

        if ($isTrending !== null) {
            $sql .= " AND is_trending = :trending";
            $params['trending'] = $isTrending ? 1 : 0;
        }

        $sql .= " ORDER BY display_order ASC, created_at DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $styles = $stmt->fetchAll();

        // Fetch media for all styles
        if (!empty($styles)) {
            $styleIds = array_column($styles, 'id');
            $inClause = implode(',', array_fill(0, count($styleIds), '?'));
            $mediaStmt = $pdo->prepare("SELECT * FROM hairstyle_media WHERE hairstyle_id IN ($inClause) ORDER BY display_order ASC");
            $mediaStmt->execute($styleIds);
            $allMedia = $mediaStmt->fetchAll();

            $mediaByStyle = [];
            foreach ($allMedia as $m) {
                $mediaByStyle[$m['hairstyle_id']][] = [
                    'id' => $m['id'],
                    'hairstyle_id' => $m['hairstyle_id'],
                    'media_url' => $m['media_url'],
                    'media_type' => $m['media_type'],
                    'thumbnail_url' => $m['thumbnail_url'],
                    'display_order' => (int)$m['display_order'],
                ];
            }

            foreach ($styles as &$s) {
                $s['is_featured'] = (bool)$s['is_featured'];
                $s['is_trending'] = (bool)$s['is_trending'];
                $s['is_active'] = (bool)$s['is_active'];
                $s['display_order'] = (int)$s['display_order'];
                $s['hairstyle_media'] = $mediaByStyle[$s['id']] ?? [];
            }
        }

        Response::json($styles);
    }

    public static function getStyleById(string $id): void {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("SELECT * FROM hairstyles WHERE id = :id AND is_active = 1");
        $stmt->execute(['id' => $id]);
        $style = $stmt->fetch();

        if (!$style) {
            Response::error('Style not found.', 404);
        }

        $mediaStmt = $pdo->prepare("SELECT * FROM hairstyle_media WHERE hairstyle_id = :id ORDER BY display_order ASC");
        $mediaStmt->execute(['id' => $id]);
        $media = $mediaStmt->fetchAll();

        $style['is_featured'] = (bool)$style['is_featured'];
        $style['is_trending'] = (bool)$style['is_trending'];
        $style['is_active'] = (bool)$style['is_active'];
        $style['display_order'] = (int)$style['display_order'];
        $style['hairstyle_media'] = $media;

        Response::json($style);
    }
}
