<?php
// backend/api/energy/sync_lives.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

Response::initCors();

$user = AuthHelper::requireAuth();
$userId = (int)$user['id'];
$pdo = Database::getConnection();

$input = Response::getJsonInput();
$action = isset($input['action']) ? trim($input['action']) : 'check'; // 'check', 'deduct', 'refill'

try {
    $stmt = $pdo->prepare("SELECT current_lives, max_lives, last_life_loss_time, infinite_lives_until FROM game_energy WHERE user_id = ?");
    $stmt->execute([$userId]);
    $energy = $stmt->fetch();

    if (!$energy) {
        $pdo->prepare("INSERT INTO game_energy (user_id, current_lives, max_lives) VALUES (?, 5, 5)")->execute([$userId]);
        $energy = ['current_lives' => 5, 'max_lives' => 5, 'last_life_loss_time' => null, 'infinite_lives_until' => null];
    }

    $currentLives = (int)$energy['current_lives'];
    $maxLives = (int)$energy['max_lives'];
    $lastLossTime = $energy['last_life_loss_time'] ? strtotime($energy['last_life_loss_time']) : null;
    $infiniteUntil = $energy['infinite_lives_until'] ? strtotime($energy['infinite_lives_until']) : null;
    $now = time();

    // Check if user currently has infinite lives active
    $hasInfiniteLives = ($infiniteUntil !== null && $infiniteUntil > $now);

    // Calculate server-authoritative regenerated lives
    if ($currentLives < $maxLives && $lastLossTime !== null) {
        $secondsPassed = $now - $lastLossTime;
        $secondsPerLife = LIFE_REGEN_MINUTES * 60; // 1200 seconds
        $livesGained = (int)floor($secondsPassed / $secondsPerLife);

        if ($livesGained > 0) {
            $currentLives = min($maxLives, $currentLives + $livesGained);
            if ($currentLives >= $maxLives) {
                $lastLossTime = null;
            } else {
                $lastLossTime = $lastLossTime + ($livesGained * $secondsPerLife);
            }
        }
    }

    if ($action === 'deduct') {
        if (!$hasInfiniteLives && $currentLives > 0) {
            if ($currentLives === $maxLives) {
                $lastLossTime = $now;
            }
            $currentLives = max(0, $currentLives - 1);
        }
    } elseif ($action === 'refill') {
        $currentLives = $maxLives;
        $lastLossTime = null;
    } elseif ($action === 'grant_infinite') {
        $hours = isset($input['hours']) ? (int)$input['hours'] : 2;
        $infiniteUntil = $now + ($hours * 3600);
        $currentLives = $maxLives;
        $lastLossTime = null;
    }

    // Update database
    $updateStmt = $pdo->prepare("
        UPDATE game_energy 
        SET current_lives = ?, 
            last_life_loss_time = ?, 
            infinite_lives_until = ? 
        WHERE user_id = ?
    ");
    $updateStmt->execute([
        $currentLives,
        $lastLossTime ? date('Y-m-d H:i:s', $lastLossTime) : null,
        $infiniteUntil ? date('Y-m-d H:i:s', $infiniteUntil) : null,
        $userId
    ]);

    // Calculate seconds remaining until next life
    $secondsToNextLife = 0;
    if ($currentLives < $maxLives && $lastLossTime !== null) {
        $secondsPassed = $now - $lastLossTime;
        $secondsPerLife = LIFE_REGEN_MINUTES * 60;
        $secondsToNextLife = max(0, $secondsPerLife - ($secondsPassed % $secondsPerLife));
    }

    Response::success('Life energy synced.', [
        'current_lives' => $currentLives,
        'max_lives' => $maxLives,
        'is_full' => ($currentLives >= $maxLives),
        'seconds_to_next_life' => $secondsToNextLife,
        'has_infinite_lives' => ($infiniteUntil !== null && $infiniteUntil > $now),
        'infinite_lives_seconds' => max(0, ($infiniteUntil ?? $now) - $now)
    ]);
} catch (Exception $e) {
    Response::error('Server Error: ' . $e->getMessage(), 500);
}
