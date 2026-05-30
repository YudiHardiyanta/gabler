@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."

echo GABLER Next.js Project Creator
echo.
set /p "APP_NAME=Masukkan nama app Next.js: "

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: next-app
    pause
    exit /b 1
)

if exist "www\%APP_NAME%" (
    echo Folder www\%APP_NAME% sudah ada.
    pause
    exit /b 1
)

docker run --rm -v "%CD%\www:/app" -w /app node:lts-alpine sh -lc "npx create-next-app@latest '%APP_NAME%' --yes --use-npm"
if errorlevel 1 goto error

echo.
echo Next.js app berhasil dibuat.
echo Folder: www\%APP_NAME%
echo Jalankan: cd www\%APP_NAME% lalu ..\npm.bat run dev -- --hostname 0.0.0.0
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
