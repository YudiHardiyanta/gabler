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

echo.
echo Membuat project Express: %APP_NAME%
call npx express-generator@latest "www\%APP_NAME%" --no-view
if errorlevel 1 goto error

echo.
echo Install dependency dan membuat package-lock.json...
pushd "www\%APP_NAME%"
call npm install --package-lock
if errorlevel 1 (
    popd
    goto error
)
popd

echo Menambahkan informasi port di app.js...
call node -e "const fs=require('fs'); const p='www/%APP_NAME%/app.js'; let c=fs.readFileSync(p,'utf8'); const insert=`var app = express();\n\nvar defaultPort = process.env.PORT || '3000';\napp.set('port', defaultPort);\nconsole.log('Express app default port: ' + defaultPort);`; c=c.replace('var app = express();', insert); fs.writeFileSync(p,c);"
if errorlevel 1 goto error

echo.
echo Express app berhasil dibuat.
echo Folder: www\%APP_NAME%
echo Port default: 3000
echo File dibuat: package-lock.json
echo Folder dibuat: node_modules
echo Jalankan:
echo   cd www\%APP_NAME%
echo   npm start
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
