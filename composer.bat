@echo off
setlocal

set "CURRENT_DIR=%CD%"

docker run --rm -it -v "%CURRENT_DIR%:/app" composer %*
