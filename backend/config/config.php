<?php
declare(strict_types=1);

// Set Business Timezone to Addis Ababa (UTC+3)
date_default_timezone_set('Africa/Addis_Ababa');

return [
    'app' => [
        'name' => 'Afro-Barber API',
        'env' => getenv('APP_ENV') ?: 'development',
        'debug' => (getenv('APP_ENV') ?: 'development') === 'development',
        'base_url' => getenv('BASE_URL') ?: 'http://127.0.0.1/afro_barber_api/public',
        'timezone' => 'Africa/Addis_Ababa',
    ],
    'db' => [
        'host' => getenv('DB_HOST') ?: '127.0.0.1',
        'port' => getenv('DB_PORT') ?: '3306',
        'database' => getenv('DB_DATABASE') ?: 'Afro_Barber',
        'username' => getenv('DB_USERNAME') ?: 'root',
        'password' => getenv('DB_PASSWORD') !== false ? getenv('DB_PASSWORD') : '',
        'charset' => 'utf8mb4',
    ],
    'jwt' => [
        'secret' => getenv('JWT_SECRET') ?: 'afro_barber_luxury_secret_key_2026_ethiopia_bole',
        'algorithm' => 'HS256',
        'expiry_seconds' => 86400 * 30, // 30 days session
    ],
    'uploads' => [
        'dir' => dirname(__DIR__) . '/uploads',
        'max_image_size' => 5 * 1024 * 1024, // 5MB
        'max_video_size' => 50 * 1024 * 1024, // 50MB
        'allowed_image_mimes' => ['image/jpeg', 'image/png', 'image/webp'],
        'allowed_video_mimes' => ['video/mp4', 'video/webm', 'video/quicktime'],
    ],
    'cors' => [
        'allowed_origins' => [
            '*', // Permissive for local mobile app development
        ],
        'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
    ],
];
