<?php
declare(strict_types=1);

class Database {
    private static ?PDO $pdo = null;

    public static function getConnection(): PDO {
        if (self::$pdo !== null) {
            return self::$pdo;
        }

        $config = require __DIR__ . '/config.php';
        $db = $config['db'];

        $dsn = "mysql:host={$db['host']};port={$db['port']};dbname={$db['database']};charset={$db['charset']}";

        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES '{$db['charset']}'",
        ];

        try {
            self::$pdo = new PDO($dsn, $db['username'], $db['password'], $options);
            return self::$pdo;
        } catch (PDOException $e) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Database connection failed. Please ensure XAMPP MySQL is running and Afro_Barber database is imported.',
                'details' => $config['app']['debug'] ? $e->getMessage() : null,
            ]);
            exit;
        }
    }
}
