@echo off
cd /d "%~dp0"

echo Starting GABLER services...
docker compose up -d --build

echo.
echo GABLER is running.
echo Home:       http://localhost:8080
echo phpMyAdmin: http://localhost:8081
echo.
pause
