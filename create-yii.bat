@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo GABLER Yii2 Project Creator
echo.
set /p "APP_NAME=Masukkan nama app Yii2: "

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: yii-app
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
echo Membuat project Yii2: %APP_NAME%
docker compose exec -T php sh -lc "cd /var/www/html && composer create-project yiisoft/yii2-app-basic '%APP_NAME%'"
if errorlevel 1 goto error

echo.
echo Mengatur database Yii2...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='www\%APP_NAME%\config\db.php'; $c=@('<?php','','return [','    ''class'' => ''yii\db\Connection'',','    ''dsn'' => ''mysql:host=mysql;dbname=appdb'',','    ''username'' => ''appuser'',','    ''password'' => ''apppass'',','    ''charset'' => ''utf8'',','];'); [System.IO.File]::WriteAllLines($p, $c, [System.Text.UTF8Encoding]::new($false))"
if errorlevel 1 goto error

echo.
echo Mengatur permission runtime dan assets...
docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && chmod -R 777 runtime web/assets"
if errorlevel 1 goto error

echo.
echo Yii2 app berhasil dibuat.
echo URL: http://localhost:8080/%APP_NAME%/web/
echo Folder: www\%APP_NAME%
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
