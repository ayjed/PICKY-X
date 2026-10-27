<?php
// backend/admin/transactions.php

$activePage = 'transactions';
$pageTitle = 'IAP Transactions Ledger';
$pageSubtitle = 'Real-time financial audit trail for Google Play in-app purchases & subscriptions';

include __DIR__ . '/header.php';

// Financial Metrics
$totalTx = (int)$pdo->query("SELECT COUNT(*) FROM iap_transactions WHERE status = 'COMPLETED'")->fetchColumn();
$grossRevenue = (float)$pdo->query("SELECT COALESCE(SUM(amount_usd), 0.00) FROM iap_transactions WHERE status = 'COMPLETED'")->fetchColumn();
$avgOrderVal = $totalTx > 0 ? ($grossRevenue / $totalTx) : 0.00;

$search = isset($_GET['q']) ? trim($_GET['q']) : '';
$skuFilter = isset($_GET['sku']) ? trim($_GET['sku']) : 'all';

$sql = "
    SELECT t.id, t.order_id, t.product_id, t.amount_usd, t.status, t.raw_receipt, t.created_at,
           u.id as user_id, u.username, u.country_flag, u.country_code
    FROM iap_transactions t
    JOIN users u ON t.user_id = u.id
";

$where = [];
$params = [];

if (!empty($search)) {
    $where[] = "(t.order_id LIKE ? OR u.username LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

if ($skuFilter !== 'all') {
    $where[] = "t.product_id = ?";
    $params[] = $skuFilter;
}

if (!empty($where)) {
    $sql .= " WHERE " . implode(" AND ", $where);
}

$sql .= " ORDER BY t.id DESC LIMIT 100";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$transactions = $stmt->fetchAll();
?>

<!-- Financial Summary Cards -->
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(16, 185, 129, 0.15); color: var(--accent-emerald);">💵</div>
    <div class="stat-info">
      <h3>Gross Revenue (USD)</h3>
      <div class="value">$<?= number_format($grossRevenue, 2) ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(6, 182, 212, 0.15); color: var(--accent-cyan);">🧾</div>
    <div class="stat-info">
      <h3>Total Transactions</h3>
      <div class="value"><?= number_format($totalTx) ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(245, 158, 11, 0.15); color: var(--accent-gold);">📊</div>
    <div class="stat-info">
      <h3>Average Order Value</h3>
      <div class="value">$<?= number_format($avgOrderVal, 2) ?></div>
    </div>
  </div>
</div>

<!-- Filter Bar -->
<div class="content-section" style="padding: 16px 24px; margin-bottom: 24px;">
  <form method="GET" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
    <div style="flex: 1; min-width: 240px;">
      <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" placeholder="Search by Order ID or Player Name..." class="search-input" style="width: 100%;">
    </div>

    <select name="sku" class="search-input" style="background: var(--bg-secondary); cursor: pointer;">
      <option value="all" <?= $skuFilter === 'all' ? 'selected' : '' ?>>All Products</option>
      <option value="vip_monthly_subscription" <?= $skuFilter === 'vip_monthly_subscription' ? 'selected' : '' ?>>VIP Monthly Subscription ($3.99)</option>
      <option value="remove_ads_permanent" <?= $skuFilter === 'remove_ads_permanent' ? 'selected' : '' ?>>Remove Ads Permanent ($1.99)</option>
      <option value="starter_pack" <?= $skuFilter === 'starter_pack' ? 'selected' : '' ?>>Starter Pack 80% Off ($0.99)</option>
      <option value="gem_vault_1000" <?= $skuFilter === 'gem_vault_1000' ? 'selected' : '' ?>>Gem Vault 1,000 ($9.99)</option>
      <option value="gem_sack_200" <?= $skuFilter === 'gem_sack_200' ? 'selected' : '' ?>>Gem Sack 200 ($2.99)</option>
      <option value="gem_pouch_50" <?= $skuFilter === 'gem_pouch_50' ? 'selected' : '' ?>>Gem Pouch 50 ($0.99)</option>
    </select>

    <button type="submit" class="btn btn-primary">Filter</button>
    <?php if (!empty($search) || $skuFilter !== 'all'): ?>
      <a href="transactions.php" class="btn" style="background: var(--bg-secondary); color: var(--text-muted);">Reset</a>
    <?php endif; ?>
  </form>
</div>

<!-- Transaction Table -->
<div class="content-section">
  <div class="section-header">
    <h2 class="section-title">💳 Purchase Ledger (<?= count($transactions) ?>)</h2>
  </div>

  <?php if (empty($transactions)): ?>
    <div style="text-align: center; padding: 48px; color: var(--text-muted);">
      No in-app purchase transactions recorded yet.
    </div>
  <?php else: ?>
    <table class="data-table">
      <thead>
        <tr>
          <th>Order ID</th>
          <th>Player</th>
          <th>Product SKU</th>
          <th>Amount (USD)</th>
          <th>Status</th>
          <th>Timestamp</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($transactions as $tx): ?>
          <tr>
            <td><code><?= htmlspecialchars($tx['order_id']) ?></code></td>
            <td>
              <?= $tx['country_flag'] ?> <strong><?= htmlspecialchars($tx['username']) ?></strong>
              <span style="font-size: 11px; color: var(--text-muted);">(#<?= $tx['user_id'] ?>)</span>
            </td>
            <td>
              <?php if (str_contains($tx['product_id'], 'vip')): ?>
                <span class="badge badge-vip">👑 <?= htmlspecialchars($tx['product_id']) ?></span>
              <?php else: ?>
                <span class="badge badge-gold"><?= htmlspecialchars($tx['product_id']) ?></span>
              <?php endif; ?>
            </td>
            <td style="font-weight: 700; color: var(--accent-emerald);">$<?= number_format($tx['amount_usd'], 2) ?></td>
            <td>
              <span class="badge" style="background: rgba(16, 185, 129, 0.2); color: var(--accent-emerald);">
                ✔ <?= htmlspecialchars($tx['status']) ?>
              </span>
            </td>
            <td style="color: var(--text-muted); font-size: 13px;"><?= $tx['created_at'] ?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  <?php endif; ?>
</div>

<?php include __DIR__ . '/footer.php'; ?>
