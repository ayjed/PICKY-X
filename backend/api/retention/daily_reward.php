<?php
// backend/api/retention/daily_reward.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

Response::initCors();

$user = AuthHelper::requireAuth();
$userId = (int)$user['id'];
$pdo = Database::getConnection();

$input = Response::getJsonInput();
$action = isset($input['action']) ? trim($input['action']) : 'check'; // 'check' or 'claim'

$rewardCalendar = [
    1 => ['coins' => 50, 'gems' => 0, 'booster' => null],
    2 => ['coins' => 100, 'gems' => 0, 'booster' => 'peek'],
    3 => ['coins' => 150, 'gems' => 5, 'booster' => null],
    4 => ['coins' => 200, 'gems' => 0, 'booster' => 'freeze'],
    5 => ['coins' => 250, 'gems' => 10, 'booster' => null],
    6 => ['coins' => 300, 'gems' => 0, 'booster' => 'wand'],
    7 => ['coins' => 500, 'gems' => 25, 'booster' => 'shuffle'],
];

try {
    $stmt = $pdo->prepare("SELECT current_streak, last_claim_date FROM daily_rewards WHERE user_id = ?");
    $stmt->execute([$userId]);
    $reward = $stmt->fetch();

    if (!$reward) {
        $pdo->prepare("INSERT INTO daily_rewards (user_id, current_streak, last_claim_date) VALUES (?, 0, NULL)")->execute([$userId]);
        $reward = ['current_streak' => 0, 'last_claim_date' => null];
    }

    $currentStreak = (int)$reward['current_streak'];
    $lastClaimDate = $reward['last_claim_date'];
    $today = date('Y-m-d');
    $yesterday = date('Y-m-d', strtotime('-1 day'));

    $canClaim = false;
    $nextDay = 1;

    if ($lastClaimDate === null) {
        $canClaim = true;
        $nextDay = 1;
    } elseif ($lastClaimDate === $today) {
        $canClaim = false;
        $nextDay = ($currentStreak % 7) + 1;
    } elseif ($lastClaimDate === $yesterday) {
        $canClaim = true;
        $nextDay = ($currentStreak % 7) + 1;
    } else {
        // Streak broken
        $canClaim = true;
        $nextDay = 1;
    }

    if ($action === 'claim') {
        if (!$canClaim) {
            Response::error('Daily reward already claimed today. Come back tomorrow!', 400);
        }

        $awarded = $rewardCalendar[$nextDay];
        $newStreak = ($lastClaimDate === $yesterday) ? ($currentStreak + 1) : 1;

        $pdo->beginTransaction();

        // Update daily rewards table
        $pdo->prepare("UPDATE daily_rewards SET current_streak = ?, last_claim_date = ? WHERE user_id = ?")
            ->execute([$newStreak, $today, $userId]);

        // Credit Wallet
        $updateWalletSql = "UPDATE wallets SET coins = coins + ?, gems = gems + ?";
        $params = [$awarded['coins'], $awarded['gems']];

        if ($awarded['booster'] === 'peek') {
            $updateWalletSql .= ", booster_peek = booster_peek + 1";
        } elseif ($awarded['booster'] === 'freeze') {
            $updateWalletSql .= ", booster_freeze = booster_freeze + 1";
        } elseif ($awarded['booster'] === 'wand') {
            $updateWalletSql .= ", booster_wand = booster_wand + 1";
        } elseif ($awarded['booster'] === 'shuffle') {
            $updateWalletSql .= ", booster_shuffle = booster_shuffle + 1";
        }

        $updateWalletSql .= " WHERE user_id = ?";
        $params[] = $userId;
        $pdo->prepare($updateWalletSql)->execute($params);

        $pdo->commit();

        Response::success("Day {$nextDay} reward claimed successfully!", [
            'day' => $nextDay,
            'streak' => $newStreak,
            'reward' => $awarded,
            'last_claim_date' => $today
        ]);
    } else {
        Response::success('Daily reward status checked.', [
            'can_claim' => $canClaim,
            'current_streak' => $currentStreak,
            'next_day_reward' => $rewardCalendar[$nextDay],
            'next_day' => $nextDay,
            'last_claim_date' => $lastClaimDate
        ]);
    }
} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    Response::error('Server Error: ' . $e->getMessage(), 500);
}
