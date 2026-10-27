<?php
// backend/helpers/response.php

class Response {
    public static function initCors(): void {
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Device-Id, X-Auth-Token");
        header("Content-Type: application/json; charset=UTF-8");

        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit;
        }
    }

    public static function json(bool $success, string $message = '', $data = null, int $statusCode = 200): void {
        self::initCors();
        http_response_code($statusCode);
        
        $response = [
            'success' => $success,
            'message' => $message,
            'server_time' => date('Y-m-d H:i:s'),
            'timestamp' => time()
        ];

        if ($data !== null) {
            $response['data'] = $data;
        }

        echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }

    public static function error(string $message, int $statusCode = 400, $data = null): void {
        self::json(false, $message, $data, $statusCode);
    }

    public static function success(string $message, $data = null, int $statusCode = 200): void {
        self::json(true, $message, $data, $statusCode);
    }

    public static function getJsonInput(): array {
        $raw = file_get_contents('php://input');
        if (empty($raw)) {
            return $_POST;
        }
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : [];
    }
}
