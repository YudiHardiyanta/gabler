@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."

echo GABLER React Project Creator
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

set /p "APP_NAME=Masukkan nama app React: "

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: react-app
    pause
    exit /b 1
)

if exist "www\%APP_NAME%" (
    echo Folder www\%APP_NAME% sudah ada.
    pause
    exit /b 1
)

set /p "APP_PORT=Masukkan port React [5173]: "
if "%APP_PORT%"=="" set "APP_PORT=5173"

powershell -NoProfile -ExecutionPolicy Bypass -Command "if ('%APP_PORT%' -notmatch '^[0-9]+$' -or [int]'%APP_PORT%' -lt 1 -or [int]'%APP_PORT%' -gt 65535) { exit 1 }"
if errorlevel 1 (
    echo Port harus angka 1 sampai 65535.
    pause
    exit /b 1
)

echo.
echo Membuat project React: %APP_NAME%
pushd "www"
call npm create vite@latest "%APP_NAME%" -- --template react
if errorlevel 1 (
    popd
    goto error
)
popd

echo.
echo Install dependency dan membuat package-lock.json...
pushd "www\%APP_NAME%"
call npm install --package-lock
if errorlevel 1 (
    popd
    goto error
)
popd

echo.
echo Mengatur script dev/preview ke port %APP_PORT%...
pushd "www\%APP_NAME%"
call npm pkg set scripts.dev="vite --host 0.0.0.0 --port %APP_PORT% --strictPort"
if errorlevel 1 (
    popd
    goto error
)
call npm pkg set scripts.preview="vite preview --host 0.0.0.0 --port %APP_PORT% --strictPort"
if errorlevel 1 (
    popd
    goto error
)
popd

echo.
echo React app berhasil dibuat.
echo Folder: www\%APP_NAME%
echo Port: %APP_PORT%
echo File dibuat: package-lock.json
echo Folder dibuat: node_modules
echo Jalankan:
echo   cd www\%APP_NAME%
echo   npm run dev
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
