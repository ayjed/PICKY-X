<?php
// backend/admin/leaderboard.php

$activePage = 'leaderboard';
$pageTitle = 'Live Leaderboards';
$pageSubtitle = 'Real-time global and national ranking tables powered by MySQL';

include __DIR__ . '/header.php';

$countryFilter = isset($_GET['country']) ? strtoupper(trim($_GET['country'])) : 'GLOBAL';
$search = isset($_GET['q']) ? trim($_GET['q']) : '';

$countries = [
    'GLOBAL' => ['name' => 'Worldwide (Global)', 'flag' => '🌍'],
    'NG' => ['name' => 'Nigeria', 'flag' => '🇳🇬'],
    'US' => ['name' => 'United States', 'flag' => '🇺🇸'],
    'GB' => ['name' => 'United Kingdom', 'flag' => '🇬🇧'],
    'GH' => ['name' => 'Ghana', 'flag' => '🇬🇭'],
    'CA' => ['name' => 'Canada', 'flag' => '🇨🇦'],
    'JP' => ['name' => 'Japan', 'flag' => '🇯🇵'],
    'DE' => ['name' => 'Germany', 'flag' => '🇩🇪'],
    'IN' => ['name' => 'India', 'flag' => '🇮🇳'],
    'FR' => ['name' => 'France', 'flag' => '🇫🇷'],
    'BR' => ['name' => 'Brazil', 'flag' => '🇧🇷'],
];

$sql = "
    SELECT u.id, u.username, u.country_code, u.country_flag, u.is_vip,
           ls.total_stars, ls.max_level, ls.total_score, ls.updated_at
    FROM leaderboard_scores ls
    JOIN users u ON ls.user_id = u.id
";

$where = [];
$params = [];

if ($countryFilter !== 'GLOBAL' && isset($countries[$countryFilter])) {
    $where[] = "ls.country_code = ?";
    $params[] = $countryFilter;
}

if (!empty($search)) {
    $where[] = "u.username LIKE ?";
    $params[] = "%$search%";
}

if (!empty($where)) {
    $sql .= " WHERE " . implode(" AND ", $where);
}

$sql .= " ORDER BY ls.total_stars DESC, ls.total_score DESC, ls.max_level DESC LIMIT 50";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$players = $stmt->fetchAll();

// Extract Top 3 for Podium
$top1 = $players[0] ?? null;
$top2 = $players[1] ?? null;
$top3 = $players[2] ?? null;
?>

<!-- Country Selector Tabs -->
<div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 24px;">
  <?php foreach ($countries as $code => $info): ?>
    <a href="leaderboard.php?country=<?= $code ?>" 
       class="btn <?= $countryFilter === $code ? 'btn-primary' : '' ?>" 
       style="<?= $countryFilter !== $code ? 'background: var(--bg-card); color: var(--text-muted); border: 1px solid var(--border-color);' : '' ?>">
      <?= $info['flag'] ?> <?= htmlspecialchars($info['name']) ?>
    </a>
  <?php endforeach; ?>
</div>

<!-- Top 3 Podium Cards -->
<?php if ($top1 && empty($search)): ?>
  <div style="display: grid; grid-template-columns: 1fr 1.1fr 1fr; gap: 20px; margin-bottom: 32px; align-items: end;">
    <!-- 2nd Place -->
    <?php if ($top2): ?>
      <div class="stat-card" style="border-top: 4px solid #cbd5e1; flex-direction: column; text-align: center; padding: 24px;">
        <div style="font-size: 32px;">🥈</div>
        <span class="badge badge-silver" style="margin-top: 6px;">Rank #2</span>
        <h3 style="font-size: 18px; margin-top: 8px; color: #fff;"><?= htmlspecialchars($top2['username']) ?> <?= $top2['country_flag'] ?></h3>
        <div style="color: #fbbf24; font-weight: 700; margin-top: 4px;">⭐ <?= number_format($top2['total_stars']) ?> Stars</div>
        <div style="color: var(--text-muted); font-size: 13px;"><?= number_format($top2['total_score']) ?> pts | Lvl <?= $top2['max_level'] ?></div>
      </div>
    <?php else: ?><div></div><?php endif; ?>

    <!-- 1st Place (Winner) -->
    <div class="stat-card" style="border-top: 4px solid #f59e0b; flex-direction: column; text-align: center; padding: 28px; background: rgba(245, 158, 11, 0.1);">
      <div style="font-size: 40px;">👑 🥇</div>
      <span class="badge badge-gold" style="margin-top: 6px;">Champion #1</span>
      <h3 style="font-size: 20px; margin-top: 8px; color: #fff; font-weight: 800;"><?= htmlspecialchars($top1['username']) ?> <?= $top1['country_flag'] ?></h3>
      <div style="color: #fbbf24; font-weight: 800; font-size: 16px; margin-top: 4px;">⭐ <?= number_format($top1['total_stars']) ?> Stars</div>
      <div style="color: var(--text-muted); font-size: 14px;"><?= number_format($top1['total_score']) ?> pts | Level <?= $top1['max_level'] ?></div>
    </div>

    <!-- 3rd Place -->
    <?php if ($top3): ?>
      <div class="stat-card" style="border-top: 4px solid #d97706; flex-direction: column; text-align: center; padding: 24px;">
        <div style="font-size: 32px;">🥉</div>
        <span class="badge badge-bronze" style="margin-top: 6px;">Rank #3</span>
        <h3 style="font-size: 18px; margin-top: 8px; color: #fff;"><?= htmlspecialchars($top3['username']) ?> <?= $top3['country_flag'] ?></h3>
        <div style="color: #fbbf24; font-weight: 700; margin-top: 4px;">⭐ <?= number_format($top3['total_stars']) ?> Stars</div>
        <div style="color: var(--text-muted); font-size: 13px;"><?= number_format($top3['total_score']) ?> pts | Lvl <?= $top3['max_level'] ?></div>
      </div>
    <?php else: ?><div></div><?php endif; ?>
  </div>
