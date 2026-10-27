<?php
// backend/admin/api_diagnostics.php

$activePage = 'api_diagnostics';
$pageTitle = 'API Diagnostics & Test Bench';
$pageSubtitle = 'Live endpoint health checker, network probes & response tester';

include __DIR__ . '/header.php';

// Check DB Latency
$start = microtime(true);
$pdo->query("SELECT 1");
$dbLatency = round((microtime(true) - $start) * 1000, 2);
?>

<!-- Server Health Status -->
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(16, 185, 129, 0.15); color: var(--accent-emerald);">🟢</div>
    <div class="stat-info">
      <h3>MySQL Status</h3>
      <div class="value" style="color: var(--accent-emerald);">Connected (<?= $dbLatency ?>ms)</div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(6, 182, 212, 0.15); color: var(--accent-cyan);">🐘</div>
    <div class="stat-info">
      <h3>PHP Version</h3>
      <div class="value"><?= phpversion() ?></div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon" style="background: rgba(139, 92, 246, 0.15); color: var(--accent-purple);">🌐</div>
    <div class="stat-info">
      <h3>API Base URL</h3>
      <div class="value" style="font-size: 16px;"><code>/pickyx_api/</code></div>
    </div>
  </div>
</div>

<!-- Interactive Test Bench -->
<div class="content-section">
  <div class="section-header">
    <h2 class="section-title">🧪 Live Endpoint Tester</h2>
    <span style="font-size: 13px; color: var(--text-muted);">Click any button below to execute a real-time request to the API</span>
  </div>

  <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px;">
    <button class="btn btn-primary" onclick="runApiTest('../api/leaderboard/global.php')">GET Global Leaderboard</button>
    <button class="btn btn-primary" onclick="runApiTest('../api/leaderboard/country.php?country_code=NG')">GET Nigeria Leaderboard</button>
    <button class="btn btn-primary" onclick="runApiTest('../api/leaderboard/country.php?country_code=US')">GET USA Leaderboard</button>
    <button class="btn btn-primary" onclick="runApiTest('../api/energy/sync_lives.php', 'POST', {action: 'check'})">POST Life Energy Check</button>
    <button class="btn btn-primary" onclick="runApiTest('../api/retention/daily_reward.php', 'POST', {action: 'check'})">POST Daily Reward Check</button>
  </div>

  <div style="background: #080c14; border: 1px solid var(--border-color); border-radius: 8px; padding: 16px;">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; border-bottom: 1px solid rgba(255,255,255,0.05); padding-bottom: 8px;">
      <span style="font-size: 12px; color: var(--text-muted); text-transform: uppercase; font-weight: 600;" id="requestInfo">Endpoint Response Console</span>
      <span id="responseStatus" class="badge" style="display: none;"></span>
    </div>
    <pre id="jsonOutput" style="color: #38bdf8; font-family: Consolas, Monaco, monospace; font-size: 13px; max-height: 400px; overflow-y: auto; white-space: pre-wrap;">Select an endpoint above to run diagnostics...</pre>
  </div>
</div>

<!-- Endpoints Documentation Grid -->
<div class="content-section">
  <div class="section-header">
    <h2 class="section-title">🔌 Picky X API Reference</h2>
  </div>

  <table class="data-table">
    <thead>
      <tr>
        <th>Method</th>
        <th>Endpoint</th>
        <th>Purpose</th>
        <th>Auth Required</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><span class="badge" style="background: rgba(6, 182, 212, 0.2); color: var(--accent-cyan);">POST</span></td>
        <td><code>/api/auth/login.php</code></td>
        <td>Device handshake, login and registration</td>
        <td>No</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(16, 185, 129, 0.2); color: var(--accent-emerald);">GET</span></td>
        <td><code>/api/leaderboard/global.php</code></td>
        <td>Fetch Top 50 global ranking podium</td>
        <td>Optional</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(16, 185, 129, 0.2); color: var(--accent-emerald);">GET</span></td>
        <td><code>/api/leaderboard/country.php</code></td>
        <td>Fetch Top 50 national ranking (NG, US, GB, etc.)</td>
        <td>Optional</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(6, 182, 212, 0.2); color: var(--accent-cyan);">POST</span></td>
        <td><code>/api/leaderboard/submit_score.php</code></td>
        <td>Submit level victory & update star stats</td>
        <td>Yes</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(6, 182, 212, 0.2); color: var(--accent-cyan);">POST</span></td>
        <td><code>/api/sync/save_progress.php</code></td>
        <td>Full snapshot cloud save (levels, wallet, energy)</td>
        <td>Yes</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(16, 185, 129, 0.2); color: var(--accent-emerald);">GET</span></td>
        <td><code>/api/sync/get_player_data.php</code></td>
        <td>Fetch cloud save recovery snapshot</td>
        <td>Yes</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(6, 182, 212, 0.2); color: var(--accent-cyan);">POST</span></td>
        <td><code>/api/energy/sync_lives.php</code></td>
        <td>Server-authoritative 20-min energy timer</td>
        <td>Yes</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(6, 182, 212, 0.2); color: var(--accent-cyan);">POST</span></td>
        <td><code>/api/store/verify_purchase.php</code></td>
        <td>Record IAP transaction & grant perks/VIP</td>
        <td>Yes</td>
      </tr>
      <tr>
        <td><span class="badge" style="background: rgba(6, 182, 212, 0.2); color: var(--accent-cyan);">POST</span></td>
        <td><code>/api/retention/daily_reward.php</code></td>
        <td>Validate 7-day daily check-in against server date</td>
        <td>Yes</td>
      </tr>
    </tbody>
  </table>
</div>

<script>
async function runApiTest(url, method = 'GET', body = null) {
  const output = document.getElementById('jsonOutput');
  const info = document.getElementById('requestInfo');
  const statusBadge = document.getElementById('responseStatus');

  info.textContent = `${method} ${url}`;
  output.textContent = 'Sending request...';
  statusBadge.style.display = 'none';

  try {
    const opts = {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-Device-Id': 'dev_test_device_99'
      }
    };
    if (body) {
      opts.body = JSON.stringify(body);
    }

    const res = await fetch(url, opts);
    const data = await res.json();
    
    statusBadge.style.display = 'inline-block';
    statusBadge.textContent = `HTTP ${res.status}`;
    statusBadge.style.background = res.ok ? 'rgba(16, 185, 129, 0.2)' : 'rgba(244, 63, 94, 0.2)';
    statusBadge.style.color = res.ok ? 'var(--accent-emerald)' : 'var(--accent-rose)';

    output.textContent = JSON.stringify(data, null, 2);
  } catch (err) {
    statusBadge.style.display = 'inline-block';
    statusBadge.textContent = 'ERROR';
    statusBadge.style.background = 'rgba(244, 63, 94, 0.2)';
    statusBadge.style.color = 'var(--accent-rose)';
    output.textContent = `Network Error: ${err.message}`;
  }
}
</script>

<?php include __DIR__ . '/footer.php'; ?>
