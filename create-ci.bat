@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo GABLER CodeIgniter 4 Project Creator
echo.
set /p APP_NAME=Masukkan nama app CodeIgniter: 

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: ci-app
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
echo Membuat project CodeIgniter 4: %APP_NAME%
docker run --rm -v "%CD%\www:/app" composer create-project codeigniter4/appstarter "%APP_NAME%"
if errorlevel 1 goto error

echo.
echo Mengatur file .env CodeIgniter...
copy "www\%APP_NAME%\env" "www\%APP_NAME%\.env" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='www\%APP_NAME%\.env'; $c=Get-Content $p; $c=$c -replace '^# CI_ENVIRONMENT = production','CI_ENVIRONMENT = development'; $c=$c -replace '^# app.baseURL = ''''','app.baseURL = ''http://localhost:8080/%APP_NAME%/public/'''; $c=$c -replace '^# database.default.hostname = localhost','database.default.hostname = mysql'; $c=$c -replace '^# database.default.database = ci4','database.default.database = appdb'; $c=$c -replace '^# database.default.username = root','database.default.username = appuser'; $c=$c -replace '^# database.default.password = root','database.default.password = apppass'; $c=$c -replace '^# database.default.DBDriver = MySQLi','database.default.DBDriver = MySQLi'; $c=$c -replace '^# database.default.port = 3306','database.default.port = 3306'; Set-Content $p $c"
if errorlevel 1 goto error

echo.
echo Mengatur permission writable...
docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && chmod -R 777 writable"
if errorlevel 1 goto error

echo.
set /p RUN_MIGRATE=Jalankan migration sekarang? (y/n): 
if /i "%RUN_MIGRATE%"=="y" (
    docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && php spark migrate"
    if errorlevel 1 goto error
)

echo.
echo CodeIgniter app berhasil dibuat.
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
