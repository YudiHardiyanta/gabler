<?php
$host = 'mysql';
$db = 'appdb';
$user = 'appuser';
$pass = 'apppass';
$appVersion = '1.0.0';
$year = date('Y');

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $dbStatus = 'MySQL connected';
    $dbReady = true;
} catch (Throwable $e) {
    $dbStatus = 'MySQL not ready: ' . $e->getMessage();
    $dbReady = false;
}
?>
<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>GABLER</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-950 text-slate-100">
    <main class="flex min-h-screen items-center justify-center px-6 py-10">
        <section class="w-full max-w-2xl text-center">
            <div class="mb-6 inline-flex items-center rounded-full border border-cyan-400/30 bg-cyan-400/10 px-4 py-2 text-sm font-medium text-cyan-200">
                Local PHP Development Stack
            </div>

            <h1 class="text-5xl font-bold tracking-tight text-white sm:text-6xl">GABLER</h1>
            <p class="mt-4 text-lg font-semibold text-cyan-100">General App Backend Local Environment Runner</p>
            <p class="mx-auto mt-4 max-w-xl text-base leading-7 text-slate-300">
                Environment lokal untuk PHP, Nginx, MySQL, dan phpMyAdmin.
                Edit file web di folder <code class="rounded bg-white/10 px-1.5 py-0.5 text-cyan-100">www</code>.
            </p>

            <div class="mt-8 grid gap-3 sm:grid-cols-2">
                <div class="rounded-lg border border-white/10 bg-white/5 p-4">
                    <p class="text-sm text-slate-400">PHP version</p>
                    <p class="mt-1 text-lg font-semibold text-white"><?= htmlspecialchars(PHP_VERSION, ENT_QUOTES, 'UTF-8') ?></p>
                </div>
                <div class="rounded-lg border border-white/10 bg-white/5 p-4">
                    <p class="text-sm text-slate-400">Database</p>
                    <p class="mt-1 text-lg font-semibold <?= $dbReady ? 'text-emerald-300' : 'text-rose-300' ?>">
                        <?= htmlspecialchars($dbStatus, ENT_QUOTES, 'UTF-8') ?>
                    </p>
                </div>
            </div>

            <div class="mt-8">
                <a class="inline-flex items-center justify-center rounded-md bg-cyan-400 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-cyan-300" href="http://localhost:8081">
                    Buka phpMyAdmin
                </a>
            </div>

            <footer class="mt-12 text-sm text-slate-500">
                <p>GABLER version <?= htmlspecialchars($appVersion, ENT_QUOTES, 'UTF-8') ?></p>
                <p class="mt-1">Copyright &copy; <?= htmlspecialchars($year, ENT_QUOTES, 'UTF-8') ?> I Komang Yudi Hardiyanta</p>
            </footer>
        </section>
    </main>
</body>
</html>
