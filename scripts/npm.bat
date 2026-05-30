@echo off
setlocal

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI\"
set "CURRENT_DIR=%CD%"
set "PROJECT_DIR=%CURRENT_DIR:*www\=%"

if /I "%PROJECT_DIR%"=="%CURRENT_DIR%" (
    echo Jalankan scripts\npm.bat dari folder project di dalam folder www.
    echo Contoh: cd c:\etc\www\nama-project
    exit /b 1
)

set "PROJECT_DIR=%PROJECT_DIR:\=/%"
set "PORT_ARGS=-p 3000:3000 -p 5173:5173"

if "%~1"=="--version" set "PORT_ARGS="
if "%~1"=="-v" set "PORT_ARGS="
if "%~1"=="version" set "PORT_ARGS="

docker run --rm %PORT_ARGS% -v "%ROOT_DIR%www:/app" -w "/app/%PROJECT_DIR%" node:lts-alpine npm %*
