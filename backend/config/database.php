<?php
// backend/config/database.php

require_once __DIR__ . '/constants.php';

class Database {
    private static ?PDO $instance = null;

    public static function getConnection(): PDO {
        if (self::$instance === null) {
            $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];

            try {
                self::$instance = new PDO($dsn, DB_USER, DB_PASS, $options);
            } catch (PDOException $e) {
                // If database doesn't exist yet, connect to server root without dbname
                if ($e->getCode() == 1049) {
                    $rootDsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";charset=utf8mb4";
                    self::$instance = new PDO($rootDsn, DB_USER, DB_PASS, $options);
                } else {
                    http_response_code(500);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Database Connection Failed: ' . $e->getMessage()
                    ]);
                    exit;
                }
            }
        }
        return self::$instance;
    }
}
