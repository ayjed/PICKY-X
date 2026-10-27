<?php
// backend/api/auth/login.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

Response::initCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Only POST method is allowed.', 405);
}

$input = Response::getJsonInput();
$deviceId = isset($input['device_id']) ? trim($input['device_id']) : '';
$username = isset($input['username']) ? trim($input['username']) : '';
$countryCode = isset($input['country_code']) ? strtoupper(trim($input['country_code'])) : 'NG';

if (empty($deviceId)) {
    Response::error('Parameter device_id is required.');
}

// Country flag mapping helper
$flagMap = [
    'NG' => '🇳🇬', 'US' => '🇺🇸', 'GB' => '🇬🇧', 'GH' => '🇬🇭', 'CA' => '🇨🇦',
    'JP' => '🇯🇵', 'DE' => '🇩🇪', 'FR' => '🇫🇷', 'IN' => '🇮🇳', 'BR' => '🇧🇷',
    'ZA' => '🇿🇦', 'KE' => '🇰🇪', 'EG' => '🇪🇬', 'AU' => '🇦🇺', 'ES' => '🇪🇸'
];
$countryFlag = $flagMap[$countryCode] ?? '🌍';

if (empty($username)) {
    $username = 'Player_' . substr(md5($deviceId), 0, 5);
}

$pdo = Database::getConnection();

try {
    // Check if user exists
    $stmt = $pdo->prepare("SELECT * FROM users WHERE device_id = ? LIMIT 1");
    $stmt->execute([$deviceId]);
    $user = $stmt->fetch();

    if (!$user) {
        // Register new user
        $insertStmt = $pdo->prepare("
            INSERT INTO users (device_id, username, country_code, country_flag, is_vip, remove_ads)
            VALUES (?, ?, ?, ?, 0, 0)
        ");
        $insertStmt->execute([$deviceId, $username, $countryCode, $countryFlag]);
        $userId = (int)$pdo->lastInsertId();

        // Initialize Wallet
        $pdo->prepare("INSERT INTO wallets (user_id, coins, gems, booster_peek, booster_freeze, booster_wand, booster_shuffle) VALUES (?, ?, ?, ?, ?, ?, ?)")
            ->execute([$userId, STARTING_COINS, STARTING_GEMS, STARTING_PEEK, STARTING_FREEZE, STARTING_WAND, STARTING_SHUFFLE]);

        // Initialize Energy
        $pdo->prepare("INSERT INTO game_energy (user_id, current_lives, max_lives) VALUES (?, ?, ?)")
            ->execute([$userId, MAX_LIVES, MAX_LIVES]);

        // Initialize Leaderboard entry
        $pdo->prepare("INSERT INTO leaderboard_scores (user_id, total_stars, max_level, total_score, country_code) VALUES (?, 0, 1, 0, ?)")
            ->execute([$userId, $countryCode]);

        // Initialize Daily Rewards
        $pdo->prepare("INSERT INTO daily_rewards (user_id, current_streak, last_claim_date) VALUES (?, 0, NULL)")
            ->execute([$userId]);
    } else {
        $userId = (int)$user['id'];
        // Update username / country if provided and different
        if (!empty($username) || !empty($countryCode)) {
            $updateUser = $pdo->prepare("UPDATE users SET username = ?, country_code = ?, country_flag = ? WHERE id = ?");
            $updateUser->execute([$username, $countryCode, $countryFlag, $userId]);
            
            $pdo->prepare("UPDATE leaderboard_scores SET country_code = ? WHERE user_id = ?")
                ->execute([$countryCode, $userId]);
        }
    }

    // Generate fresh auth token
    $token = AuthHelper::generateToken($userId, $deviceId);
    $pdo->prepare("UPDATE users SET auth_token = ? WHERE id = ?")->execute([$token, $userId]);

    // Fetch complete user profile
    $userStmt = $pdo->prepare("SELECT id, device_id, username, country_code, country_flag, is_vip, vip_expires_at, remove_ads, auth_token, created_at FROM users WHERE id = ?");
    $userStmt->execute([$userId]);
    $userProfile = $userStmt->fetch();

    // Fetch wallet
    $walletStmt = $pdo->prepare("SELECT coins, gems, booster_peek, booster_freeze, booster_wand, booster_shuffle, piggy_coins FROM wallets WHERE user_id = ?");
    $walletStmt->execute([$userId]);
    $wallet = $walletStmt->fetch();

    // Fetch energy
    $energyStmt = $pdo->prepare("SELECT current_lives, max_lives, last_life_loss_time, infinite_lives_until FROM game_energy WHERE user_id = ?");
    $energyStmt->execute([$userId]);
    $energy = $energyStmt->fetch();

    // Fetch leaderboard stats
    $scoreStmt = $pdo->prepare("SELECT total_stars, max_level, total_score FROM leaderboard_scores WHERE user_id = ?");
    $scoreStmt->execute([$userId]);
    $score = $scoreStmt->fetch();

    Response::success('Login successful.', [
        'user' => $userProfile,
        'wallet' => $wallet,
        'energy' => $energy,
        'score' => $score,
        'auth_token' => $token
    ]);
} catch (Exception $e) {
    Response::error('Server Error: ' . $e->getMessage(), 500);
}
