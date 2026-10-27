<?php
// backend/api/store/verify_purchase.php

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

$productId = isset($input['product_id']) ? trim($input['product_id']) : '';
$orderId = isset($input['order_id']) ? trim($input['order_id']) : ('ORD_' . time() . '_' . rand(1000, 9999));
$rawReceipt = isset($input['raw_receipt']) ? json_encode($input['raw_receipt']) : null;

if (empty($productId)) {
    Response::error('product_id is required.');
}

$catalog = [
    'gem_pouch_50' => ['gems' => 50, 'coins' => 0, 'usd' => 0.99, 'type' => 'gems'],
    'gem_sack_200' => ['gems' => 200, 'coins' => 0, 'usd' => 2.99, 'type' => 'gems'],
    'gem_vault_1000' => ['gems' => 1000, 'coins' => 0, 'usd' => 9.99, 'type' => 'gems'],
    'coin_pack_500' => ['gems' => 0, 'coins' => 500, 'usd' => 1.49, 'type' => 'coins'],
    'starter_pack' => ['gems' => 30, 'coins' => 250, 'usd' => 0.99, 'type' => 'starter', 'boosters' => 2],
    'remove_ads_permanent' => ['gems' => 0, 'coins' => 0, 'usd' => 1.99, 'type' => 'remove_ads'],
    'vip_monthly_subscription' => ['gems' => 100, 'coins' => 500, 'usd' => 3.99, 'type' => 'vip_sub']
];

if (!isset($catalog[$productId])) {
    Response::error('Unrecognized product_id.', 400);
}

$item = $catalog[$productId];
$pdo = Database::getConnection();

try {
    $pdo->beginTransaction();

    // 1. Record Transaction
    $txStmt = $pdo->prepare("
        INSERT INTO iap_transactions (user_id, order_id, product_id, amount_usd, status, raw_receipt)
        VALUES (?, ?, ?, ?, 'COMPLETED', ?)
    ");
    $txStmt->execute([$userId, $orderId, $productId, $item['usd'], $rawReceipt]);

    // 2. Deliver Entitlements
    if ($item['type'] === 'remove_ads') {
        $pdo->prepare("UPDATE users SET remove_ads = 1 WHERE id = ?")->execute([$userId]);
    } elseif ($item['type'] === 'vip_sub') {
        $vipExpires = date('Y-m-d H:i:s', strtotime('+30 days'));
        $pdo->prepare("UPDATE users SET is_vip = 1, vip_expires_at = ?, remove_ads = 1 WHERE id = ?")->execute([$vipExpires, $userId]);
        $pdo->prepare("UPDATE game_energy SET current_lives = 5, infinite_lives_until = ? WHERE user_id = ?")->execute([$vipExpires, $userId]);
        $pdo->prepare("UPDATE wallets SET coins = coins + ?, gems = gems + ? WHERE user_id = ?")->execute([$item['coins'], $item['gems'], $userId]);
    } elseif ($item['type'] === 'starter') {
        $bCount = $item['boosters'];
        $pdo->prepare("
            UPDATE wallets 
            SET coins = coins + ?, 
                gems = gems + ?, 
                booster_peek = booster_peek + ?, 
                booster_freeze = booster_freeze + ?, 
                booster_wand = booster_wand + ?, 
                booster_shuffle = booster_shuffle + ? 
            WHERE user_id = ?
        ")->execute([$item['coins'], $item['gems'], $bCount, $bCount, $bCount, $bCount, $userId]);
    } else {
        $pdo->prepare("UPDATE wallets SET coins = coins + ?, gems = gems + ? WHERE user_id = ?")
            ->execute([$item['coins'], $item['gems'], $userId]);
    }

    $pdo->commit();

    // Fetch updated wallet
    $wStmt = $pdo->prepare("SELECT coins, gems, booster_peek, booster_freeze, booster_wand, booster_shuffle FROM wallets WHERE user_id = ?");
    $wStmt->execute([$userId]);

    Response::success("Purchase of {$productId} completed.", [
        'order_id' => $orderId,
        'product_id' => $productId,
        'wallet' => $wStmt->fetch()
    ]);
} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    Response::error('Purchase Processing Error: ' . $e->getMessage(), 500);
}
