<?php
declare(strict_types=1);

/**
 * Afro-Barber Complete System & Security Verification Test Suite
 */

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/JwtService.php';

function runTestSuite() {
    $results = [];
    $pdo = Database::getConnection();

    echo "=== 1. DATABASE HEALTH & CONNECTION ===\n";
    $dbName = $pdo->query("SELECT DATABASE()")->fetchColumn();
    $results['db_name'] = $dbName;
    echo "Active MySQL Database: " . $dbName . "\n";
    $results['db_connected'] = ($dbName === 'afro_barber' || $dbName === 'Afro_Barber');
    echo "DB Connection Status: " . ($results['db_connected'] ? "PASS" : "FAIL") . "\n\n";

    echo "=== 2. AUTHENTICATION & LOGIN ROLE SEPARATION ===\n";
    $baseUrl = 'http://127.0.0.1/afro_barber_api/public';

    // 2.1 Customer Login
    $custLogin = makeHttpRequest('POST', "$baseUrl/api/auth/login", [
        'email' => 'customer@afrobarber.com',
        'password' => 'password123'
    ]);
    $results['cust_login'] = ($custLogin['success'] === true && $custLogin['data']['user']['role'] === 'customer');
    echo "Customer Login: " . ($results['cust_login'] ? "PASS" : "FAIL") . " (Role: " . ($custLogin['data']['user']['role'] ?? 'none') . ")\n";

    // 2.2 Barber Login
    $barberLogin = makeHttpRequest('POST', "$baseUrl/api/auth/login", [
        'email' => 'mike@afrobarber.com',
        'password' => 'password123'
    ]);
    $results['barber_login'] = ($barberLogin['success'] === true && $barberLogin['data']['user']['role'] === 'barber');
    echo "Barber Login: " . ($results['barber_login'] ? "PASS" : "FAIL") . " (Role: " . ($barberLogin['data']['user']['role'] ?? 'none') . ")\n";

    // 2.3 Admin Login
    $adminLogin = makeHttpRequest('POST', "$baseUrl/api/auth/login", [
        'email' => 'admin@afrobarber.com',
        'password' => 'password123'
    ]);
    $results['admin_login'] = ($adminLogin['success'] === true && $adminLogin['data']['user']['role'] === 'admin');
    echo "Admin Login: " . ($results['admin_login'] ? "PASS" : "FAIL") . " (Role: " . ($adminLogin['data']['user']['role'] ?? 'none') . ")\n\n";

    echo "=== 3. CUSTOMER REGISTRATION TO MYSQL ===\n";
    $randomEmail = 'user_' . time() . '_' . rand(100, 999) . '@afrobarber.com';
    $regRes = makeHttpRequest('POST', "$baseUrl/api/auth/register", [
        'full_name' => 'Kidus Registered User',
        'email' => $randomEmail,
        'phone' => '+251911998877',
        'password' => 'password123'
    ]);
    
    $results['reg_success'] = ($regRes['success'] === true && $regRes['data']['user']['role'] === 'customer');
    
    // Verify in MySQL
    $stmt = $pdo->prepare("SELECT id, full_name, email, role FROM profiles WHERE email = :email");
    $stmt->execute(['email' => $randomEmail]);
    $dbUser = $stmt->fetch();
    $results['reg_in_db'] = ($dbUser && $dbUser['role'] === 'customer');
    echo "Customer Registration: " . ($results['reg_success'] ? "PASS" : "FAIL") . "\n";
    echo "User physically in MySQL profiles: " . ($results['reg_in_db'] ? "PASS" : "FAIL") . " (Email: {$dbUser['email']}, Role: {$dbUser['role']})\n\n";

    echo "=== 4. APPOINTMENT TRANSACTION PERSISTENCE ===\n";
    $newUserToken = $regRes['data']['token'];
    $futureDate = date('Y-m-d', strtotime('+' . rand(2, 60) . ' days'));
    $hour = rand(9, 17);
    $time = sprintf('%02d:00:00', $hour);

    $aptRes = makeHttpRequest('POST', "$baseUrl/api/appointments", [
        'barber_id' => 'barber-mike',
        'service_id' => 'srv-haircut',
        'appointment_date' => $futureDate,
        'start_time' => $time,
        'notes' => 'E2E Verification Cut',
    ], $newUserToken);

    $results['apt_success'] = ($aptRes['success'] === true && !empty($aptRes['data']['id']));
    $aptId = $aptRes['data']['id'] ?? '';

    // Verify Appointments table
    $stmt = $pdo->prepare("SELECT id, appointment_reference, status, service_name_snapshot FROM appointments WHERE id = :id");
    $stmt->execute(['id' => $aptId]);
    $dbApt = $stmt->fetch();
    $results['apt_in_db'] = ($dbApt !== false);
    echo "Appointment API Confirmation: " . ($results['apt_success'] ? "PASS" : "FAIL") . " (Ref: " . ($aptRes['data']['appointment_reference'] ?? '') . ")\n";
    echo "Appointment in MySQL appointments table: " . ($results['apt_in_db'] ? "PASS" : "FAIL") . "\n";

    // Verify Status History table
    $stmt = $pdo->prepare("SELECT * FROM appointment_status_history WHERE appointment_id = :id");
    $stmt->execute(['id' => $aptId]);
    $dbHistory = $stmt->fetchAll();
    $results['history_in_db'] = (count($dbHistory) > 0);
    echo "Status history in appointment_status_history: " . ($results['history_in_db'] ? "PASS" : "FAIL") . " (" . count($dbHistory) . " records)\n";

    // Verify Notifications table
    $stmt = $pdo->prepare("SELECT * FROM notifications WHERE user_id = :uid ORDER BY created_at DESC LIMIT 1");
    $stmt->execute(['uid' => $dbUser['id']]);
    $dbNotif = $stmt->fetch();
    $results['notif_in_db'] = ($dbNotif !== false);
    echo "Notification in MySQL notifications: " . ($results['notif_in_db'] ? "PASS" : "FAIL") . " (Title: " . ($dbNotif['title'] ?? '') . ")\n\n";

    echo "=== 5. SECURITY & ROLE MIDDLEWARE TESTS ===\n";
    $custToken = $custLogin['data']['token'];
    $barberToken = $barberLogin['data']['token'];
    $adminToken = $adminLogin['data']['token'];

    // 5.1 Customer -> Admin endpoint (Expect HTTP 403)
    $cToA = makeHttpRequest('GET', "$baseUrl/api/admin/dashboard", null, $custToken);
    $results['cust_to_admin_blocked'] = ($cToA['http_code'] === 403);
    echo "Customer -> Admin endpoint rejected (403): " . ($results['cust_to_admin_blocked'] ? "PASS" : "FAIL") . " (Code: {$cToA['http_code']})\n";

    // 5.2 Barber -> Admin endpoint (Expect HTTP 403)
    $bToA = makeHttpRequest('GET', "$baseUrl/api/admin/dashboard", null, $barberToken);
    $results['barber_to_admin_blocked'] = ($bToA['http_code'] === 403);
    echo "Barber -> Admin endpoint rejected (403): " . ($results['barber_to_admin_blocked'] ? "PASS" : "FAIL") . " (Code: {$bToA['http_code']})\n";

    // 5.3 Admin -> Admin endpoint (Expect HTTP 200)
    $aToA = makeHttpRequest('GET', "$baseUrl/api/admin/dashboard", null, $adminToken);
    $results['admin_to_admin_allowed'] = ($aToA['http_code'] === 200 && $aToA['success'] === true);
    echo "Admin -> Admin endpoint allowed (200): " . ($results['admin_to_admin_allowed'] ? "PASS" : "FAIL") . " (Code: {$aToA['http_code']})\n";

    // 5.4 Barber -> Barber endpoint (Expect HTTP 200)
    $bToB = makeHttpRequest('GET', "$baseUrl/api/barber/appointments/today", null, $barberToken);
    $results['barber_to_barber_allowed'] = ($bToB['http_code'] === 200 && $bToB['success'] === true);
    echo "Barber -> Barber queue endpoint allowed (200): " . ($results['barber_to_barber_allowed'] ? "PASS" : "FAIL") . "\n";

    // 5.5 Invalid / Expired JWT (Expect HTTP 401)
    $invJwt = makeHttpRequest('GET', "$baseUrl/api/auth/me", null, "invalid.token.here");
    $results['invalid_jwt_blocked'] = ($invJwt['http_code'] === 401);
    echo "Invalid JWT rejected (401): " . ($results['invalid_jwt_blocked'] ? "PASS" : "FAIL") . "\n\n";

    echo "=== 6. HEALTH & DEBUG ENDPOINTS ===\n";
    $health = makeHttpRequest('GET', "$baseUrl/api/health");
    $results['health_ok'] = ($health['success'] === true && $health['data']['database'] === 'connected');
    echo "Health Endpoint (/api/health): " . ($results['health_ok'] ? "PASS" : "FAIL") . "\n";

    $debug = makeHttpRequest('GET', "$baseUrl/api/debug/database");
    $results['debug_ok'] = ($debug['success'] === true && $debug['data']['connected'] === true);
    echo "Debug Endpoint (/api/debug/database): " . ($results['debug_ok'] ? "PASS" : "FAIL") . " (DB Version: " . ($debug['data']['database_server_version'] ?? '') . ")\n\n";

    echo "========================================\n";
    $allPass = !in_array(false, $results, true);
    echo "FINAL TEST RESULT: " . ($allPass ? "ALL TESTS PASSED 100%" : "SOME TESTS FAILED") . "\n";
    echo "========================================\n";
}

function makeHttpRequest(string $method, string $url, ?array $body = null, ?string $token = null): array {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $headers = [
        'Accept: application/json',
        'Content-Type: application/json'
    ];

    if ($token) {
        $headers[] = "Authorization: Bearer $token";
    }

    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    if ($body !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
    }

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    $json = json_decode($response ?: '', true) ?? [];
    $json['http_code'] = $httpCode;
    return $json;
}

runTestSuite();
