<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

class AvailabilityService {
    /**
     * Calculates time slots for a given barber, service, and date
     */
    public static function getAvailableSlots(string $barberId, string $serviceId, string $dateIso): array {
        $pdo = Database::getConnection();

        // 1. Fetch Service Duration
        $stmt = $pdo->prepare("SELECT duration_minutes, is_active FROM services WHERE id = :id AND deleted_at IS NULL");
        $stmt->execute(['id' => $serviceId]);
        $service = $stmt->fetch();

        if (!$service || $service['duration_minutes'] === null || (int)$service['duration_minutes'] <= 0) {
            return [];
        }

        $durationMinutes = (int)$service['duration_minutes'];

        // 2. Fetch Barber & Branch
        $stmt = $pdo->prepare("SELECT branch_id, is_active FROM barbers WHERE id = :id");
        $stmt->execute(['id' => $barberId]);
        $barber = $stmt->fetch();
        if (!$barber || !$barber['is_active']) {
            return [];
        }

        $branchId = $barber['branch_id'] ?? 'branch-bole-main';
        $dayOfWeek = (int)date('w', strtotime($dateIso)); // 0=Sun, 1=Mon ... 6=Sat

        // 3. Check Special Closures
        $stmt = $pdo->prepare("SELECT id FROM special_closures WHERE branch_id = :branch_id AND closure_date = :date");
        $stmt->execute(['branch_id' => $branchId, 'date' => $dateIso]);
        if ($stmt->fetch()) {
            return []; // Shop closed
        }

        // 4. Check Barber Days Off
        $stmt = $pdo->prepare("SELECT id FROM barber_days_off WHERE barber_id = :barber_id AND off_date = :date");
        $stmt->execute(['barber_id' => $barberId, 'date' => $dateIso]);
        if ($stmt->fetch()) {
            return []; // Barber day off
        }

        // 5. Check Operating Hours
        $stmt = $pdo->prepare("SELECT open_time, close_time, is_closed FROM business_hours WHERE branch_id = :branch_id AND day_of_week = :day");
        $stmt->execute(['branch_id' => $branchId, 'day' => $dayOfWeek]);
        $hours = $stmt->fetch();
        if (!$hours || $hours['is_closed']) {
            return [];
        }

        $openTime = $hours['open_time'];
        $closeTime = $hours['close_time'];

        // 6. Check Barber Schedule
        $stmt = $pdo->prepare("SELECT start_time, end_time, is_working FROM barber_schedules WHERE barber_id = :barber_id AND day_of_week = :day");
        $stmt->execute(['barber_id' => $barberId, 'day' => $dayOfWeek]);
        $schedule = $stmt->fetch();
        if (!$schedule || !$schedule['is_working']) {
            return [];
        }

        $workStart = max($openTime, $schedule['start_time']);
        $workEnd = min($closeTime, $schedule['end_time']);

        // 7. Fetch Existing Active Appointments for that day
        $stmt = $pdo->prepare("
            SELECT start_time, end_time 
            FROM appointments 
            WHERE barber_id = :barber_id 
              AND appointment_date = :date 
              AND status NOT IN ('cancelled', 'no_show')
        ");
        $stmt->execute(['barber_id' => $barberId, 'date' => $dateIso]);
        $existing = $stmt->fetchAll();

        // 8. Generate 30-Minute Interval Slots
        $slots = [];
        $currentSeconds = strtotime("$dateIso $workStart");
        $endLimitSeconds = strtotime("$dateIso $workEnd");

        while ($currentSeconds + ($durationMinutes * 60) <= $endLimitSeconds) {
            $slotStart = date('H:i:s', $currentSeconds);
            $slotEnd = date('H:i:s', $currentSeconds + ($durationMinutes * 60));

            // Check overlap
            $isAvailable = true;
            $reason = null;

            foreach ($existing as $apt) {
                if ($slotStart < $apt['end_time'] && $slotEnd > $apt['start_time']) {
                    $isAvailable = false;
                    $reason = "Slot is already booked";
                    break;
                }
            }

            $displayLabel = date('g:i A', $currentSeconds);

            $slots[] = [
                'time_string' => $slotStart,
                'display_label' => $displayLabel,
                'is_available' => $isAvailable,
                'reason_unavailable' => $reason,
            ];

            $currentSeconds += 30 * 60; // 30-minute interval
        }

        return $slots;
    }
}
