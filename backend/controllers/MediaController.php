<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';
require_once dirname(__DIR__) . '/utils/ReferenceGenerator.php';
require_once dirname(__DIR__) . '/middleware/role.php';

class MediaController {
    public static function upload(): void {
        RoleMiddleware::requireBarber(); // Barber or admin can upload media

        if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
            Response::error('No valid file uploaded.');
        }

        $config = require dirname(__DIR__) . '/config/config.php';
        $file = $_FILES['file'];
        $type = $_POST['type'] ?? 'image'; // 'image' or 'video'
        $category = $_POST['folder'] ?? 'styles'; // 'styles', 'videos', 'barbers', 'avatars'

        $targetDir = $config['uploads']['dir'] . '/' . $category;
        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0755, true);
        }

        // Validate File Size & MIME
        $mime = mime_content_type($file['tmp_name']);
        if ($type === 'video') {
            if (!in_array($mime, $config['uploads']['allowed_video_mimes'], true)) {
                Response::error('Invalid video format. Allowed: MP4, WebM, MOV.');
            }
            if ($file['size'] > $config['uploads']['max_video_size']) {
                Response::error('Video exceeds maximum size limit (50MB).');
            }
        } else {
            if (!in_array($mime, $config['uploads']['allowed_image_mimes'], true)) {
                Response::error('Invalid image format. Allowed: JPEG, PNG, WEBP.');
            }
            if ($file['size'] > $config['uploads']['max_image_size']) {
                Response::error('Image exceeds maximum size limit (5MB).');
            }
        }

        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = ReferenceGenerator::uuid() . '.' . strtolower($ext);
        $destination = $targetDir . '/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            Response::error('Failed to save uploaded file.');
        }

        $baseUrl = $config['app']['base_url'];
        $publicUrl = "$baseUrl/uploads/$category/$filename";

        Response::json([
            'url' => $publicUrl,
            'filename' => $filename,
            'mime' => $mime,
            'size' => $file['size'],
        ], 201);
    }
}
