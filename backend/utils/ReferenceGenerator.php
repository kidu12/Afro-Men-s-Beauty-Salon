<?php
declare(strict_types=1);

class ReferenceGenerator {
    /**
     * Generates a unique, server-side appointment reference code
     * Example: AFB-20260821-X7K29P
     */
    public static function generate(string $dateIso = ''): string {
        if (empty($dateIso)) {
            $datePart = date('Ymd');
        } else {
            $datePart = date('Ymd', strtotime($dateIso));
        }

        $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        $length = 6;
        $suffix = '';
        $max = strlen($chars) - 1;

        for ($i = 0; $i < $length; $i++) {
            $suffix .= $chars[random_int(0, $max)];
        }

        return "AFB-{$datePart}-{$suffix}";
    }

    /**
     * Generates a UUID v4
     */
    public static function uuid(): string {
        $data = random_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40); // version 4
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80); // variant
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}
