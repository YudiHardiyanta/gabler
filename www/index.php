<?php
$host = 'mysql';
$db = 'appdb';
$user = 'appuser';
$pass = 'apppass';
$mongoDb = 'appdb';
$mongoUri = 'mongodb://root:rootpass@mongodb:27017/?authSource=admin';
$redisHost = 'redis';
$redisPort = 6379;
$appVersion = '1.3.0';
$year = date('Y');
$mongoCollections = [];
$mongoMessage = null;
$mongoMessageType = 'success';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $dbStatus = 'MySQL connected';
    $dbReady = true;
} catch (Throwable $e) {
    $dbStatus = 'MySQL not ready: ' . $e->getMessage();
    $dbReady = false;
}

if (!extension_loaded('mongodb')) {
    $mongoStatus = 'MongoDB extension not installed';
    $mongoReady = false;
} else {
    try {
        $mongoManager = new MongoDB\Driver\Manager($mongoUri);

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'create_collection') {
            $collectionName = trim((string) ($_POST['collection_name'] ?? ''));

            if ($collectionName === '') {
                $mongoMessage = 'Nama collection tidak boleh kosong.';
                $mongoMessageType = 'error';
            } elseif (!preg_match('/^[A-Za-z0-9_-]+$/', $collectionName)) {
                $mongoMessage = 'Nama collection hanya boleh berisi huruf, angka, strip, dan underscore.';
                $mongoMessageType = 'error';
            } else {
                try {
                    $mongoManager->executeCommand($mongoDb, new MongoDB\Driver\Command([
                        'create' => $collectionName,
                    ]));
                    $mongoMessage = 'Collection "' . $collectionName . '" berhasil dibuat.';
                } catch (Throwable $e) {
                    $mongoMessage = 'Collection gagal dibuat: ' . $e->getMessage();
                    $mongoMessageType = 'error';
                }
            }
        }

        $mongoManager->executeCommand('admin', new MongoDB\Driver\Command(['ping' => 1]));
        $collections = $mongoManager->executeCommand($mongoDb, new MongoDB\Driver\Command([
            'listCollections' => 1,
        ]));

        foreach ($collections as $collection) {
            $mongoCollections[] = $collection->name;
        }

        sort($mongoCollections);
        $mongoStatus = 'MongoDB connected';
        $mongoReady = true;
    } catch (Throwable $e) {
        $mongoStatus = 'MongoDB not ready: ' . $e->getMessage();
        $mongoReady = false;
    }
}

