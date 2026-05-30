@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."

echo GABLER Express Project Creator
echo.
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

docker run --rm -v "%CD%\www:/app" -w /app node:lts-alpine sh -lc "npx express-generator@latest '%APP_NAME%' --no-view && cd '%APP_NAME%' && npm install"
if errorlevel 1 goto error

echo.
echo Express app berhasil dibuat.
echo Folder: www\%APP_NAME%
echo Jalankan: cd www\%APP_NAME% lalu ..\npm.bat start
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
