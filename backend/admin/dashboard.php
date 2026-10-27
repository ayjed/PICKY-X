<?php
// backend/admin/dashboard.php

$activePage = 'dashboard';
$pageTitle = 'Analytics Overview';
$pageSubtitle = 'Real-time telemetry, economy metrics & campaign health';

include __DIR__ . '/header.php';

// 1. Top Level Metrics
$totalUsers = (int)$pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
$totalVips = (int)$pdo->query("SELECT COUNT(*) FROM users WHERE is_vip = 1")->fetchColumn();
$totalCoins = (int)$pdo->query("SELECT COALESCE(SUM(coins), 0) FROM wallets")->fetchColumn();
$totalGems = (int)$pdo->query("SELECT COALESCE(SUM(gems), 0) FROM wallets")->fetchColumn();
$totalRevenue = (float)$pdo->query("SELECT COALESCE(SUM(amount_usd), 0.00) FROM iap_transactions WHERE status = 'COMPLETED'")->fetchColumn();
$totalStars = (int)$pdo->query("SELECT COALESCE(SUM(stars), 0) FROM level_progress")->fetchColumn();

// 2. Booster Inventory Distribution
$totalPeek = (int)$pdo->query("SELECT COALESCE(SUM(booster_peek), 0) FROM wallets")->fetchColumn();
$totalFreeze = (int)$pdo->query("SELECT COALESCE(SUM(booster_freeze), 0) FROM wallets")->fetchColumn();
$totalWand = (int)$pdo->query("SELECT COALESCE(SUM(booster_wand), 0) FROM wallets")->fetchColumn();
$totalShuffle = (int)$pdo->query("SELECT COALESCE(SUM(booster_shuffle), 0) FROM wallets")->fetchColumn();
$totalPiggy = (int)$pdo->query("SELECT COALESCE(SUM(piggy_coins), 0) FROM wallets")->fetchColumn();

// 3. World Distribution
$world1 = (int)$pdo->query("SELECT COUNT(DISTINCT user_id) FROM leaderboard_scores WHERE max_level BETWEEN 1 AND 12")->fetchColumn();
$world2 = (int)$pdo->query("SELECT COUNT(DISTINCT user_id) FROM leaderboard_scores WHERE max_level BETWEEN 13 AND 24")->fetchColumn();
$world3 = (int)$pdo->query("SELECT COUNT(DISTINCT user_id) FROM leaderboard_scores WHERE max_level BETWEEN 25 AND 36")->fetchColumn();
$world4 = (int)$pdo->query("SELECT COUNT(DISTINCT user_id) FROM leaderboard_scores WHERE max_level BETWEEN 37 AND 48")->fetchColumn();
$world5 = (int)$pdo->query("SELECT COUNT(DISTINCT user_id) FROM leaderboard_scores WHERE max_level BETWEEN 49 AND 60")->fetchColumn();

