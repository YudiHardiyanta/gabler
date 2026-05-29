@echo off
setlocal

set "ROOT_DIR=%~dp0"
set "CURRENT_DIR=%CD%"
set "PROJECT_DIR=%CURRENT_DIR:%ROOT_DIR%www\=%"
set "PROJECT_DIR=%PROJECT_DIR:\=/%"

if "%PROJECT_DIR%"=="%CURRENT_DIR%" (
    echo Jalankan composer.bat dari folder project di dalam folder www.
    echo Contoh: cd c:\etc\www\nama-project
    exit /b 1
)

docker compose -f "%ROOT_DIR%docker-compose.yml" up -d --build php
if errorlevel 1 exit /b 1

docker compose -f "%ROOT_DIR%docker-compose.yml" exec php sh -lc "cd /var/www/html/%PROJECT_DIR% && composer %*"
