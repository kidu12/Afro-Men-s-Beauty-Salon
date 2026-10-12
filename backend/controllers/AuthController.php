<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/Response.php';
require_once dirname(__DIR__) . '/utils/JwtService.php';
require_once dirname(__DIR__) . '/utils/ReferenceGenerator.php';
require_once dirname(__DIR__) . '/middleware/auth.php';

class AuthController {
    public static function register(): void {
        $data = json_decode(file_get_contents('php://input'), true) ?? [];

        $email = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';
        $fullName = trim($data['full_name'] ?? '');
        $phone = trim($data['phone'] ?? '');

        if (empty($email) || empty($password) || empty($fullName)) {
            Response::error('Full name, email, and password are required.');
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Response::error('Invalid email format.');
        }

        $pdo = Database::getConnection();

        // Check duplicate
        $stmt = $pdo->prepare("SELECT id FROM profiles WHERE email = :email");
        $stmt->execute(['email' => $email]);
        if ($stmt->fetch()) {
            Response::error('An account with this email already exists.', 409);
        }

        $userId = ReferenceGenerator::uuid();
        $passwordHash = password_hash($password, PASSWORD_BCRYPT);

        $stmt = $pdo->prepare("
            INSERT INTO profiles (id, email, password_hash, full_name, phone, role, is_active, created_at)
            VALUES (:id, :email, :password_hash, :full_name, :phone, 'customer', 1, NOW())
        ");
        $stmt->execute([
            'id' => $userId,
            'email' => $email,
            'password_hash' => $passwordHash,
            'full_name' => $fullName,
            'phone' => $phone,
        ]);

        $token = JwtService::generateToken([
            'sub' => $userId,
            'email' => $email,
            'role' => 'customer',
            'full_name' => $fullName,
        ]);

        Response::json([
            'token' => $token,
            'user' => [
                'id' => $userId,
                'email' => $email,
                'full_name' => $fullName,
                'phone' => $phone,
                'avatar_url' => null,
                'role' => 'customer',
            ],
        ], 201);
    }

    public static function login(): void {
        $rawInput = file_get_contents('php://input');
        $data = json_decode($rawInput, true) ?? [];

        $identifier = trim($data['email'] ?? $data['identifier'] ?? $data['phone'] ?? '');
        $password = $data['password'] ?? '';

        error_log("[AUTH DEBUG] Login request received");
        error_log("[AUTH DEBUG] Method: " . ($_SERVER['REQUEST_METHOD'] ?? 'UNKNOWN'));
        error_log("[AUTH DEBUG] Content-Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'UNKNOWN'));
        error_log("[AUTH DEBUG] Email received: " . ($identifier !== '' ? $identifier : '(empty)'));

        if (empty($identifier) || empty($password)) {
            error_log("[AUTH DEBUG] Response status: 400 (Missing identifier or password)");
            Response::error('Email or phone and password are required.');
        }

        $pdo = Database::getConnection();
        $dbName = $pdo->query("SELECT DATABASE()")->fetchColumn();
        error_log("[AUTH DEBUG] Database: " . $dbName);

        $stmt = $pdo->prepare("SELECT id, email, password_hash, full_name, phone, avatar_url, role, is_active FROM profiles WHERE email = :id_email OR phone = :id_phone");
        $stmt->execute(['id_email' => $identifier, 'id_phone' => $identifier]);
        $user = $stmt->fetch();

        error_log("[AUTH DEBUG] User found: " . ($user ? "YES (ID: " . $user['id'] . ", Role: " . $user['role'] . ")" : "NO"));

        $valid = false;
        if ($user) {
            if (password_verify($password, $user['password_hash'])) {
                $valid = true;
            }
        }

        error_log("[AUTH DEBUG] Password verification: " . ($valid ? "SUCCESS" : "FAILED"));

        if (!$user || !$valid || !$user['is_active']) {
            error_log("[AUTH DEBUG] Response status: 401 (Invalid credentials)");
            Response::error('Invalid email or password.', 401);
        }

        $token = JwtService::generateToken([
            'sub' => $user['id'],
            'email' => $user['email'],
            'role' => $user['role'],
            'full_name' => $user['full_name'],
        ]);

        error_log("[AUTH DEBUG] JWT generation: SUCCESS");
        error_log("[AUTH DEBUG] Response status: 200");

        Response::json([
            'token' => $token,
            'user' => [
                'id' => $user['id'],
                'email' => $user['email'],
                'full_name' => $user['full_name'],
                'phone' => $user['phone'],
                'avatar_url' => $user['avatar_url'],
                'role' => $user['role'],
            ],
        ]);
    }

    public static function getProfile(): void {
        $auth = AuthMiddleware::authenticate();
        $pdo = Database::getConnection();

        $stmt = $pdo->prepare("SELECT id, email, full_name, phone, avatar_url, role, created_at FROM profiles WHERE id = :id");
        $stmt->execute(['id' => $auth['sub']]);
        $user = $stmt->fetch();

        if (!$user) {
            Response::error('User not found.', 404);
        }

        Response::json($user);
    }
}
