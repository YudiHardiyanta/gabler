$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$LaravelPath = Join-Path $Root "www\laravel"
$EnvPath = Join-Path $LaravelPath ".env"
$EnvExamplePath = Join-Path $LaravelPath ".env.example"

Set-Location $Root

function Set-EnvValue {
    param (
        [string] $Path,
        [string] $Key,
        [string] $Value
    )

    $lines = Get-Content $Path
    $pattern = "^$([regex]::Escape($Key))="

    if ($lines -match $pattern) {
        $lines = $lines -replace $pattern + ".*", "$Key=$Value"
    } else {
        $lines += "$Key=$Value"
    }

    Set-Content -Path $Path -Value $lines
}

Write-Host "Starting Docker services..."
docker compose up -d --build

Write-Host "Installing Laravel dependencies..."
$LaravelFullPath = (Resolve-Path $LaravelPath).Path
docker run --rm -v "${LaravelFullPath}:/app" composer install

if (-not (Test-Path $EnvPath)) {
    Write-Host "Creating Laravel .env file..."
    Copy-Item $EnvExamplePath $EnvPath
}

Write-Host "Configuring Laravel .env..."
Set-EnvValue $EnvPath "APP_URL" "http://localhost:8080/laravel/public"
Set-EnvValue $EnvPath "DB_CONNECTION" "mysql"
Set-EnvValue $EnvPath "DB_HOST" "mysql"
Set-EnvValue $EnvPath "DB_PORT" "3306"
Set-EnvValue $EnvPath "DB_DATABASE" "appdb"
Set-EnvValue $EnvPath "DB_USERNAME" "appuser"
Set-EnvValue $EnvPath "DB_PASSWORD" "apppass"

Write-Host "Preparing Laravel..."
docker compose exec -T php sh -lc "cd /var/www/html/laravel && php artisan key:generate --force"
docker compose exec -T php sh -lc "cd /var/www/html/laravel && php artisan migrate --force"
docker compose exec -T php sh -lc "cd /var/www/html/laravel && chmod -R 777 storage bootstrap/cache && php artisan optimize:clear"

Write-Host ""
Write-Host "GABLER is ready."
Write-Host "Home:       http://localhost:8080"
Write-Host "Laravel:    http://localhost:8080/laravel/public/"
Write-Host "phpMyAdmin: http://localhost:8081"