// 4. Recent Top Players
$recentLeaders = $pdo->query("
    SELECT u.username, u.country_flag, ls.total_stars, ls.max_level, ls.total_score
    FROM leaderboard_scores ls
    JOIN users u ON ls.user_id = u.id
    ORDER BY ls.total_stars DESC, ls.total_score DESC
    LIMIT 5
")->fetchAll();
?>

<!-- Metric Cards Grid -->
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(6, 182, 212, 0.15); color: var(--accent-cyan);">👥</div>
    <div class="stat-info">
      <h3>Total Players</h3>
      <div class="value"><?= number_format($totalUsers) ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(245, 158, 11, 0.15); color: var(--accent-gold);">👑</div>
    <div class="stat-info">
      <h3>VIP Subscribers</h3>
      <div class="value"><?= number_format($totalVips) ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(16, 185, 129, 0.15); color: var(--accent-emerald);">💵</div>
    <div class="stat-info">
      <h3>IAP Revenue</h3>
      <div class="value">$<?= number_format($totalRevenue, 2) ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(234, 179, 8, 0.15); color: #eab308);">🪙</div>
    <div class="stat-info">
      <h3>Circulating Coins</h3>
      <div class="value"><?= number_format($totalCoins) ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(139, 92, 246, 0.15); color: var(--accent-purple);">💎</div>
    <div class="stat-info">
      <h3>Circulating Gems</h3>
      <div class="value"><?= number_format($totalGems) ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(244, 63, 94, 0.15); color: var(--accent-rose);">⭐</div>
    <div class="stat-info">
      <h3>Total Stars</h3>
      <div class="value"><?= number_format($totalStars) ?></div>
    </div>
  </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 32px;">
  <!-- Virtual Economy Breakdown -->
  <div class="content-section" style="margin-bottom: 0;">
    <div class="section-header">
      <h2 class="section-title">💰 Virtual Economy & Booster Stockpile</h2>
      <a href="players.php" class="btn btn-sm btn-primary">Manage Players</a>
    </div>

    <table class="data-table">
      <tbody>
        <tr>
          <td>🪙 <strong>Total Coins in Wallets</strong></td>
          <td style="text-align: right; font-weight: 700; color: #fbbf24;"><?= number_format($totalCoins) ?></td>
        </tr>
        <tr>
          <td>💎 <strong>Total Gems in Wallets</strong></td>
          <td style="text-align: right; font-weight: 700; color: var(--accent-purple);"><?= number_format($totalGems) ?></td>
        </tr>
        <tr>
          <td>🐷 <strong>Coins Locked in Piggy Banks</strong></td>
          <td style="text-align: right; font-weight: 700; color: #f472b6;"><?= number_format($totalPiggy) ?></td>
        </tr>
        <tr>
          <td>👁️ <strong>Peek Boosters Active</strong></td>
          <td style="text-align: right; font-weight: 600;"><?= number_format($totalPeek) ?></td>
        </tr>
        <tr>
          <td>❄️ <strong>Freeze (+Moves) Boosters</strong></td>
          <td style="text-align: right; font-weight: 600;"><?= number_format($totalFreeze) ?></td>
        </tr>
        <tr>
          <td>🪄 <strong>Magic Wand Boosters</strong></td>
          <td style="text-align: right; font-weight: 600;"><?= number_format($totalWand) ?></td>
        </tr>
        <tr>
          <td>🔀 <strong>Shuffle Boosters</strong></td>
          <td style="text-align: right; font-weight: 600;"><?= number_format($totalShuffle) ?></td>
        </tr>
      </tbody>
    </table>
  </div>

  <!-- Campaign Progress Distribution -->
  <div class="content-section" style="margin-bottom: 0;">
    <div class="section-header">
      <h2 class="section-title">🗺️ Campaign World Player Spread</h2>
      <a href="leaderboard.php" class="btn btn-sm btn-primary">View Leaderboard</a>
    </div>

    <table class="data-table">
      <tbody>
        <tr>
          <td>🌿 <strong>World 1: Neon Meadow</strong> (Lvl 1–12)</td>
          <td style="text-align: right; font-weight: 700; color: var(--accent-emerald);"><?= number_format($world1) ?> Players</td>
        </tr>
        <tr>
          <td>🏙️ <strong>World 2: Cyber City</strong> (Lvl 13–24)</td>
          <td style="text-align: right; font-weight: 700; color: var(--accent-cyan);"><?= number_format($world2) ?> Players</td>
        </tr>
        <tr>
          <td>💎 <strong>World 3: Crystal Caverns</strong> (Lvl 25–36)</td>
          <td style="text-align: right; font-weight: 700; color: #a855f7;"><?= number_format($world3) ?> Players</td>
        </tr>
        <tr>
          <td>🔥 <strong>World 4: Solar Forge</strong> (Lvl 37–48)</td>
          <td style="text-align: right; font-weight: 700; color: #f97316;"><?= number_format($world4) ?> Players</td>
        </tr>
        <tr>
          <td>🌌 <strong>World 5: Cosmic Core</strong> (Lvl 49–60)</td>
          <td style="text-align: right; font-weight: 700; color: var(--accent-rose);"><?= number_format($world5) ?> Players</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<!-- Quick Leaderboard Showcase -->
<div class="content-section">
  <div class="section-header">
    <h2 class="section-title">🏆 Top 5 Champions Showcase</h2>
    <a href="leaderboard.php" class="btn btn-sm btn-primary">View Full Leaderboard →</a>
  </div>

  <table class="data-table">
    <thead>
      <tr>
        <th>Rank</th>
        <th>Player</th>
        <th>Country</th>
        <th>Stars ⭐</th>
        <th>Max Level</th>
        <th>Total Score</th>
      </tr>
    </thead>
    <tbody>
      <?php $rank = 1; foreach ($recentLeaders as $leader): ?>
        <tr>
          <td>
            <?php if ($rank === 1): ?><span class="badge badge-gold">🥇 #1</span>
            <?php elseif ($rank === 2): ?><span class="badge badge-silver">🥈 #2</span>
            <?php elseif ($rank === 3): ?><span class="badge badge-bronze">🥉 #3</span>
            <?php else: ?>#<?= $rank ?><?php endif; ?>
          </td>
          <td><strong><?= htmlspecialchars($leader['username']) ?></strong></td>
          <td><?= $leader['country_flag'] ?></td>
          <td>⭐ <?= number_format($leader['total_stars']) ?></td>
          <td>Level <?= $leader['max_level'] ?></td>
          <td><?= number_format($leader['total_score']) ?> pts</td>
        </tr>
      <?php $rank++; endforeach; ?>
    </tbody>
  </table>
</div>

<?php include __DIR__ . '/footer.php'; ?>
