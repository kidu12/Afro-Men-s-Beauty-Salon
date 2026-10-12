<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/controllers/AuthController.php';
require_once dirname(__DIR__) . '/controllers/StyleController.php';
require_once dirname(__DIR__) . '/controllers/ServiceController.php';
require_once dirname(__DIR__) . '/controllers/BarberController.php';
require_once dirname(__DIR__) . '/controllers/AppointmentController.php';
require_once dirname(__DIR__) . '/controllers/ReviewController.php';
require_once dirname(__DIR__) . '/controllers/NotificationController.php';
require_once dirname(__DIR__) . '/controllers/AdminController.php';
require_once dirname(__DIR__) . '/controllers/MediaController.php';
require_once dirname(__DIR__) . '/middleware/role.php';
require_once dirname(__DIR__) . '/utils/Response.php';

class Router {
    public static function dispatch(string $method, string $uri): void {
        // Strip query string and trim base path
        $path = parse_url($uri, PHP_URL_PATH) ?? '/';
        
        // Normalize subfolder path if running inside XAMPP e.g. /afro_barber_api/public/api/...
        if (strpos($path, '/api') !== false) {
            $path = substr($path, strpos($path, '/api'));
        }

        $path = rtrim($path, '/');
        if (empty($path)) $path = '/api';

        // 1. Health check (Real PDO query SELECT DATABASE())
        if ($method === 'GET' && ($path === '/api/health' || $path === '/api')) {
            try {
                $pdo = Database::getConnection();
                $dbName = $pdo->query("SELECT DATABASE()")->fetchColumn() ?: 'Afro_Barber';
                Response::json([
                    'status' => 'ok',
                    'database' => 'connected',
                    'database_name' => $dbName,
                ]);
            } catch (Throwable $e) {
                Response::error('Database unreachable', 500, $e->getMessage());
            }
        }

        // 2. Database Debug Endpoint (Development only!)
        if ($method === 'GET' && $path === '/api/debug/database') {
            $config = require dirname(__DIR__) . '/config/config.php';
            if (($config['app']['env'] ?? '') !== 'development') {
                Response::error('Debug endpoint disabled in non-development environments.', 403);
            }

            try {
                $pdo = Database::getConnection();
                $dbName = $pdo->query("SELECT DATABASE()")->fetchColumn() ?: 'Afro_Barber';
                $serverVersion = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);
                Response::json([
                    'database' => $dbName,
                    'connected' => true,
                    'server_time' => date('Y-m-d H:i:s'),
                    'timezone' => date_default_timezone_get(),
                    'database_server_version' => $serverVersion,
                ]);
            } catch (Throwable $e) {
                Response::error('Database unreachable', 500, $e->getMessage());
            }
        }

        // 2b. POST Echo Diagnostic Endpoint (Development only!)
        if ($method === 'POST' && $path === '/api/debug/echo') {
            $raw = file_get_contents('php://input');
            $data = json_decode($raw, true) ?? [];
            Response::json([
                'success' => true,
                'echo' => $data,
                'method' => 'POST',
                'content_type' => $_SERVER['CONTENT_TYPE'] ?? '',
                'timestamp' => date('Y-m-d H:i:s'),
            ]);
        }

        // 3. Authentication
        if ($method === 'POST' && $path === '/api/auth/register') {
            AuthController::register();
        }
        if ($method === 'POST' && $path === '/api/auth/login') {
            AuthController::login();
        }
        if ($method === 'GET' && ($path === '/api/profile' || $path === '/api/auth/me')) {
            AuthController::getProfile();
        }

        // 4. Styles (Customer & Public)
        if ($method === 'GET' && $path === '/api/styles') {
            StyleController::getStyles();
        }
        if ($method === 'GET' && preg_match('#^/api/styles/([^/]+)$#', $path, $m)) {
            StyleController::getStyleById($m[1]);
        }

        // 5. Services (Customer & Public)
        if ($method === 'GET' && $path === '/api/services/categories') {
            ServiceController::getCategories();
        }
        if ($method === 'GET' && $path === '/api/services') {
            ServiceController::getServices();
        }
        if ($method === 'GET' && preg_match('#^/api/services/([^/]+)$#', $path, $m)) {
            ServiceController::getServiceById($m[1]);
        }

        // 6. Barbers (Customer & Public)
        if ($method === 'GET' && $path === '/api/barbers') {
            BarberController::getBarbers();
        }
        if ($method === 'GET' && preg_match('#^/api/barbers/([^/]+)$#', $path, $m)) {
            BarberController::getBarberById($m[1]);
        }

