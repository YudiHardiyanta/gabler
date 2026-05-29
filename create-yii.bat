@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo GABLER Yii3 Project Creator
echo.
set /p "APP_NAME=Masukkan nama app Yii3: "

if "%APP_NAME%"=="" (
    echo Nama app tidak boleh kosong.
    pause
    exit /b 1
)

if not "%APP_NAME: =%"=="%APP_NAME%" (
    echo Nama app tidak boleh mengandung spasi. Gunakan contoh: yii-app
    pause
    exit /b 1
)

if exist "www\%APP_NAME%" (
    echo Folder www\%APP_NAME% sudah ada.
    pause
    exit /b 1
)

echo.
echo Menjalankan service Docker...
docker compose up -d --build
if errorlevel 1 goto error

echo.
echo Membuat project Yii3: %APP_NAME%
docker compose exec -T php sh -lc "cd /var/www/html && composer create-project yiisoft/app '%APP_NAME%'"
if errorlevel 1 goto error

echo.
echo Mengatur file .env Yii3...
copy "www\%APP_NAME%\.env.example" "www\%APP_NAME%\.env" >nul
if errorlevel 1 goto error

echo.
echo Mengatur base URL subfolder Yii3...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$app='%APP_NAME%'; $prefix='/' + $app + '/public'; $params='www\' + $app + '\config\common\params.php'; $c=Get-Content $params -Raw; $c=$c -replace '''@baseUrl''\s*=>\s*''/''', '''@baseUrl'' => ''' + $prefix + ''''; $c=$c -replace '''@assetsUrl''\s*=>\s*''/assets''', '''@assetsUrl'' => ''' + $prefix + '/assets'''; $c=$c -replace '''app''\s*=>\s*\[', '''app'' => [' + [Environment]::NewLine + '        ''prefix'' => ''' + $prefix + ''','; Set-Content -Path $params -Value $c -Encoding UTF8; $subfolder='www\' + $app + '\config\common\subfolder.php'; $s=@('<?php','','declare(strict_types=1);','','use Yiisoft\Aliases\Aliases;','use Yiisoft\Router\UrlGeneratorInterface;','use Yiisoft\Yii\Middleware\SubFolder;','','return [','    SubFolder::class => static function (','        Aliases $aliases,','        UrlGeneratorInterface $urlGenerator,','    ) use ($params) {','        $aliases->set(''@baseUrl'', $params[''app''][''prefix'']);','        $aliases->set(''@assetsUrl'', $params[''app''][''prefix''] . ''/assets'');','','        return new SubFolder(','            $urlGenerator,','            $aliases,','            $params[''app''][''prefix''] === ''/'' ? null : $params[''app''][''prefix''],','        );','    },','];'); Set-Content -Path $subfolder -Value $s -Encoding UTF8"
if errorlevel 1 goto error

echo.
echo Mengatur permission runtime dan assets...
docker compose exec -T php sh -lc "cd /var/www/html/%APP_NAME% && chmod -R 777 runtime public/assets"
if errorlevel 1 goto error

echo.
echo Yii3 app berhasil dibuat.
echo URL: http://localhost:8080/%APP_NAME%/public/
echo Folder: www\%APP_NAME%
echo.
pause
exit /b 0

:error
echo.
echo Terjadi error. Cek pesan di atas.
pause
exit /b 1