if (!extension_loaded('redis')) {
    $redisStatus = 'Redis extension not installed';
    $redisReady = false;
} else {
    try {
        $redis = new Redis();
        $redis->connect($redisHost, $redisPort, 1.5);
        $redisStatus = $redis->ping() ? 'Redis connected' : 'Redis not ready';
        $redisReady = $redisStatus === 'Redis connected';
        $redis->close();
    } catch (Throwable $e) {
        $redisStatus = 'Redis not ready: ' . $e->getMessage();
        $redisReady = false;
    }
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
        <section class="w-full max-w-4xl text-center">
            <div class="mb-6 inline-flex items-center rounded-full border border-cyan-400/30 bg-cyan-400/10 px-4 py-2 text-sm font-medium text-cyan-200">
                Local Development Stack
            </div>

            <h1 class="text-5xl font-bold tracking-tight text-white sm:text-6xl">GABLER</h1>
            <p class="mt-4 text-lg font-semibold text-cyan-100">General App Backend Local Environment Runner</p>
            <p class="mx-auto mt-4 max-w-xl text-base leading-7 text-slate-300">
                Environment lokal untuk PHP, Nginx, MySQL, MongoDB, Redis, phpMyAdmin, mongo-express, dan Redis Commander.
                Edit file web di folder <code class="rounded bg-white/10 px-1.5 py-0.5 text-cyan-100">www</code>.
            </p>

            <div class="mt-8 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
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
                <div class="rounded-lg border border-white/10 bg-white/5 p-4">
                    <p class="text-sm text-slate-400">MongoDB</p>
                    <p class="mt-1 text-lg font-semibold <?= $mongoReady ? 'text-emerald-300' : 'text-rose-300' ?>">
                        <?= htmlspecialchars($mongoStatus, ENT_QUOTES, 'UTF-8') ?>
                    </p>
                </div>
                <div class="rounded-lg border border-white/10 bg-white/5 p-4">
                    <p class="text-sm text-slate-400">Redis</p>
                    <p class="mt-1 text-lg font-semibold <?= $redisReady ? 'text-emerald-300' : 'text-rose-300' ?>">
                        <?= htmlspecialchars($redisStatus, ENT_QUOTES, 'UTF-8') ?>
                    </p>
                </div>
            </div>

            <div class="mt-8 flex flex-wrap justify-center gap-3">
                <a class="inline-flex items-center justify-center rounded-md bg-cyan-400 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-cyan-300" href="http://localhost:8081">
                    Buka phpMyAdmin
                </a>
                <a class="inline-flex items-center justify-center rounded-md bg-emerald-400 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-emerald-300" href="http://localhost:8082">
                    Buka mongo-express
                </a>
                <a class="inline-flex items-center justify-center rounded-md bg-amber-300 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-amber-200" href="http://localhost:8083">
                    Buka Redis Commander
                </a>
            </div>

            <div class="mt-8 rounded-lg border border-white/10 bg-white/5 p-5 text-left">
                <div class="flex flex-col gap-1 sm:flex-row sm:items-end sm:justify-between">
                    <div>
                        <p class="text-sm text-slate-400">MongoDB database</p>
                        <h2 class="text-xl font-semibold text-white"><?= htmlspecialchars($mongoDb, ENT_QUOTES, 'UTF-8') ?></h2>
                    </div>
                    <form class="mt-4 flex gap-2 sm:mt-0" method="post">
                        <input type="hidden" name="action" value="create_collection">
                        <input class="w-full rounded-md border border-white/10 bg-slate-950 px-3 py-2 text-sm text-white outline-none placeholder:text-slate-500 focus:border-cyan-300 sm:w-52" name="collection_name" placeholder="nama_collection">
                        <button class="rounded-md bg-cyan-400 px-4 py-2 text-sm font-semibold text-slate-950 transition hover:bg-cyan-300" type="submit">
                            Buat
                        </button>
                    </form>
                </div>

                <?php if ($mongoMessage !== null): ?>
                    <p class="mt-4 rounded-md px-3 py-2 text-sm <?= $mongoMessageType === 'success' ? 'bg-emerald-400/10 text-emerald-200' : 'bg-rose-400/10 text-rose-200' ?>">
                        <?= htmlspecialchars($mongoMessage, ENT_QUOTES, 'UTF-8') ?>
                    </p>
                <?php endif; ?>

                <div class="mt-4">
                    <p class="text-sm font-medium text-slate-300">Collections</p>
                    <?php if (!$mongoReady): ?>
                        <p class="mt-2 text-sm text-slate-500">Collection belum bisa dibaca karena MongoDB belum siap.</p>
                    <?php elseif ($mongoCollections === []): ?>
                        <p class="mt-2 text-sm text-slate-500">Belum ada collection.</p>
                    <?php else: ?>
                        <div class="mt-3 flex flex-wrap gap-2">
                            <?php foreach ($mongoCollections as $collectionName): ?>
                                <span class="rounded-full border border-emerald-300/20 bg-emerald-300/10 px-3 py-1 text-sm text-emerald-100">
                                    <?= htmlspecialchars($collectionName, ENT_QUOTES, 'UTF-8') ?>
                                </span>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>

            <footer class="mt-12 text-sm text-slate-500">
                <p>GABLER version <?= htmlspecialchars($appVersion, ENT_QUOTES, 'UTF-8') ?></p>
                <p class="mt-1">Copyright &copy; <?= htmlspecialchars($year, ENT_QUOTES, 'UTF-8') ?> I Komang Yudi Hardiyanta</p>
            </footer>
        </section>
    </main>
</body>
</html>
