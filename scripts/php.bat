@echo off
setlocal

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI\"
for %%I in ("%ROOT_DIR%www") do set "WWW_DIR=%%~fI"
set "CURRENT_DIR=%CD%"
for %%I in ("%CURRENT_DIR%") do set "CURRENT_DIR=%%~fI"

if /I "%CURRENT_DIR%"=="%WWW_DIR%" (
    set "CONTAINER_DIR=/var/www/html"
) else (
    set "PROJECT_DIR=%CURRENT_DIR:*www\=%"
    if /I "%PROJECT_DIR%"=="%CURRENT_DIR%" (
        echo Jalankan scripts\php.bat dari folder www atau folder project di dalam www.
        echo Contoh: cd c:\etc\www
        echo Contoh: cd c:\etc\www\nama-project
        exit /b 1
    )

    set "PROJECT_DIR=%PROJECT_DIR:\=/%"
    set "CONTAINER_DIR=/var/www/html/%PROJECT_DIR%"
)

if "%~1"=="" (
    echo Pakai: php.bat [argumen php]
    echo Contoh: php.bat -v
    echo Contoh: php.bat artisan --version
    exit /b 1
)

docker compose -f "%ROOT_DIR%docker-compose.yml" up -d --build php
if errorlevel 1 exit /b 1

docker compose -f "%ROOT_DIR%docker-compose.yml" exec php sh -lc "cd %CONTAINER_DIR% && php %*"
