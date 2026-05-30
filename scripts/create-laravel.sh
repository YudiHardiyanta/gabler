#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER Laravel Project Creator"
printf "Masukkan nama app Laravel: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: toko-online"
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
echo "Membuat project Laravel: $APP_NAME"
docker compose exec -T php sh -lc "cd /var/www/html && composer create-project laravel/laravel '$APP_NAME'"

echo
echo "Mengatur file .env Laravel..."
docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && cp .env.example .env && php -r '\$p=\".env\"; \$c=file_get_contents(\$p); \$r=[\"/^APP_URL=.*/m\"=>\"APP_URL=http://localhost:8080/$APP_NAME/public\", \"/^DB_CONNECTION=.*/m\"=>\"DB_CONNECTION=mysql\", \"/^DB_HOST=.*/m\"=>\"DB_HOST=mysql\", \"/^DB_PORT=.*/m\"=>\"DB_PORT=3306\", \"/^DB_DATABASE=.*/m\"=>\"DB_DATABASE=appdb\", \"/^DB_USERNAME=.*/m\"=>\"DB_USERNAME=appuser\", \"/^DB_PASSWORD=.*/m\"=>\"DB_PASSWORD=apppass\"]; foreach(\$r as \$k=>\$v){ if(preg_match(\$k,\$c)){ \$c=preg_replace(\$k,\$v,\$c); } else { \$c.=\"\n\".\$v; } } file_put_contents(\$p,\$c);'"

echo
echo "Generate Laravel application key..."
docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && php artisan key:generate --force"

echo
echo "Mengatur permission storage dan clear cache..."
docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && chmod -R 777 storage bootstrap/cache && php artisan optimize:clear"

echo
printf "Jalankan migration sekarang? (y/n): "
read -r RUN_MIGRATE
if [ "$RUN_MIGRATE" = "y" ] || [ "$RUN_MIGRATE" = "Y" ]; then
  docker compose exec -T php sh -lc "cd /var/www/html/$APP_NAME && php artisan migrate --force"
fi

echo
echo "Laravel app berhasil dibuat."
echo "URL: http://localhost:8080/$APP_NAME/public/"
echo "Folder: www/$APP_NAME"
