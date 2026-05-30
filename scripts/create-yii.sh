#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER Yii2 Project Creator"
printf "Masukkan nama app Yii2: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: yii-app"
    exit 1
    ;;
esac

if [ -e "www/$APP_NAME" ]; then
  echo "Folder www/$APP_NAME sudah ada."
  exit 1
fi

echo
echo "Menjalankan service Docker..."
docker compose up -d --build

echo
echo "Membuat project Yii2: $APP_NAME"
docker compose exec -T php sh -lc "cd /var/www/html && composer create-project yiisoft/yii2-app-basic '$APP_NAME'"

echo
echo "Mengatur database Yii2..."
docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && php -r 'file_put_contents(\"config/db.php\", \"<?php\n\nreturn [\n    '\\''class'\\'' => '\\''yii\\\\db\\\\Connection'\\'',\n    '\\''dsn'\\'' => '\\''mysql:host=mysql;dbname=appdb'\\'',\n    '\\''username'\\'' => '\\''appuser'\\'',\n    '\\''password'\\'' => '\\''apppass'\\'',\n    '\\''charset'\\'' => '\\''utf8'\\'',\n];\n\");'"

echo
echo "Mengatur permission runtime dan assets..."
docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && chmod -R 777 runtime web/assets"

echo
echo "Yii2 app berhasil dibuat."
echo "URL: http://localhost:8080/$APP_NAME/web/"
echo "Folder: www/$APP_NAME"
