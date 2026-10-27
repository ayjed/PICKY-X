<?php
// backend/api/sync/get_player_data.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

Response::initCors();

$user = AuthHelper::requireAuth();
$userId = (int)$user['id'];
$pdo = Database::getConnection();

try {
    // 1. Fetch User Profile
    $userStmt = $pdo->prepare("SELECT id, device_id, username, country_code, country_flag, is_vip, vip_expires_at, remove_ads, created_at FROM users WHERE id = ?");
    $userStmt->execute([$userId]);
    $userProfile = $userStmt->fetch();

    // 2. Fetch Wallet
    $walletStmt = $pdo->prepare("SELECT coins, gems, booster_peek, booster_freeze, booster_wand, booster_shuffle, piggy_coins FROM wallets WHERE user_id = ?");
    $walletStmt->execute([$userId]);
    $wallet = $walletStmt->fetch();

    // 3. Fetch Energy
    $energyStmt = $pdo->prepare("SELECT current_lives, max_lives, last_life_loss_time, infinite_lives_until FROM game_energy WHERE user_id = ?");
    $energyStmt->execute([$userId]);
    $energy = $energyStmt->fetch();

    // 4. Fetch Level Progress
    $progressStmt = $pdo->prepare("SELECT level_number, stars, high_score, is_completed FROM level_progress WHERE user_id = ? ORDER BY level_number ASC");
    $progressStmt->execute([$userId]);
    $levels = $progressStmt->fetchAll();

    // 5. Fetch Leaderboard Stats
    $scoreStmt = $pdo->prepare("SELECT total_stars, max_level, total_score FROM leaderboard_scores WHERE user_id = ?");
    $scoreStmt->execute([$userId]);
    $score = $scoreStmt->fetch();

    // 6. Fetch Daily Rewards status
    $dailyStmt = $pdo->prepare("SELECT current_streak, last_claim_date FROM daily_rewards WHERE user_id = ?");
    $dailyStmt->execute([$userId]);
    $daily = $dailyStmt->fetch();

    Response::success('Player cloud data retrieved.', [
        'user' => $userProfile,
        'wallet' => $wallet,
        'energy' => $energy,
        'levels' => $levels,
        'score' => $score,
        'daily_reward' => $daily
    ]);
} catch (Exception $e) {
    Response::error('Server Error: ' . $e->getMessage(), 500);
}
