<?php
// backend/admin/header.php

// Configure secure session cookie settings before starting session
if (session_status() === PHP_SESSION_NONE) {
    $isSecure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ||
                (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == 443);

    session_set_cookie_params([
        'lifetime' => 0,
        'path'     => '/',
        'domain'   => '',
        'secure'   => $isSecure,
        'httponly' => true,
        'samesite' => 'Lax'
    ]);
    session_start();
}

require_once __DIR__ . '/../config/database.php';

// Strict session check: Redirect unauthenticated requests to login page
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header('Location: index.php?error=unauthorized');
    exit;
}

// Ensure CSRF token is available in session
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
$csrfToken = $_SESSION['csrf_token'];

$pdo = Database::getConnection();
if (!isset($pageTitle)) {
    $pageTitle = 'Control Center';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= htmlspecialchars($pageTitle) ?> - Picky X Admin</title>
  <link rel="stylesheet" href="admin.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

  <!-- Shared Sidebar -->
  <?php include __DIR__ . '/sidebar.php'; ?>

  <!-- Main Content Wrapper -->
  <main class="main-content">
    <header class="header">
      <div>
        <h1><?= htmlspecialchars($pageTitle) ?></h1>
        <p style="color: var(--text-muted); font-size: 14px; margin-top: 4px;">
          <?= htmlspecialchars($pageSubtitle ?? 'Picky X LiveOps & Backend Control') ?>
        </p>
      </div>
      <div style="display: flex; align-items: center; gap: 12px;">
        <span class="badge badge-vip" style="font-size: 13px; padding: 6px 12px;">👑 <?= htmlspecialchars($_SESSION['admin_user'] ?? 'Administrator') ?></span>
      </div>
    </header>

    <?php if (isset($_GET['msg'])): ?>
      <div style="background: rgba(16, 185, 129, 0.15); border: 1px solid var(--accent-emerald); color: #a7f3d0; padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; font-weight: 500;">
        ✔ <?= htmlspecialchars($_GET['msg']) ?>
      </div>
    <?php endif; ?>
