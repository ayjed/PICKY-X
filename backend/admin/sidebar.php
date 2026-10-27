<?php
// backend/admin/sidebar.php
if (!isset($activePage)) {
    $activePage = 'dashboard';
}
?>
<aside class="sidebar">
  <div class="brand">
    <span class="brand-icon">🎮</span>
    <span class="brand-title">Picky X Admin</span>
  </div>

  <ul class="nav-links">
    <li>
      <a href="dashboard.php" class="nav-link <?= $activePage === 'dashboard' ? 'active' : '' ?>">
        <span>📊</span> Analytics Overview
      </a>
    </li>
    <li>
      <a href="leaderboard.php" class="nav-link <?= $activePage === 'leaderboard' ? 'active' : '' ?>">
        <span>🏆</span> Live Leaderboards
      </a>
    </li>
    <li>
      <a href="players.php" class="nav-link <?= $activePage === 'players' ? 'active' : '' ?>">
        <span>👥</span> Player Management
      </a>
    </li>
    <li>
      <a href="transactions.php" class="nav-link <?= $activePage === 'transactions' ? 'active' : '' ?>">
        <span>💳</span> IAP Transactions
      </a>
    </li>
    <li>
      <a href="api_diagnostics.php" class="nav-link <?= $activePage === 'api_diagnostics' ? 'active' : '' ?>">
        <span>🔌</span> API Diagnostics
      </a>
    </li>
  </ul>

  <div style="padding-top: 20px; border-top: 1px solid var(--border-color); font-size: 12px; color: var(--text-muted);">
    <div style="display: flex; align-items: center; gap: 6px;">
      <span style="color: var(--accent-emerald);">🟢</span> <strong>MySQL XAMPP Live</strong>
    </div>
    <div style="margin-top: 6px;">Host: <code>127.0.0.1:3306</code></div>
    <div style="margin-top: 4px;">Database: <code>pickyx_db</code></div>
    <div style="margin-top: 12px;">
      <a href="index.php?logout=1" style="color: var(--accent-rose); text-decoration: none; font-weight: 600;">🚪 Sign Out</a>
    </div>
  </div>
</aside>
