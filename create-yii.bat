@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo GABLER Yii3 Project Creator
echo.
set /p APP_NAME=Masukkan nama app Yii3:

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
echo Membuat project Yii3: %APP_NAME%
docker compose exec -T php sh -lc "cd /var/www/html && composer create-project yiisoft/app '%APP_NAME%'"
if errorlevel 1 goto error

echo.
echo Mengatur file .env Yii3...
copy "www\%APP_NAME%\.env.example" "www\%APP_NAME%\.env" >nul
if errorlevel 1 goto error

echo.
echo Mengatur permission runtime dan assets...
docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && chmod -R 777 runtime public/assets"
if errorlevel 1 goto error

echo.
echo Yii3 app berhasil dibuat.
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
