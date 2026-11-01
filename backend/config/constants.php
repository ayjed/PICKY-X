<?php
// backend/config/constants.php

// Application Constants
define('APP_NAME', 'Picky X API');
define('APP_VERSION', '2.0.0');

// Load environment variables from backend/config/.env or backend/.env if present
$envLocations = [
    __DIR__ . '/.env',
    dirname(__DIR__) . '/.env',
];

foreach ($envLocations as $envPath) {
    if (file_exists($envPath) && is_readable($envPath)) {
        $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        if ($lines !== false) {
            foreach ($lines as $line) {
                $line = trim($line);
                if ($line === '' || str_starts_with($line, '#')) {
                    continue;
                }
                if (str_contains($line, '=')) {
                    [$k, $v] = explode('=', $line, 2);
                    $k = trim($k);
                    $v = trim($v);
                    // Strip optional wrapping quotes
                    if ((str_starts_with($v, '"') && str_ends_with($v, '"')) ||
                        (str_starts_with($v, "'") && str_ends_with($v, "'"))) {
                        $v = substr($v, 1, -1);
                    }
                    if (!array_key_exists($k, $_ENV)) {
                        $_ENV[$k] = $v;
                        putenv("$k=$v");
                    }
                }
            }
        }
        break;
    }
}

// Database Configuration - environment with safe local fallbacks
define('DB_HOST', getenv('DB_HOST') ?: ($_ENV['DB_HOST'] ?? '127.0.0.1'));
define('DB_PORT', getenv('DB_PORT') ?: ($_ENV['DB_PORT'] ?? '3306'));
define('DB_NAME', getenv('DB_NAME') ?: ($_ENV['DB_NAME'] ?? 'pickyx_db'));
define('DB_USER', getenv('DB_USER') !== false ? getenv('DB_USER') : ($_ENV['DB_USER'] ?? 'root'));
define('DB_PASS', getenv('DB_PASS') !== false ? getenv('DB_PASS') : ($_ENV['DB_PASS'] ?? ''));

// Game Defaults
define('MAX_LIVES', 5);
define('LIFE_REGEN_MINUTES', 20);
define('STARTING_COINS', 100);
define('STARTING_GEMS', 10);
define('STARTING_PEEK', 2);
define('STARTING_FREEZE', 2);
define('STARTING_WAND', 2);
define('STARTING_SHUFFLE', 2);

// Security Secret - read from environment, fallback to secure development default
$apiSecret = getenv('API_SECRET_KEY') ?: ($_ENV['API_SECRET_KEY'] ?? 'mesh_pickyx_dev_jwt_secret_change_in_prod');
define('API_SECRET_KEY', $apiSecret);
