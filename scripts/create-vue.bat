@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."

echo GABLER Vue Project Creator
echo.
set /p "APP_NAME=Masukkan nama app Vue: "

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: vue-app
    pause
    exit /b 1
)

if exist "www\%APP_NAME%" (
    echo Folder www\%APP_NAME% sudah ada.
    pause
    exit /b 1
)

docker run --rm -it -v "%CD%\www:/app" -w /app node:lts-alpine sh -lc "npm create vue@latest '%APP_NAME%' -- --default && cd '%APP_NAME%' && npm install"
if errorlevel 1 goto error

echo.
echo Vue app berhasil dibuat.
echo Folder: www\%APP_NAME%
echo Jalankan: cd www\%APP_NAME% lalu ..\..\scripts\npm.bat run dev -- --host 0.0.0.0
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
