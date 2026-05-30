@echo off
setlocal

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI\"
set "CURRENT_DIR=%CD%"
set "PROJECT_DIR=%CURRENT_DIR:*www\=%"

if /I "%PROJECT_DIR%"=="%CURRENT_DIR%" (
    echo Jalankan scripts\composer.bat dari folder project di dalam folder www.
    echo Contoh: cd c:\etc\www\nama-project
    exit /b 1
)

set "PROJECT_DIR=%PROJECT_DIR:\=/%"

docker compose -f "%ROOT_DIR%docker-compose.yml" up -d --build php
if errorlevel 1 exit /b 1

docker compose -f "%ROOT_DIR%docker-compose.yml" exec php sh -lc "cd /var/www/html/%PROJECT_DIR% && composer %*"
