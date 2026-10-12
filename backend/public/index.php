<?php
declare(strict_types=1);

// Handle errors gracefully in production vs dev
ini_set('display_errors', '0');
error_reporting(E_ALL);

require_once dirname(__DIR__) . '/middleware/cors.php';
require_once dirname(__DIR__) . '/routes/api.php';

// Handle CORS Pre-flight and headers
CorsMiddleware::handle();

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri = $_SERVER['REQUEST_URI'] ?? '/';

Router::dispatch($method, $uri);
