<?php
// backend/setup_database.php

require_once __DIR__ . '/config/constants.php';

echo "====================================================\n";
echo "🚀 Initializing Picky X MySQL Database (pickyx_db)...\n";
echo "====================================================\n";

try {
    $rootDsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";charset=utf8mb4";
    $pdo = new PDO($rootDsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    // 1. Create database
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `" . DB_NAME . "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
    echo "✔ Database '" . DB_NAME . "' verified/created successfully.\n";

    // 2. Select database
    $pdo->exec("USE `" . DB_NAME . "`;");

    // 3. Create 'users' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `users` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `device_id` VARCHAR(128) NOT NULL UNIQUE,
            `username` VARCHAR(64) NOT NULL,
            `country_code` VARCHAR(4) NOT NULL DEFAULT 'NG',
            `country_flag` VARCHAR(8) NOT NULL DEFAULT '🇳🇬',
            `is_vip` TINYINT(1) NOT NULL DEFAULT 0,
            `vip_expires_at` DATETIME NULL,
            `remove_ads` TINYINT(1) NOT NULL DEFAULT 0,
            `auth_token` VARCHAR(128) NULL,
            `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX (`device_id`),
            INDEX (`country_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'users' created.\n";

    // 4. Create 'wallets' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `wallets` (
            `user_id` INT PRIMARY KEY,
            `coins` INT NOT NULL DEFAULT " . STARTING_COINS . ",
            `gems` INT NOT NULL DEFAULT " . STARTING_GEMS . ",
            `booster_peek` INT NOT NULL DEFAULT " . STARTING_PEEK . ",
            `booster_freeze` INT NOT NULL DEFAULT " . STARTING_FREEZE . ",
            `booster_wand` INT NOT NULL DEFAULT " . STARTING_WAND . ",
            `booster_shuffle` INT NOT NULL DEFAULT " . STARTING_SHUFFLE . ",
            `piggy_coins` INT NOT NULL DEFAULT 0,
            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'wallets' created.\n";

    // 5. Create 'game_energy' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `game_energy` (
            `user_id` INT PRIMARY KEY,
            `current_lives` INT NOT NULL DEFAULT " . MAX_LIVES . ",
            `max_lives` INT NOT NULL DEFAULT " . MAX_LIVES . ",
            `last_life_loss_time` DATETIME NULL,
            `infinite_lives_until` DATETIME NULL,
            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'game_energy' created.\n";

    // 6. Create 'level_progress' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `level_progress` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `user_id` INT NOT NULL,
            `level_number` INT NOT NULL,
            `stars` TINYINT NOT NULL DEFAULT 0,
            `high_score` INT NOT NULL DEFAULT 0,
            `is_completed` TINYINT(1) NOT NULL DEFAULT 0,
            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY `uk_user_level` (`user_id`, `level_number`),
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'level_progress' created.\n";

    // 7. Create 'leaderboard_scores' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `leaderboard_scores` (
            `user_id` INT PRIMARY KEY,
            `total_stars` INT NOT NULL DEFAULT 0,
            `max_level` INT NOT NULL DEFAULT 1,
            `total_score` INT NOT NULL DEFAULT 0,
            `country_code` VARCHAR(4) NOT NULL DEFAULT 'NG',
            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX (`total_stars`),
            INDEX (`total_score`),
            INDEX (`country_code`),
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'leaderboard_scores' created.\n";

    // 8. Create 'iap_transactions' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `iap_transactions` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `user_id` INT NOT NULL,
            `order_id` VARCHAR(128) NOT NULL,
            `product_id` VARCHAR(64) NOT NULL,
            `amount_usd` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            `status` VARCHAR(32) NOT NULL DEFAULT 'COMPLETED',
            `raw_receipt` TEXT NULL,
            `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'iap_transactions' created.\n";

    // 9. Create 'daily_rewards' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `daily_rewards` (
            `user_id` INT PRIMARY KEY,
            `current_streak` INT NOT NULL DEFAULT 0,
            `last_claim_date` DATE NULL,
            `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'daily_rewards' created.\n";

    // 10. Create 'admin_users' table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `admin_users` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `username` VARCHAR(64) NOT NULL UNIQUE,
            `password_hash` VARCHAR(255) NOT NULL,
            `role` VARCHAR(32) NOT NULL DEFAULT 'superadmin',
            `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
    echo "✔ Table 'admin_users' created.\n";

    // 11. Seed Admin User
    $adminUser = 'admin';
    $adminPass = 'pickyx2026admin';
    $stmt = $pdo->prepare("SELECT id FROM admin_users WHERE username = ?");
    $stmt->execute([$adminUser]);
    if (!$stmt->fetch()) {
        $hash = password_hash($adminPass, PASSWORD_BCRYPT);
        $insertAdmin = $pdo->prepare("INSERT INTO admin_users (username, password_hash, role) VALUES (?, ?, 'superadmin')");
        $insertAdmin->execute([$adminUser, $hash]);
        echo "✔ Seeded default admin account: Username='$adminUser', Password='$adminPass'\n";
    }

    // 12. Seed Mock Top Players for Realistic Country & Global Leaderboards
    $mockPlayers = [
        ['dev_us_01', 'AeroNinja', 'US', '🇺🇸', 178, 60, 98450, 1],
        ['dev_gh_02', 'Kofi_King', 'GH', '🇬🇭', 172, 58, 94200, 1],
        ['dev_ng_03', 'ChukaVortex', 'NG', '🇳🇬', 165, 55, 89100, 1],
        ['dev_jp_04', 'SakuraMatch', 'JP', '🇯🇵', 154, 52, 83400, 0],
        ['dev_gb_05', 'LondonBrain', 'GB', '🇬🇧', 148, 50, 79200, 0],
        ['dev_ng_06', 'Tunde_Lagos', 'NG', '🇳🇬', 142, 48, 76800, 0],
        ['dev_de_07', 'PixelMaster', 'DE', '🇩🇪', 135, 45, 72000, 0],
        ['dev_ca_08', 'MapleMind', 'CA', '🇨🇦', 128, 42, 67500, 0],
        ['dev_in_09', 'RohanMystic', 'IN', '🇮🇳', 120, 40, 63000, 0],
        ['dev_ng_10', 'AminaKano', 'NG', '🇳🇬', 115, 38, 59400, 0],
        ['dev_fr_11', 'JeanLucSpeed', 'FR', '🇫🇷', 108, 35, 55100, 0],
        ['dev_br_12', 'SilvaBlitz', 'BR', '🇧🇷', 95, 30, 48200, 0],
        ['dev_ng_13', 'ZainabAbuja', 'NG', '🇳🇬', 88, 28, 44100, 0],
        ['dev_us_14', 'CyberNova', 'US', '🇺🇸', 82, 25, 41000, 0],
        ['dev_gb_15', 'OliverClash', 'GB', '🇬🇧', 75, 22, 36500, 0],
    ];

    foreach ($mockPlayers as $p) {
        [$devId, $name, $country, $flag, $stars, $maxLvl, $score, $isVip] = $p;
        $check = $pdo->prepare("SELECT id FROM users WHERE device_id = ?");
        $check->execute([$devId]);
        $existing = $check->fetch();
        if (!$existing) {
            $insertUser = $pdo->prepare("
                INSERT INTO users (device_id, username, country_code, country_flag, is_vip, remove_ads)
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            $insertUser->execute([$devId, $name, $country, $flag, $isVip, $isVip]);
            $uId = $pdo->lastInsertId();

            // Wallet
            $pdo->prepare("INSERT INTO wallets (user_id, coins, gems, piggy_coins) VALUES (?, 1200, 45, 300)")->execute([$uId]);
            // Energy
            $pdo->prepare("INSERT INTO game_energy (user_id, current_lives, max_lives) VALUES (?, 5, 5)")->execute([$uId]);
            // Leaderboard score
            $pdo->prepare("INSERT INTO leaderboard_scores (user_id, total_stars, max_level, total_score, country_code) VALUES (?, ?, ?, ?, ?)")->execute([$uId, $stars, $maxLvl, $score, $country]);
            // Daily reward
            $pdo->prepare("INSERT INTO daily_rewards (user_id, current_streak, last_claim_date) VALUES (?, 4, CURDATE())")->execute([$uId]);
        }
    }
    echo "✔ Seeded 15 top international & national leaderboard players!\n";

    echo "\n🎉 Database setup completed successfully!\n";
} catch (Exception $e) {
    echo "\n❌ Setup Failed: " . $e->getMessage() . "\n";
}
