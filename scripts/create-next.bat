@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."

echo GABLER Next.js Project Creator
echo Menggunakan Node.js lokal, bukan Docker.
echo.

where node >nul 2>nul
if errorlevel 1 (
    echo Node.js belum terinstall atau belum masuk PATH.
    echo Install Node.js terlebih dahulu dari https://nodejs.org/
    pause
    exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
    echo npm belum tersedia. Pastikan Node.js terinstall dengan benar.
    pause
    exit /b 1
)

where npx >nul 2>nul
if errorlevel 1 (
    echo npx belum tersedia. Pastikan Node.js terinstall dengan benar.
    pause
    exit /b 1
)

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

echo.
echo Membuat project Next.js: %APP_NAME%
call npx create-next-app@latest "www\%APP_NAME%" --yes --use-npm
if errorlevel 1 goto error

echo.
echo Next.js app berhasil dibuat.
echo Folder: www\%APP_NAME%
echo Port default: 3000
echo File dibuat: package-lock.json
echo Folder dibuat: node_modules
echo Jalankan:
echo   cd www\%APP_NAME%
echo   npm run dev
echo Akses:
echo   http://localhost:3000
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