        // 7. Barber Portal Protected Endpoints (Requires Barber/Admin role)
        if ($method === 'GET' && ($path === '/api/barber/appointments/today' || $path === '/api/barber/appointments')) {
            RoleMiddleware::requireBarber();
            BarberController::getTodayAppointments();
        }
        if ($method === 'POST' && preg_match('#^/api/barber/appointments/([^/]+)/check-in$#', $path, $m)) {
            RoleMiddleware::requireBarber();
            AppointmentController::updateStatus($m[1], 'checked_in');
        }
        if ($method === 'POST' && preg_match('#^/api/barber/appointments/([^/]+)/start$#', $path, $m)) {
            RoleMiddleware::requireBarber();
            AppointmentController::updateStatus($m[1], 'in_progress');
        }
        if ($method === 'POST' && preg_match('#^/api/barber/appointments/([^/]+)/complete$#', $path, $m)) {
            RoleMiddleware::requireBarber();
            AppointmentController::updateStatus($m[1], 'completed');
        }
        if ($method === 'POST' && preg_match('#^/api/barber/appointments/([^/]+)/no-show$#', $path, $m)) {
            RoleMiddleware::requireBarber();
            AppointmentController::updateStatus($m[1], 'no_show');
        }
        if ($method === 'POST' && preg_match('#^/api/barber/appointments/([^/]+)/status$#', $path, $m)) {
            RoleMiddleware::requireBarber();
            $data = json_decode(file_get_contents('php://input'), true) ?? [];
            AppointmentController::updateStatus($m[1], $data['status'] ?? 'completed');
        }

        // 8. Availability & Appointments (Customer & Authenticated Users)
        if ($method === 'GET' && $path === '/api/availability') {
            AppointmentController::getAvailability();
        }
        if ($method === 'GET' && ($path === '/api/appointments' || $path === '/api/appointments/my')) {
            AppointmentController::list();
        }
        if ($method === 'POST' && $path === '/api/appointments') {
            AppointmentController::create();
        }
        if ($method === 'GET' && preg_match('#^/api/appointments/([^/]+)$#', $path, $m)) {
            AppointmentController::getById($m[1]);
        }
        if ($method === 'POST' && preg_match('#^/api/appointments/([^/]+)/cancel$#', $path, $m)) {
            AppointmentController::cancel($m[1]);
        }
        if ($method === 'POST' && preg_match('#^/api/appointments/([^/]+)/status$#', $path, $m)) {
            $data = json_decode(file_get_contents('php://input'), true) ?? [];
            AppointmentController::updateStatus($m[1], $data['status'] ?? 'completed');
        }

        // 9. Reviews
        if ($method === 'GET' && $path === '/api/reviews') {
            ReviewController::getReviews();
        }
        if ($method === 'POST' && $path === '/api/reviews') {
            ReviewController::create();
        }

        // 10. Notifications
        if ($method === 'GET' && $path === '/api/notifications') {
            NotificationController::getNotifications();
        }
        if ($method === 'POST' && preg_match('#^/api/notifications/([^/]+)/read$#', $path, $m)) {
            NotificationController::markAsRead($m[1]);
        }
        if ($method === 'POST' && $path === '/api/notifications/read-all') {
            NotificationController::markAllAsRead();
        }

        // 11. Admin Endpoints (Strictly require Admin role)
        if ($method === 'GET' && $path === '/api/admin/dashboard') {
            RoleMiddleware::requireAdmin();
            AdminController::getDashboard();
        }
        if ($method === 'POST' && $path === '/api/admin/services') {
            RoleMiddleware::requireAdmin();
            AdminController::saveService();
        }
        if ($method === 'DELETE' && preg_match('#^/api/admin/services/([^/]+)$#', $path, $m)) {
            RoleMiddleware::requireAdmin();
            AdminController::deleteService($m[1]);
        }
        if ($method === 'POST' && $path === '/api/admin/barbers') {
            RoleMiddleware::requireAdmin();
            AdminController::saveBarber();
        }
        if ($method === 'POST' && $path === '/api/admin/styles') {
            RoleMiddleware::requireAdmin();
            AdminController::saveStyle();
        }
        if ($method === 'POST' && $path === '/api/admin/media') {
            RoleMiddleware::requireAdmin();
            MediaController::upload();
        }
        if ($method === 'GET' && preg_match('#^/api/admin/barbers/([^/]+)/days-off$#', $path, $m)) {
            RoleMiddleware::requireAdmin();
            AdminController::getBarberDaysOff($m[1]);
        }
        if ($method === 'POST' && preg_match('#^/api/admin/barbers/([^/]+)/days-off$#', $path, $m)) {
            RoleMiddleware::requireAdmin();
            AdminController::addBarberDayOff($m[1]);
        }
        if ($method === 'DELETE' && preg_match('#^/api/admin/barbers/([^/]+)/days-off/([^/]+)$#', $path, $m)) {
            RoleMiddleware::requireAdmin();
            AdminController::deleteBarberDayOff($m[1], $m[2]);
        }

        // 404 Route Not Found
        Response::error("Endpoint not found: $method $path", 404);
    }
}
