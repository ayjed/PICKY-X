<?php
// backend/helpers/auth.php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/response.php';

class AuthHelper {
    public static function generateToken(int $userId, string $deviceId): string {
        return hash('sha256', $userId . '_' . $deviceId . '_' . time() . '_' . API_SECRET_KEY);
    }

    public static function getAuthenticatedUser(): ?array {
        $headers = getallheaders();
        $token = null;
        $deviceId = null;

        if (isset($headers['X-Auth-Token'])) {
            $token = trim($headers['X-Auth-Token']);
        } elseif (isset($headers['Authorization'])) {
            $token = trim(str_replace('Bearer ', '', $headers['Authorization']));
        }

        if (isset($headers['X-Device-Id'])) {
            $deviceId = trim($headers['X-Device-Id']);
        }

        // Also check GET/POST fallback
        if (!$token && isset($_REQUEST['auth_token'])) {
            $token = trim($_REQUEST['auth_token']);
        }
        if (!$deviceId && isset($_REQUEST['device_id'])) {
            $deviceId = trim($_REQUEST['device_id']);
        }

        if (!$token && !$deviceId) {
            return null;
        }

        $pdo = Database::getConnection();
        if ($token) {
            $stmt = $pdo->prepare("SELECT * FROM users WHERE auth_token = ? LIMIT 1");
            $stmt->execute([$token]);
            $user = $stmt->fetch();
            if ($user) return $user;
        }

        if ($deviceId) {
            $stmt = $pdo->prepare("SELECT * FROM users WHERE device_id = ? LIMIT 1");
            $stmt->execute([$deviceId]);
            $user = $stmt->fetch();
            if ($user) return $user;
        }

        return null;
    }

    public static function requireAuth(): array {
        $user = self::getAuthenticatedUser();
        if (!$user) {
            Response::error('Unauthorized. Valid device_id or auth_token required.', 401);
        }
        return $user;
    }
}
