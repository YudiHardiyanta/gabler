#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER CodeIgniter 4 Project Creator"
printf "Masukkan nama app CodeIgniter: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: ci-app"
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
echo "Membuat project CodeIgniter 4: $APP_NAME"
docker compose exec -T php sh -lc "cd /var/www/html && composer create-project codeigniter4/appstarter '$APP_NAME'"

echo
echo "Mengatur file .env CodeIgniter..."
docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && cp env .env && php -r '\$p=\".env\"; \$c=file_get_contents(\$p); \$r=[\"/^# CI_ENVIRONMENT = production/m\"=>\"CI_ENVIRONMENT = development\", \"/^# app.baseURL = '\\''\\''/m\"=>\"app.baseURL = '\\''http://localhost:8080/$APP_NAME/public/'\\''\", \"/^# database.default.hostname = localhost/m\"=>\"database.default.hostname = mysql\", \"/^# database.default.database = ci4/m\"=>\"database.default.database = appdb\", \"/^# database.default.username = root/m\"=>\"database.default.username = appuser\", \"/^# database.default.password = root/m\"=>\"database.default.password = apppass\", \"/^# database.default.DBDriver = MySQLi/m\"=>\"database.default.DBDriver = MySQLi\", \"/^# database.default.port = 3306/m\"=>\"database.default.port = 3306\"]; foreach(\$r as \$k=>\$v){ \$c=preg_replace(\$k,\$v,\$c); } file_put_contents(\$p,\$c);'"

echo
echo "Mengatur permission writable..."
docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && chmod -R 777 writable"

echo
printf "Jalankan migration sekarang? (y/n): "
read -r RUN_MIGRATE
if [ "$RUN_MIGRATE" = "y" ] || [ "$RUN_MIGRATE" = "Y" ]; then
  docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && php spark migrate"
fi

echo
echo "CodeIgniter app berhasil dibuat."
echo "URL: http://localhost:8080/$APP_NAME/public/"
echo "Folder: www/$APP_NAME"
