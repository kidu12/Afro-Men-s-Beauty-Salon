<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/utils/JwtService.php';
require_once dirname(__DIR__) . '/utils/Response.php';

class AuthMiddleware {
    public static function authenticate(): array {
        $authHeader = '';

        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        }

        if (empty($authHeader) && function_exists('getallheaders')) {
            $headers = getallheaders();
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        }

        if (empty($authHeader)) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'] 
                ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] 
                ?? $_SERVER['Authorization'] 
                ?? getenv('HTTP_AUTHORIZATION')
                ?? '';
        }

        if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            Response::error('Authentication required. Missing Bearer token.', 401);
        }

        $token = trim($matches[1]);
        $payload = JwtService::verifyToken($token);

        if (!$payload) {
            Response::error('Invalid or expired authentication token.', 401);
        }

        return $payload;
    }
}
