@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo GABLER Laravel Project Creator
echo.
set /p APP_NAME=Masukkan nama app Laravel: 

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: toko-online
    pause
    exit /b 1
)

if exist "www\%APP_NAME%" (
    echo Folder www\%APP_NAME% sudah ada.
    pause
    exit /b 1
)

echo.
echo Menjalankan service Docker...
docker compose up -d --build
if errorlevel 1 goto error

echo.
echo Membuat project Laravel: %APP_NAME%
docker run --rm -v "%CD%\www:/app" composer create-project laravel/laravel "%APP_NAME%"
if errorlevel 1 goto error

echo.
echo Mengatur file .env Laravel...
copy "www\%APP_NAME%\.env.example" "www\%APP_NAME%\.env" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='www\%APP_NAME%\.env'; $c=Get-Content $p; $c=$c -replace '^APP_URL=.*','APP_URL=http://localhost:8080/%APP_NAME%/public'; $c=$c -replace '^DB_CONNECTION=.*','DB_CONNECTION=mysql'; if($c -match '^DB_HOST='){ $c=$c -replace '^DB_HOST=.*','DB_HOST=mysql' } else { $c += 'DB_HOST=mysql' }; if($c -match '^DB_PORT='){ $c=$c -replace '^DB_PORT=.*','DB_PORT=3306' } else { $c += 'DB_PORT=3306' }; if($c -match '^DB_DATABASE='){ $c=$c -replace '^DB_DATABASE=.*','DB_DATABASE=appdb' } else { $c += 'DB_DATABASE=appdb' }; if($c -match '^DB_USERNAME='){ $c=$c -replace '^DB_USERNAME=.*','DB_USERNAME=appuser' } else { $c += 'DB_USERNAME=appuser' }; if($c -match '^DB_PASSWORD='){ $c=$c -replace '^DB_PASSWORD=.*','DB_PASSWORD=apppass' } else { $c += 'DB_PASSWORD=apppass' }; Set-Content $p $c"
if errorlevel 1 goto error

echo.
echo Generate Laravel application key...
docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && php artisan key:generate --force"
if errorlevel 1 goto error

echo.
echo Mengatur permission storage dan clear cache...
docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && chmod -R 777 storage bootstrap/cache && php artisan optimize:clear"
if errorlevel 1 goto error

echo.
set /p RUN_MIGRATE=Jalankan migration sekarang? (y/n): 
if /i "%RUN_MIGRATE%"=="y" (
    docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && php artisan migrate --force"
    if errorlevel 1 goto error
)

echo.
echo Laravel app berhasil dibuat.
echo URL: http://localhost:8080/%APP_NAME%/public/
echo Folder: www\%APP_NAME%
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