<?php endif; ?>

<!-- Leaderboard Table Section -->
<div class="content-section">
  <div class="section-header">
    <h2 class="section-title">
      <?= $countries[$countryFilter]['flag'] ?? '🌍' ?> <?= htmlspecialchars($countries[$countryFilter]['name'] ?? 'Leaderboard') ?>
      <span style="font-size: 14px; color: var(--text-muted); font-weight: 400;">(<?= count($players) ?> Ranked Players)</span>
    </h2>
    <form method="GET" style="display: flex; gap: 8px;">
      <input type="hidden" name="country" value="<?= htmlspecialchars($countryFilter) ?>">
      <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" placeholder="Search player name..." class="search-input">
      <button type="submit" class="btn btn-primary">Search</button>
      <?php if (!empty($search)): ?>
        <a href="leaderboard.php?country=<?= htmlspecialchars($countryFilter) ?>" class="btn" style="background: var(--bg-secondary); color: var(--text-muted);">Clear</a>
      <?php endif; ?>
    </form>
  </div>

  <?php if (empty($players)): ?>
    <div style="text-align: center; padding: 48px; color: var(--text-muted);">
      No players found in this category.
    </div>
  <?php else: ?>
    <table class="data-table">
      <thead>
        <tr>
          <th>Rank</th>
          <th>Player Name</th>
          <th>Country</th>
          <th>Total Stars</th>
          <th>Max Level</th>
          <th>High Score</th>
          <th>Membership</th>
          <th>Last Active</th>
        </tr>
      </thead>
      <tbody>
        <?php $rank = 1; foreach ($players as $p): ?>
          <tr>
            <td>
              <?php if ($rank === 1): ?><span class="badge badge-gold">🥇 #1</span>
              <?php elseif ($rank === 2): ?><span class="badge badge-silver">🥈 #2</span>
              <?php elseif ($rank === 3): ?><span class="badge badge-bronze">🥉 #3</span>
              <?php else: ?>#<?= $rank ?><?php endif; ?>
            </td>
            <td>
              <strong><?= htmlspecialchars($p['username']) ?></strong>
            </td>
            <td><?= $p['country_flag'] ?> <?= htmlspecialchars($p['country_code']) ?></td>
            <td style="color: #fbbf24; font-weight: 700;">⭐ <?= number_format($p['total_stars']) ?></td>
            <td>Level <?= $p['max_level'] ?></td>
            <td style="font-weight: 600;"><?= number_format($p['total_score']) ?> pts</td>
            <td>
              <?php if ($p['is_vip']): ?>
                <span class="badge badge-vip">👑 VIP Club</span>
              <?php else: ?>
                <span style="color: var(--text-muted); font-size: 13px;">Standard</span>
              <?php endif; ?>
            </td>
            <td style="color: var(--text-muted); font-size: 12px;"><?= $p['updated_at'] ?></td>
          </tr>
        <?php $rank++; endforeach; ?>
      </tbody>
    </table>
  <?php endif; ?>
</div>

<?php include __DIR__ . '/footer.php'; ?>
