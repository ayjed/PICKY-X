<?php
// backend/admin/index.php

session_start();
require_once __DIR__ . '/../config/database.php';

$error = '';

if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header('Location: dashboard.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = trim($_POST['password'] ?? '');

    if (!empty($username) && !empty($password)) {
        try {
            $pdo = Database::getConnection();
            $stmt = $pdo->prepare("SELECT * FROM admin_users WHERE username = ? LIMIT 1");
            $stmt->execute([$username]);
            $admin = $stmt->fetch();

            if ($admin && password_verify($password, $admin['password_hash'])) {
                $_SESSION['admin_logged_in'] = true;
                $_SESSION['admin_user'] = $admin['username'];
                $_SESSION['admin_role'] = $admin['role'];
                header('Location: dashboard.php');
                exit;
            } else {
                $error = 'Invalid admin username or password.';
            }
        } catch (Exception $e) {
            $error = 'Database Error: ' . $e->getMessage();
        }
    } else {
        $error = 'Please enter both username and password.';
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Picky X Admin Portal</title>
  <link rel="stylesheet" href="admin.css">
  <style>
    body {
      display: flex;
      align-items: center;
      justify-content: center;
      background: radial-gradient(circle at top, #1e1b4b 0%, #0a0e17 100%);
    }
    .login-card {
      background: var(--bg-card);
      backdrop-filter: blur(16px);
      border: 1px solid var(--border-color);
      padding: 40px;
      border-radius: 16px;
      width: 100%;
      max-width: 400px;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
    }
    .login-header {
      text-align: center;
      margin-bottom: 28px;
    }
    .form-group {
      margin-bottom: 20px;
    }
    .form-label {
      display: block;
      font-size: 13px;
      color: var(--text-muted);
      margin-bottom: 8px;
    }
    .form-control {
      width: 100%;
      padding: 12px 16px;
      background: var(--bg-secondary);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      color: #fff;
      font-size: 14px;
      outline: none;
    }
    .form-control:focus {
      border-color: var(--accent-cyan);
    }
    .alert-error {
      background: rgba(244, 63, 94, 0.15);
      border: 1px solid var(--accent-rose);
      color: #fecdd3;
      padding: 12px;
      border-radius: 8px;
      font-size: 13px;
      margin-bottom: 20px;
      text-align: center;
    }
    .btn-block {
      width: 100%;
      padding: 12px;
      font-size: 15px;
      justify-content: center;
    }
  </style>
</head>
<body>

  <div class="login-card">
    <div class="login-header">
      <div style="font-size: 40px; margin-bottom: 8px;">🎮</div>
      <h2 style="font-size: 22px; font-weight: 800;">Picky X Control Center</h2>
      <p style="color: var(--text-muted); font-size: 13px; margin-top: 4px;">Backend & LiveOps Administration</p>
    </div>

    <?php if (!empty($error)): ?>
      <div class="alert-error"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>

    <form method="POST">
      <div class="form-group">
        <label class="form-label">Admin Username</label>
        <input type="text" name="username" class="form-control" placeholder="admin" required autofocus>
      </div>
      <div class="form-group">
        <label class="form-label">Admin Password</label>
        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
      </div>
      <button type="submit" class="btn btn-primary btn-block">Sign In to Dashboard</button>
    </form>
  </div>

</body>
</html>
