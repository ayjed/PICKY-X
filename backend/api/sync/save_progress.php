<?php
// backend/api/sync/save_progress.php

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

$pdo = Database::getConnection();

try {
    $pdo->beginTransaction();

    // 1. Sync Wallet
    if (isset($input['wallet']) && is_array($input['wallet'])) {
        $w = $input['wallet'];
        $coins = isset($w['coins']) ? (int)$w['coins'] : null;
        $gems = isset($w['gems']) ? (int)$w['gems'] : null;
        $peek = isset($w['booster_peek']) ? (int)$w['booster_peek'] : null;
        $freeze = isset($w['booster_freeze']) ? (int)$w['booster_freeze'] : null;
        $wand = isset($w['booster_wand']) ? (int)$w['booster_wand'] : null;
        $shuffle = isset($w['booster_shuffle']) ? (int)$w['booster_shuffle'] : null;
        $piggy = isset($w['piggy_coins']) ? (int)$w['piggy_coins'] : null;

        $updateFields = [];
        $params = [];

        if ($coins !== null) { $updateFields[] = "coins = ?"; $params[] = $coins; }
        if ($gems !== null) { $updateFields[] = "gems = ?"; $params[] = $gems; }
        if ($peek !== null) { $updateFields[] = "booster_peek = ?"; $params[] = $peek; }
        if ($freeze !== null) { $updateFields[] = "booster_freeze = ?"; $params[] = $freeze; }
        if ($wand !== null) { $updateFields[] = "booster_wand = ?"; $params[] = $wand; }
        if ($shuffle !== null) { $updateFields[] = "booster_shuffle = ?"; $params[] = $shuffle; }
        if ($piggy !== null) { $updateFields[] = "piggy_coins = ?"; $params[] = $piggy; }

        if (!empty($updateFields)) {
            $params[] = $userId;
            $sql = "UPDATE wallets SET " . implode(', ', $updateFields) . " WHERE user_id = ?";
            $pdo->prepare($sql)->execute($params);
        }
    }

    // 2. Sync Level Progress Array
    if (isset($input['levels']) && is_array($input['levels'])) {
        foreach ($input['levels'] as $lvl) {
            $lvlNum = isset($lvl['level_number']) ? (int)$lvl['level_number'] : 0;
            $stars = isset($lvl['stars']) ? (int)$lvl['stars'] : 0;
            $score = isset($lvl['high_score']) ? (int)$lvl['high_score'] : 0;
            $completed = isset($lvl['is_completed']) ? ((bool)$lvl['is_completed'] ? 1 : 0) : 1;

            if ($lvlNum >= 1 && $lvlNum <= 60) {
                $stmt = $pdo->prepare("
                    INSERT INTO level_progress (user_id, level_number, stars, high_score, is_completed)
                    VALUES (?, ?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        stars = GREATEST(stars, VALUES(stars)),
                        high_score = GREATEST(high_score, VALUES(high_score)),
                        is_completed = GREATEST(is_completed, VALUES(is_completed))
                ");
                $stmt->execute([$userId, $lvlNum, $stars, $score, $completed]);
            }
        }
    }

    // 3. Recalculate Leaderboard Summary
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
    $maxLevel = min(60, (int)$agg['max_level']);
    $totalScore = (int)$agg['total_score'];

    $pdo->prepare("
        INSERT INTO leaderboard_scores (user_id, total_stars, max_level, total_score, country_code)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            total_stars = VALUES(total_stars),
            max_level = VALUES(max_level),
            total_score = VALUES(total_score)
    ")->execute([$userId, $totalStars, $maxLevel, $totalScore, $user['country_code']]);

    // 4. Sync Energy
    if (isset($input['energy']) && is_array($input['energy'])) {
        $e = $input['energy'];
        $lives = isset($e['current_lives']) ? min(5, max(0, (int)$e['current_lives'])) : 5;
        $pdo->prepare("UPDATE game_energy SET current_lives = ? WHERE user_id = ?")
            ->execute([$lives, $userId]);
    }

    $pdo->commit();

    Response::success('Cloud save synchronized successfully.', [
        'user_id' => $userId,
        'total_stars' => $totalStars,
        'unlocked_level' => $maxLevel,
        'total_score' => $totalScore
    ]);
} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    Response::error('Sync Failed: ' . $e->getMessage(), 500);
}
