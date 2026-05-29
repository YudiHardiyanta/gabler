<?php
$host = 'mysql';
$db = 'appdb';
$user = 'appuser';
$pass = 'apppass';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $dbStatus = 'MySQL connected';
} catch (Throwable $e) {
    $dbStatus = 'MySQL not ready: ' . $e->getMessage();
}
?>
<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>GABLER</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; color: #222; }
        code { background: #f2f2f2; padding: 2px 5px; border-radius: 4px; }
        .actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 24px; }
        .button {
            background: #1f2937;
            border-radius: 6px;
            color: #fff;
            display: inline-block;
            padding: 10px 14px;
            text-decoration: none;
        }
        .button:hover { opacity: .9; }
        .note { color: #555; font-size: 14px; margin-top: 12px; }
    </style>
</head>
<body>
    <h1>GABLER berjalan</h1>
    <p><strong>General App Backend Local Environment Runner</strong></p>
    <p>Environment lokal untuk PHP, Nginx, MySQL, dan phpMyAdmin.</p>
    <p>PHP version: <strong><?= PHP_VERSION ?></strong></p>
    <p>Database: <strong><?= htmlspecialchars($dbStatus, ENT_QUOTES, 'UTF-8') ?></strong></p>
    <p>Edit file web di folder <code>www</code>.</p>

    <div class="actions">
        <a class="button" href="http://localhost:8081">Buka phpMyAdmin</a>
        <a class="button" href="/create-laravel.php">Create Laravel</a>
    </div>
    <p class="note">Create Laravel berjalan dari container PHP GABLER dan membuat project baru di folder <code>www</code>.</p>
</body>
</html>
