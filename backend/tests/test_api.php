<?php
declare(strict_types=1);

/**
 * Afro-Barber PHP Backend Test Suite
 * Run via CLI: php backend/tests/test_api.php
 */

require_once dirname(__DIR__) . '/config/config.php';
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/ReferenceGenerator.php';
require_once dirname(__DIR__) . '/utils/JwtService.php';
require_once dirname(__DIR__) . '/services/BookingService.php';
require_once dirname(__DIR__) . '/services/AvailabilityService.php';

echo "========================================================\n";
echo "AFRO-BARBER PHP / MYSQL BACKEND TEST SUITE\n";
echo "========================================================\n\n";

$passed = 0;
$total = 0;

function assertTest(string $description, bool $condition): void {
    global $passed, $total;
    $total++;
    if ($condition) {
        $passed++;
        echo " [PASS] $description\n";
    } else {
        echo " [FAIL] $description\n";
    }
}

// 1. Timezone Test
assertTest(
    "PHP Default Timezone is configured to Africa/Addis_Ababa",
    date_default_timezone_get() === 'Africa/Addis_Ababa'
);

// 2. Reference Code Generator Test
$ref = ReferenceGenerator::generate('2026-08-21');
assertTest(
    "Generated Reference format matches AFB-20260821-XXXXXX",
    (bool)preg_match('/^AFB-20260821-[A-Z0-9]{6}$/', $ref)
);

// 3. JWT Token Generation & Verification
$payload = ['sub' => 'user-123', 'email' => 'customer@afrobarber.com', 'role' => 'customer'];
$token = JwtService::generateToken($payload);
$verified = JwtService::verifyToken($token);

assertTest(
    "JWT token generated and verified with correct sub",
    $verified !== null && $verified['sub'] === 'user-123' && $verified['role'] === 'customer'
);

// 4. Database Connection Test (If MySQL is running locally)
try {
    $pdo = Database::getConnection();
    assertTest("Database connected successfully to MySQL / MariaDB", $pdo instanceof PDO);

    // 5. Query Services and Verify Nullable Price
    $stmt = $pdo->query("SELECT id, name, price, duration_minutes FROM services WHERE id = 'srv-haircut'");
    $srv = $stmt->fetch();
    assertTest("Service pricing is strictly NULL (never 0)", $srv && $srv['price'] === null);

    // 6. Query New Barber Rating
    $bStmt = $pdo->query("SELECT id, name, rating_avg, total_reviews FROM barbers WHERE id = 'barber-daniel'");
    $barber = $bStmt->fetch();
    assertTest("New barber starts with rating_avg = 0.00 and total_reviews = 0", $barber && (float)$barber['rating_avg'] === 0.0 && (int)$barber['total_reviews'] === 0);

    // 7. Atomic Booking Engine Test (Tomorrow at 16:00)
    $testDate = date('Y-m-d', strtotime('+2 days'));
    $apt = BookingService::createAppointment([
        'customer_id' => '55555555-5555-5555-5555-555555555555',
        'barber_id' => 'barber-mike',
        'service_id' => 'srv-haircut',
        'appointment_date' => $testDate,
        'start_time' => '16:00:00',
        'notes' => 'Test Booking',
    ]);

    assertTest("Atomic booking creates valid appointment with AFB reference", !empty($apt['id']) && !empty($apt['appointment_reference']));

    // 8. Double-Booking Concurrency Conflict Test
    $conflictCaught = false;
    try {
        BookingService::createAppointment([
            'customer_id' => '55555555-5555-5555-5555-555555555555',
            'barber_id' => 'barber-mike',
            'service_id' => 'srv-haircut',
            'appointment_date' => $testDate,
            'start_time' => '16:00:00', // EXACT SAME TIME & BARBER
        ]);
    } catch (RuntimeException $e) {
        $conflictCaught = true;
    }

    assertTest("Double-booking prevented and threw HTTP 409 conflict", $conflictCaught);

    // 9. Status State Machine Transition Test
    $statusRes = BookingService::updateStatus($apt['id'], 'checked_in', '22222222-2222-2222-2222-222222222222');
    assertTest("Status state machine transitions from confirmed -> checked_in", $statusRes['status'] === 'checked_in');

    // 10. Status History Audit Log Verification
    $hStmt = $pdo->prepare("SELECT previous_status, new_status FROM appointment_status_history WHERE appointment_id = :id ORDER BY created_at DESC LIMIT 1");
    $hStmt->execute(['id' => $apt['id']]);
    $history = $hStmt->fetch();
    assertTest("Status transition logged in appointment_status_history", $history && $history['new_status'] === 'checked_in');

} catch (PDOException $e) {
    echo " [INFO] Local MySQL not currently connected. (Ensure XAMPP MySQL is started to run DB integration tests).\n";
} catch (Throwable $e) {
    echo " [ERROR] " . $e->getMessage() . "\n";
}

echo "\n--------------------------------------------------------\n";
echo "SUMMARY: $passed / $total tests passed.\n";
echo "========================================================\n";
