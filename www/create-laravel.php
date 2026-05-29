<?php
set_time_limit(0);

$appName = '';
$errors = [];
$output = [];
$createdUrl = null;

function run_command(string $command, array &$output): int
{
    $output[] = '$ ' . $command;
    exec($command . ' 2>&1', $lines, $code);

    foreach ($lines as $line) {
        $output[] = $line;
    }

    $output[] = 'Exit code: ' . $code;
    $output[] = '';

    return $code;
}

function update_env(string $path, string $appName): void
{
    $content = file_get_contents($path);
    $replacements = [
        '/^APP_URL=.*/m' => 'APP_URL=http://localhost:8080/' . $appName . '/public',
        '/^DB_CONNECTION=.*/m' => 'DB_CONNECTION=mysql',
        '/^DB_HOST=.*/m' => 'DB_HOST=mysql',
        '/^DB_PORT=.*/m' => 'DB_PORT=3306',
        '/^DB_DATABASE=.*/m' => 'DB_DATABASE=appdb',
        '/^DB_USERNAME=.*/m' => 'DB_USERNAME=appuser',
        '/^DB_PASSWORD=.*/m' => 'DB_PASSWORD=apppass',
    ];

    foreach ($replacements as $pattern => $replacement) {
        if (preg_match($pattern, $content)) {
            $content = preg_replace($pattern, $replacement, $content);
        } else {
            $content .= PHP_EOL . $replacement;
        }
    }

    file_put_contents($path, $content);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $appName = trim((string) ($_POST['app_name'] ?? ''));

    if ($appName === '') {
        $errors[] = 'Nama app tidak boleh kosong.';
    } elseif (!preg_match('/^[A-Za-z0-9_-]+$/', $appName)) {
        $errors[] = 'Nama app hanya boleh berisi huruf, angka, strip, dan underscore.';
    } elseif (is_dir(__DIR__ . '/' . $appName)) {
        $errors[] = 'Folder www/' . $appName . ' sudah ada.';
    }

    if ($errors === []) {
        $quotedApp = escapeshellarg($appName);
        $projectDir = '/var/www/html/' . $appName;

        $commands = [
            'cd /var/www/html && COMPOSER_HOME=/tmp/composer composer create-project laravel/laravel ' . $quotedApp,
        ];

        foreach ($commands as $command) {
            if (run_command($command, $output) !== 0) {
                $errors[] = 'Pembuatan project gagal. Cek output di bawah.';
                break;
            }
        }

        if ($errors === []) {
            $envExample = __DIR__ . '/' . $appName . '/.env.example';
            $env = __DIR__ . '/' . $appName . '/.env';

            if (!copy($envExample, $env)) {
                $errors[] = 'Gagal membuat file .env.';
            } else {
                update_env($env, $appName);
            }
        }

        if ($errors === []) {
            $setupCommands = [
                'cd ' . escapeshellarg($projectDir) . ' && php artisan key:generate --force',
                'cd ' . escapeshellarg($projectDir) . ' && chmod -R 777 storage bootstrap/cache && php artisan optimize:clear',
            ];

            foreach ($setupCommands as $command) {
                if (run_command($command, $output) !== 0) {
                    $errors[] = 'Setup Laravel gagal. Cek output di bawah.';
                    break;
                }
            }
        }

        if ($errors === []) {
            $createdUrl = '/' . rawurlencode($appName) . '/public/';
        }
    }
}
?>
<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Laravel - GABLER</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; color: #222; }
        label { display: block; font-weight: bold; margin-bottom: 8px; }
        input { border: 1px solid #bbb; border-radius: 6px; padding: 10px; width: min(360px, 100%); }
        button, .button {
            background: #1f2937;
            border: 0;
            border-radius: 6px;
            color: #fff;
            cursor: pointer;
            display: inline-block;
            margin-top: 14px;
            padding: 10px 14px;
            text-decoration: none;
        }
        .button.secondary { background: #4b5563; margin-left: 8px; }
        .alert { background: #fee2e2; border-radius: 6px; margin: 16px 0; padding: 12px; }
        .success { background: #dcfce7; border-radius: 6px; margin: 16px 0; padding: 12px; }
        pre { background: #111827; border-radius: 6px; color: #f9fafb; overflow: auto; padding: 14px; white-space: pre-wrap; }
        code { background: #f2f2f2; padding: 2px 5px; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>Create Laravel</h1>
    <p>Project akan dibuat di folder <code>www</code> dan dapat diakses melalui <code>http://localhost:8080/nama-app/public/</code>.</p>

    <?php if ($errors !== []): ?>
        <div class="alert">
            <?php foreach ($errors as $error): ?>
                <div><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>

    <?php if ($createdUrl !== null): ?>
        <div class="success">
            Laravel berhasil dibuat:
            <a href="<?= htmlspecialchars($createdUrl, ENT_QUOTES, 'UTF-8') ?>"><?= htmlspecialchars($createdUrl, ENT_QUOTES, 'UTF-8') ?></a>
        </div>
    <?php endif; ?>

    <form method="post">
        <label for="app_name">Nama app Laravel</label>
        <input id="app_name" name="app_name" value="<?= htmlspecialchars($appName, ENT_QUOTES, 'UTF-8') ?>" placeholder="contoh: toko-online" required>
        <br>
        <button type="submit">Create Laravel</button>
        <a class="button secondary" href="/">Kembali</a>
    </form>

    <?php if ($output !== []): ?>
        <h2>Output</h2>
        <pre><?= htmlspecialchars(implode(PHP_EOL, $output), ENT_QUOTES, 'UTF-8') ?></pre>
    <?php endif; ?>
</body>
</html>
