<?php
// backend/admin/players.php

$activePage = 'players';
$pageTitle = 'Player Management';
$pageSubtitle = 'Inspect player profiles, balances, inventories & grant live resources';

include __DIR__ . '/header.php';

// Handle Actions (Protected with CSRF Verification)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    $submittedToken = $_POST['csrf_token'] ?? '';
    if (empty($_SESSION['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $submittedToken)) {
        http_response_code(403);
        die('Security Verification Failed: Invalid or missing CSRF token.');
    }

    $targetId = (int)($_POST['user_id'] ?? 0);
    if ($targetId <= 0) {
        header("Location: players.php?msg=Invalid+User+ID");
        exit;
    }

    if ($_POST['action'] === 'grant_resources') {
        $addCoins = (int)($_POST['add_coins'] ?? 0);
        $addGems = (int)($_POST['add_gems'] ?? 0);
        $pdo->prepare("UPDATE wallets SET coins = coins + ?, gems = gems + ? WHERE user_id = ?")
            ->execute([$addCoins, $addGems, $targetId]);
        header("Location: players.php?msg=Resources+Granted+Successfully");
        exit;
    } elseif ($_POST['action'] === 'toggle_vip') {
        $vipExpires = date('Y-m-d H:i:s', strtotime('+30 days'));
        $pdo->prepare("
            UPDATE users 
            SET is_vip = 1 - is_vip, 
                vip_expires_at = IF(is_vip = 1, NULL, ?) 
            WHERE id = ?
        ")->execute([$vipExpires, $targetId]);
        header("Location: players.php?msg=VIP+Status+Updated");
        exit;
    } elseif ($_POST['action'] === 'refill_lives') {
        $pdo->prepare("UPDATE game_energy SET current_lives = 5, last_life_loss_time = NULL WHERE user_id = ?")
            ->execute([$targetId]);
        header("Location: players.php?msg=Player+Lives+Refilled+to+Full");
        exit;
    }
}

$search = isset($_GET['q']) ? trim($_GET['q']) : '';
$filterVip = isset($_GET['vip']) ? $_GET['vip'] : 'all';

$sql = "
    SELECT u.id, u.device_id, u.username, u.country_code, u.country_flag, u.is_vip, u.vip_expires_at, u.created_at,
           w.coins, w.gems, w.booster_peek, w.booster_freeze, w.booster_wand, w.booster_shuffle, w.piggy_coins,
           e.current_lives, e.max_lives,
           ls.total_stars, ls.max_level, ls.total_score
    FROM users u
    LEFT JOIN wallets w ON u.id = w.user_id
    LEFT JOIN game_energy e ON u.id = e.user_id
    LEFT JOIN leaderboard_scores ls ON u.id = ls.user_id
";

$where = [];
$params = [];

if (!empty($search)) {
    $where[] = "(u.username LIKE ? OR u.device_id LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

if ($filterVip === '1') {
    $where[] = "u.is_vip = 1";
} elseif ($filterVip === '0') {
    $where[] = "u.is_vip = 0";
}

if (!empty($where)) {
    $sql .= " WHERE " . implode(" AND ", $where);
}

$sql .= " ORDER BY u.id DESC LIMIT 100";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$players = $stmt->fetchAll();
?>

<!-- Search and Filter Bar -->
<div class="content-section" style="padding: 16px 24px; margin-bottom: 24px;">
  <form method="GET" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
    <div style="flex: 1; min-width: 240px;">
      <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" placeholder="Search by username or device ID..." class="search-input" style="width: 100%;">
    </div>
    
    <select name="vip" class="search-input" style="background: var(--bg-secondary); cursor: pointer;">
      <option value="all" <?= $filterVip === 'all' ? 'selected' : '' ?>>All Memberships</option>
      <option value="1" <?= $filterVip === '1' ? 'selected' : '' ?>>VIP Members Only</option>
      <option value="0" <?= $filterVip === '0' ? 'selected' : '' ?>>Standard Players Only</option>
    </select>

    <button type="submit" class="btn btn-primary">Filter</button>
    <?php if (!empty($search) || $filterVip !== 'all'): ?>
      <a href="players.php" class="btn" style="background: var(--bg-secondary); color: var(--text-muted);">Reset</a>
    <?php endif; ?>
  </form>
</div>

<!-- Player Table -->
<div class="content-section">
  <div class="section-header">
    <h2 class="section-title">👥 Registered Players (<?= count($players) ?>)</h2>
  </div>

  <?php if (empty($players)): ?>
    <div style="text-align: center; padding: 48px; color: var(--text-muted);">
      No players matched your search filter.
    </div>
  <?php else: ?>
    <table class="data-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Player</th>
          <th>Country</th>
          <th>Progress (⭐/Lvl)</th>
          <th>Wallet (🪙/💎)</th>
          <th>Lives ❤️</th>
          <th>Boosters (👁️/❄️/🪄/🔀)</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($players as $p): ?>
          <tr>
            <td><code>#<?= $p['id'] ?></code></td>
            <td>
              <div style="font-weight: 700;"><?= htmlspecialchars($p['username']) ?></div>
              <div style="font-size: 11px; color: var(--text-muted);"><?= htmlspecialchars($p['device_id']) ?></div>
              <?php if ($p['is_vip']): ?>
                <span class="badge badge-vip" style="font-size: 10px; margin-top: 2px;">👑 VIP Active</span>
              <?php endif; ?>
            </td>
            <td><?= $p['country_flag'] ?> <?= htmlspecialchars($p['country_code']) ?></td>
            <td>
              <div style="color: #fbbf24; font-weight: 600;">⭐ <?= number_format($p['total_stars'] ?? 0) ?></div>
              <div style="font-size: 12px; color: var(--text-muted);">Lvl <?= $p['max_level'] ?? 1 ?> (<?= number_format($p['total_score'] ?? 0) ?> pts)</div>
            </td>
            <td>
              <div>🪙 <strong style="color: #fbbf24;"><?= number_format($p['coins'] ?? 0) ?></strong></div>
              <div>💎 <strong style="color: var(--accent-purple);"><?= number_format($p['gems'] ?? 0) ?></strong></div>
              <?php if (($p['piggy_coins'] ?? 0) > 0): ?>
                <div style="font-size: 11px; color: #f472b6;">🐷 <?= number_format($p['piggy_coins']) ?></div>
              <?php endif; ?>
            </td>
            <td>
              <span style="font-weight: 700; color: <?= ($p['current_lives'] ?? 5) > 0 ? 'var(--accent-rose)' : 'var(--text-muted)' ?>;">
                ❤️ <?= $p['current_lives'] ?? 5 ?>/5
              </span>
            </td>
            <td>
              <div style="font-size: 13px;">
                👁️ <?= $p['booster_peek'] ?? 0 ?> &nbsp;
                ❄️ <?= $p['booster_freeze'] ?? 0 ?> &nbsp;
                🪄 <?= $p['booster_wand'] ?? 0 ?> &nbsp;
                🔀 <?= $p['booster_shuffle'] ?? 0 ?>
              </div>
            </td>
            <td>
              <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                <!-- Grant +500 Coins, +25 Gems -->
                <form method="POST" style="display: inline;">
                  <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken) ?>">
                  <input type="hidden" name="user_id" value="<?= $p['id'] ?>">
                  <input type="hidden" name="action" value="grant_resources">
                  <input type="hidden" name="add_coins" value="500">
                  <input type="hidden" name="add_gems" value="25">
                  <button type="submit" class="btn btn-sm btn-primary" title="Grant 500 Coins and 25 Gems">+500🪙 +25💎</button>
                </form>

                <!-- Refill Lives -->
                <form method="POST" style="display: inline;">
                  <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken) ?>">
                  <input type="hidden" name="user_id" value="<?= $p['id'] ?>">
                  <input type="hidden" name="action" value="refill_lives">
                  <button type="submit" class="btn btn-sm" style="background: rgba(244, 63, 94, 0.2); color: #fecdd3;" title="Refill Hearts to 5">❤️ Refill</button>
                </form>

                <!-- Toggle VIP -->
                <form method="POST" style="display: inline;">
                  <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken) ?>">
                  <input type="hidden" name="user_id" value="<?= $p['id'] ?>">
                  <input type="hidden" name="action" value="toggle_vip">
                  <button type="submit" class="btn btn-sm" style="background: rgba(245, 158, 11, 0.2); color: var(--accent-gold);">
                    <?= $p['is_vip'] ? 'Revoke VIP' : 'Make VIP' ?>
                  </button>
                </form>
              </div>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  <?php endif; ?>
</div>

<?php include __DIR__ . '/footer.php'; ?>
