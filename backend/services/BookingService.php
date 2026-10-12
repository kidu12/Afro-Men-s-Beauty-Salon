<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/utils/ReferenceGenerator.php';

class BookingService {
    /**
     * Allowed State Machine Transitions
     */
    private const ALLOWED_TRANSITIONS = [
        'pending' => ['confirmed', 'cancelled'],
        'confirmed' => ['checked_in', 'cancelled', 'no_show', 'completed', 'in_progress'],
        'checked_in' => ['in_progress', 'cancelled'],
        'in_progress' => ['completed', 'cancelled'],
        'completed' => [], // Terminal state
        'cancelled' => [], // Terminal state
        'no_show' => [],   // Terminal state
    ];

    /**
     * Creates an appointment atomically with row-locking concurrency protection
     */
    public static function createAppointment(array $data): array {
        $pdo = Database::getConnection();
        $pdo->beginTransaction();

        try {
            $customerId = $data['customer_id'];
            $barberId = $data['barber_id'];
            $serviceId = $data['service_id'];
            $hairstyleId = $data['hairstyle_id'] ?? null;
            $appointmentDate = $data['appointment_date']; // "YYYY-MM-DD"
            $startTime = $data['start_time']; // "HH:MM:SS" or "HH:MM"
            $notes = $data['notes'] ?? null;

            if (strlen($startTime) === 5) {
                $startTime .= ':00';
            }

            // 1. Validate Customer
            $stmt = $pdo->prepare("SELECT id, full_name, phone, avatar_url FROM profiles WHERE id = :id AND is_active = 1");
            $stmt->execute(['id' => $customerId]);
            $customer = $stmt->fetch();
            if (!$customer) {
                throw new InvalidArgumentException("Customer account not found or inactive.");
            }

            // 2. Validate Service & Duration
            $stmt = $pdo->prepare("SELECT id, name, price, duration_minutes, is_active FROM services WHERE id = :id AND deleted_at IS NULL");
            $stmt->execute(['id' => $serviceId]);
            $service = $stmt->fetch();
            if (!$service || !$service['is_active']) {
                throw new InvalidArgumentException("Service not found or inactive.");
            }

            if ($service['duration_minutes'] === null || (int)$service['duration_minutes'] <= 0) {
                throw new InvalidArgumentException("This service cannot be booked yet because its duration is not configured.");
            }

            $durationMinutes = (int)$service['duration_minutes'];

            // 3. Validate Barber
            $stmt = $pdo->prepare("SELECT b.id, b.name, b.branch_id, b.is_active, p.phone FROM barbers b JOIN profiles p ON b.profile_id = p.id WHERE b.id = :id");
            $stmt->execute(['id' => $barberId]);
            $barber = $stmt->fetch();
            if (!$barber || !$barber['is_active']) {
                throw new InvalidArgumentException("Barber not found or inactive.");
            }

            $branchId = $barber['branch_id'] ?? 'branch-bole-main';

            // 4. Calculate End Time
            $startTimestamp = strtotime("$appointmentDate $startTime");
            $endTimestamp = $startTimestamp + ($durationMinutes * 60);
            $endTime = date('H:i:s', $endTimestamp);

            // 5. Validate Business Hours for Day of Week
            $dayOfWeek = (int)date('w', strtotime($appointmentDate)); // 0=Sun, 1=Mon ... 6=Sat
            $stmt = $pdo->prepare("SELECT open_time, close_time, is_closed FROM business_hours WHERE branch_id = :branch_id AND day_of_week = :day");
            $stmt->execute(['branch_id' => $branchId, 'day' => $dayOfWeek]);
            $hours = $stmt->fetch();

            if ($hours && ($hours['is_closed'] || $startTime < $hours['open_time'] || $endTime > $hours['close_time'])) {
                throw new InvalidArgumentException("Selected time is outside shop operating hours.");
            }

            // 6. Validate Barber Schedule
            $stmt = $pdo->prepare("SELECT start_time, end_time, is_working FROM barber_schedules WHERE barber_id = :barber_id AND day_of_week = :day");
            $stmt->execute(['barber_id' => $barberId, 'day' => $dayOfWeek]);
            $schedule = $stmt->fetch();

            if ($schedule && (!$schedule['is_working'] || $startTime < $schedule['start_time'] || $endTime > $schedule['end_time'])) {
                throw new InvalidArgumentException("The barber is not scheduled to work at this time.");
            }

            // 7. Validate Barber Days Off
            $stmt = $pdo->prepare("SELECT id, reason FROM barber_days_off WHERE barber_id = :barber_id AND off_date = :date");
            $stmt->execute(['barber_id' => $barberId, 'date' => $appointmentDate]);
            if ($stmt->fetch()) {
                throw new InvalidArgumentException("The barber is taking a day off on this date.");
            }

            // 8. Validate Special Closures
            $stmt = $pdo->prepare("SELECT id, reason FROM special_closures WHERE branch_id = :branch_id AND closure_date = :date");
            $stmt->execute(['branch_id' => $branchId, 'date' => $appointmentDate]);
            if ($stmt->fetch()) {
                throw new InvalidArgumentException("The shop is closed on this date for a special event.");
            }

            // 9. CONCURRENCY LOCK & OVERLAP CHECK (Row-level lock FOR UPDATE)
            $stmt = $pdo->prepare("
                SELECT id, start_time, end_time, status 
                FROM appointments 
                WHERE barber_id = :barber_id 
                  AND appointment_date = :date 
                  AND status NOT IN ('cancelled', 'no_show')
                FOR UPDATE
            ");
            $stmt->execute(['barber_id' => $barberId, 'date' => $appointmentDate]);
            $existingAppointments = $stmt->fetchAll();

            foreach ($existingAppointments as $apt) {
                // Overlap formula: (StartA < EndB) and (EndA > StartB)
                if ($startTime < $apt['end_time'] && $endTime > $apt['start_time']) {
                    throw new RuntimeException("This time slot is no longer available. Please choose another time.", 409);
                }
            }

            // 10. Generate Server-Side Unique Reference & UUID
            $appointmentId = ReferenceGenerator::uuid();
            $reference = ReferenceGenerator::generate($appointmentDate);

            // 11. Insert Appointment with Snapshots
            $stmt = $pdo->prepare("
                INSERT INTO appointments (
                    id, appointment_reference, branch_id, customer_id, barber_id, service_id, hairstyle_id,
                    appointment_date, start_time, end_time, status, price_snapshot, duration_snapshot,
                    service_name_snapshot, notes, created_at
                ) VALUES (
                    :id, :reference, :branch_id, :customer_id, :barber_id, :service_id, :hairstyle_id,
                    :date, :start_time, :end_time, 'confirmed', :price_snapshot, :duration_snapshot,
                    :service_name, :notes, NOW()
                )
            ");

            $stmt->execute([
                'id' => $appointmentId,
                'reference' => $reference,
                'branch_id' => $branchId,
                'customer_id' => $customerId,
                'barber_id' => $barberId,
                'service_id' => $serviceId,
                'hairstyle_id' => $hairstyleId,
                'date' => $appointmentDate,
                'start_time' => $startTime,
                'end_time' => $endTime,
                'price_snapshot' => $service['price'], // May be null per master requirement!
                'duration_snapshot' => $durationMinutes,
                'service_name' => $service['name'],
                'notes' => $notes,
            ]);

            // 12. Insert Status History Audit Record
            $historyId = ReferenceGenerator::uuid();
            $stmt = $pdo->prepare("
                INSERT INTO appointment_status_history (id, appointment_id, previous_status, new_status, changed_by, reason, created_at)
                VALUES (:id, :apt_id, NULL, 'confirmed', :changed_by, 'Initial appointment created', NOW())
            ");
            $stmt->execute([
                'id' => $historyId,
                'apt_id' => $appointmentId,
                'changed_by' => $customerId,
            ]);

            // 13. Insert Notification
            $notifId = ReferenceGenerator::uuid();
            $displayDate = date('D, M j', strtotime($appointmentDate));
            $displayTime = date('g:i A', strtotime($startTime));
            $stmt = $pdo->prepare("
                INSERT INTO notifications (id, user_id, title, message, type, is_read, data, created_at)
                VALUES (:id, :user_id, :title, :message, 'appointment_confirmed', 0, :data, NOW())
            ");
            $stmt->execute([
                'id' => $notifId,
                'user_id' => $customerId,
                'title' => 'Appointment Confirmed! 💈',
                'message' => "Your appointment ($reference) for {$service['name']} with {$barber['name']} on $displayDate at $displayTime is confirmed.",
                'data' => json_encode(['appointment_id' => $appointmentId, 'reference' => $reference]),
            ]);

            // Commit Transaction
            $pdo->commit();

            return [
                'id' => $appointmentId,
                'appointment_reference' => $reference,
                'customer_id' => $customerId,
                'customer_name' => $customer['full_name'],
                'customer_phone' => $customer['phone'],
                'customer_avatar' => $customer['avatar_url'],
                'barber_id' => $barberId,
                'barber_name' => $barber['name'],
                'service_id' => $serviceId,
                'service_name' => $service['name'],
                'hairstyle_id' => $hairstyleId,
                'appointment_date' => $appointmentDate,
                'start_time' => $startTime,
                'end_time' => $endTime,
                'status' => 'confirmed',
                'price_snapshot' => $service['price'] !== null ? (float)$service['price'] : null,
                'duration_snapshot' => $durationMinutes,
                'service_name_snapshot' => $service['name'],
                'notes' => $notes,
                'created_at' => date('Y-m-d H:i:s'),
            ];
        } catch (Throwable $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    /**
     * Enforces the Appointment Status State Machine
     */
    public static function updateStatus(string $appointmentId, string $newStatus, string $actorId, ?string $reason = null): array {
        $pdo = Database::getConnection();
        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare("SELECT * FROM appointments WHERE id = :id FOR UPDATE");
            $stmt->execute(['id' => $appointmentId]);
            $apt = $stmt->fetch();

            if (!$apt) {
                throw new InvalidArgumentException("Appointment not found.");
            }

            $currentStatus = $apt['status'];

            // Check if transition is valid
            $allowed = self::ALLOWED_TRANSITIONS[$currentStatus] ?? [];
            if (!in_array($newStatus, $allowed, true)) {
                throw new InvalidArgumentException("Invalid status transition from '$currentStatus' to '$newStatus'.");
            }

            $completedAt = $newStatus === 'completed' ? date('Y-m-d H:i:s') : null;
            $cancelledAt = $newStatus === 'cancelled' ? date('Y-m-d H:i:s') : null;

            $stmt = $pdo->prepare("
                UPDATE appointments 
                SET status = :status, 
                    completed_at = COALESCE(:completed_at, completed_at), 
                    cancelled_at = COALESCE(:cancelled_at, cancelled_at),
                    updated_at = NOW()
                WHERE id = :id
            ");
            $stmt->execute([
                'status' => $newStatus,
                'completed_at' => $completedAt,
                'cancelled_at' => $cancelledAt,
                'id' => $appointmentId,
            ]);

            // Audit history
            $historyId = ReferenceGenerator::uuid();
            $stmt = $pdo->prepare("
                INSERT INTO appointment_status_history (id, appointment_id, previous_status, new_status, changed_by, reason, created_at)
                VALUES (:id, :apt_id, :prev, :new, :actor, :reason, NOW())
            ");
            $stmt->execute([
                'id' => $historyId,
                'apt_id' => $appointmentId,
                'prev' => $currentStatus,
                'new' => $newStatus,
                'actor' => $actorId,
                'reason' => $reason ?? "Status changed to $newStatus",
            ]);

            // Optional Notification for status change
            if ($newStatus === 'cancelled') {
                $notifId = ReferenceGenerator::uuid();
                $stmt = $pdo->prepare("
                    INSERT INTO notifications (id, user_id, title, message, type, is_read, data, created_at)
                    VALUES (:id, :user_id, :title, :msg, 'appointment_cancelled', 0, :data, NOW())
                ");
                $stmt->execute([
                    'id' => $notifId,
                    'user_id' => $apt['customer_id'],
                    'title' => 'Appointment Cancelled',
                    'msg' => "Your appointment ({$apt['appointment_reference']}) has been cancelled.",
                    'data' => json_encode(['appointment_id' => $appointmentId]),
                ]);
            }

            $pdo->commit();
            return ['success' => true, 'appointment_id' => $appointmentId, 'status' => $newStatus];
        } catch (Throwable $e) {
            $pdo->rollBack();
            throw $e;
        }
    }
}
