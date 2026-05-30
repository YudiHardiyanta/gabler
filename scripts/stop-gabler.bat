@echo off
cd /d "%~dp0.."

echo Stopping GABLER services...
docker compose down

echo.
echo GABLER services stopped.
echo Local data folders are kept:
echo - mysql-data
echo - mongodb-data
echo - redis-data
echo.
pause
