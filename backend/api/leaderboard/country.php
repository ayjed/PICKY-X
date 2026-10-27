<?php
// backend/api/leaderboard/country.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

Response::initCors();

$pdo = Database::getConnection();
$currentUser = AuthHelper::getAuthenticatedUser();
$currentUserId = $currentUser ? (int)$currentUser['id'] : 0;

$countryCode = isset($_GET['country_code']) ? strtoupper(trim($_GET['country_code'])) : '';
if (empty($countryCode) && $currentUser) {
    $countryCode = $currentUser['country_code'];
}
if (empty($countryCode)) {
    $countryCode = 'NG';
}

try {
    // 1. Fetch Top 50 Players in the specified country
    $stmt = $pdo->prepare("
        SELECT 
            u.id as user_id,
            u.username,
            u.country_code,
            u.country_flag,
            u.is_vip,
            ls.total_stars,
            ls.max_level,
            ls.total_score
        FROM leaderboard_scores ls
        JOIN users u ON ls.user_id = u.id
        WHERE ls.country_code = ?
        ORDER BY ls.total_stars DESC, ls.total_score DESC, ls.max_level DESC
        LIMIT 50
    ");
    $stmt->execute([$countryCode]);
    $rawPlayers = $stmt->fetchAll();

    $leaderboard = [];
    $myRank = null;
    $rank = 1;

    foreach ($rawPlayers as $p) {
        $isMe = ((int)$p['user_id'] === $currentUserId);
        $entry = [
            'rank' => $rank,
            'user_id' => (int)$p['user_id'],
            'username' => $p['username'],
            'country_code' => $p['country_code'],
            'country_flag' => $p['country_flag'],
            'total_stars' => (int)$p['total_stars'],
            'max_level' => (int)$p['max_level'],
            'total_score' => (int)$p['total_score'],
            'is_vip' => (bool)$p['is_vip'],
            'is_me' => $isMe
        ];
        if ($isMe) {
            $myRank = $entry;
        }
        $leaderboard[] = $entry;
        $rank++;
    }

    // If current user is in this country but not top 50, calculate country rank
    if ($currentUserId > 0 && $myRank === null && $currentUser['country_code'] === $countryCode) {
        $userScoreStmt = $pdo->prepare("SELECT total_stars, max_level, total_score FROM leaderboard_scores WHERE user_id = ?");
        $userScoreStmt->execute([$currentUserId]);
        $myScore = $userScoreStmt->fetch();

        if ($myScore) {
            $rankStmt = $pdo->prepare("
                SELECT COUNT(*) + 1 as calculated_rank
                FROM leaderboard_scores
                WHERE country_code = ? AND (total_stars > ? OR (total_stars = ? AND total_score > ?))
            ");
            $rankStmt->execute([$countryCode, (int)$myScore['total_stars'], (int)$myScore['total_stars'], (int)$myScore['total_score']]);
            $calcRank = (int)$rankStmt->fetch()['calculated_rank'];

            $myRank = [
                'rank' => $calcRank,
                'user_id' => $currentUserId,
                'username' => $currentUser['username'],
                'country_code' => $currentUser['country_code'],
                'country_flag' => $currentUser['country_flag'],
                'total_stars' => (int)$myScore['total_stars'],
                'max_level' => (int)$myScore['max_level'],
                'total_score' => (int)$myScore['total_score'],
                'is_vip' => (bool)$currentUser['is_vip'],
                'is_me' => true
            ];
        }
    }

    $countStmt = $pdo->prepare("SELECT COUNT(*) FROM leaderboard_scores WHERE country_code = ?");
    $countStmt->execute([$countryCode]);
    $totalCountryParticipants = (int)$countStmt->fetchColumn();

    Response::success("Country leaderboard for {$countryCode} fetched.", [
        'country_code' => $countryCode,
        'leaderboard' => $leaderboard,
        'my_rank' => $myRank,
        'total_country_participants' => $totalCountryParticipants
    ]);
} catch (Exception $e) {
    Response::error('Server Error: ' . $e->getMessage(), 500);
}
