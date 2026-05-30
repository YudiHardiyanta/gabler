@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."

echo GABLER Express Project Creator
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

set /p "APP_NAME=Masukkan nama app Express: "

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: express-app
    pause
    exit /b 1
)

if exist "www\%APP_NAME%" (
    echo Folder www\%APP_NAME% sudah ada.
    pause
    exit /b 1
)

set /p "APP_PORT=Masukkan port Express [3000]: "
if "%APP_PORT%"=="" set "APP_PORT=3000"

powershell -NoProfile -ExecutionPolicy Bypass -Command "if ('%APP_PORT%' -notmatch '^[0-9]+$' -or [int]'%APP_PORT%' -lt 1 -or [int]'%APP_PORT%' -gt 65535) { exit 1 }"
if errorlevel 1 (
    echo Port harus angka 1 sampai 65535.
    pause
    exit /b 1
)

echo.
echo Membuat project Express: %APP_NAME%
npx express-generator@latest "www\%APP_NAME%" --no-view
if errorlevel 1 goto error

echo.
echo Install dependency...
pushd "www\%APP_NAME%"
npm install
if errorlevel 1 (
    popd
    goto error
)
popd

echo.
echo Mengatur port default ke %APP_PORT%...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='www\%APP_NAME%\bin\www'; $c=Get-Content $p -Raw; $c=$c -replace \"process\.env\.PORT \|\| '3000'\", \"process.env.PORT || '%APP_PORT%'\"; Set-Content $p $c"
if errorlevel 1 goto error

echo.
echo Express app berhasil dibuat.
echo Folder: www\%APP_NAME%
echo Port: %APP_PORT%
echo Jalankan:
echo   cd www\%APP_NAME%
echo   npm start
echo Akses:
echo   http://localhost:%APP_PORT%
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
