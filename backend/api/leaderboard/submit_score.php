<?php
// backend/api/leaderboard/submit_score.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

Response::initCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Only POST method is allowed.', 405);
}

$user = AuthHelper::requireAuth();
$userId = (int)$user['id'];

$input = Response::getJsonInput();
$levelNumber = isset($input['level_number']) ? (int)$input['level_number'] : 0;
$stars = isset($input['stars']) ? min(3, max(1, (int)$input['stars'])) : 1;
$score = isset($input['score']) ? max(0, (int)$input['score']) : 0;
$coinsEarned = isset($input['coins_earned']) ? max(0, (int)$input['coins_earned']) : 0;
$gemsEarned = isset($input['gems_earned']) ? max(0, (int)$input['gems_earned']) : 0;

if ($levelNumber < 1 || $levelNumber > 60) {
    Response::error('Invalid level_number. Must be between 1 and 60.');
}

$pdo = Database::getConnection();

try {
    $pdo->beginTransaction();

    // 1. Upsert level_progress
    $checkProgress = $pdo->prepare("SELECT stars, high_score FROM level_progress WHERE user_id = ? AND level_number = ?");
    $checkProgress->execute([$userId, $levelNumber]);
    $existing = $checkProgress->fetch();

    $isNewRecord = false;
    if (!$existing) {
        $insert = $pdo->prepare("
            INSERT INTO level_progress (user_id, level_number, stars, high_score, is_completed)
            VALUES (?, ?, ?, ?, 1)
        ");
        $insert->execute([$userId, $levelNumber, $stars, $score]);
        $isNewRecord = true;
    } else {
        $newStars = max((int)$existing['stars'], $stars);
        $newHighScore = max((int)$existing['high_score'], $score);
        $update = $pdo->prepare("
            UPDATE level_progress 
            SET stars = ?, high_score = ?, is_completed = 1 
            WHERE user_id = ? AND level_number = ?
        ");
        $update->execute([$newStars, $newHighScore, $userId, $levelNumber]);
    }

    // 2. Aggregate Total Stars, Max Unlocked Level, and Total Score
    $aggStmt = $pdo->prepare("
        SELECT 
            COALESCE(SUM(stars), 0) as total_stars,
            COALESCE(MAX(level_number), 1) as max_level,
            COALESCE(SUM(high_score), 0) as total_score
        FROM level_progress
        WHERE user_id = ?
    ");
    $aggStmt->execute([$userId]);
    $agg = $aggStmt->fetch();

    $totalStars = (int)$agg['total_stars'];
    $maxLevel = min(60, (int)$agg['max_level'] + 1); // Next unlocked level
    $totalScore = (int)$agg['total_score'];

    // 3. Update leaderboard_scores
    $lbStmt = $pdo->prepare("
        INSERT INTO leaderboard_scores (user_id, total_stars, max_level, total_score, country_code)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            total_stars = VALUES(total_stars),
            max_level = VALUES(max_level),
            total_score = VALUES(total_score),
            country_code = VALUES(country_code)
    ");
    $lbStmt->execute([$userId, $totalStars, $maxLevel, $totalScore, $user['country_code']]);

    // 4. Credit Coins / Gems in Wallet if supplied
    if ($coinsEarned > 0 || $gemsEarned > 0) {
        $pdo->prepare("
            UPDATE wallets 
            SET coins = coins + ?, gems = gems + ? 
            WHERE user_id = ?
        ")->execute([$coinsEarned, $gemsEarned, $userId]);
    }

    $pdo->commit();

    // 5. Fetch updated summary
    $wallet = $pdo->prepare("SELECT coins, gems FROM wallets WHERE user_id = ?");
    $wallet->execute([$userId]);

    Response::success('Score submitted and leaderboard updated successfully.', [
        'level_number' => $levelNumber,
        'stars' => $stars,
        'score' => $score,
        'total_stars' => $totalStars,
        'unlocked_level' => $maxLevel,
        'total_score' => $totalScore,
        'wallet' => $wallet->fetch()
    ]);
} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    Response::error('Server Error: ' . $e->getMessage(), 500);
}
