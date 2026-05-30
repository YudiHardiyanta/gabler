#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER Nuxt Project Creator"
printf "Masukkan nama app Nuxt: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: nuxt-app"
    exit 1
    ;;
esac

if [ -e "www/$APP_NAME" ]; then
  echo "Folder www/$APP_NAME sudah ada."
  exit 1
fi

docker run --rm -v "$ROOT_DIR/www:/app" -w /app node:lts-alpine sh -lc "npx nuxi@latest init '$APP_NAME' --packageManager npm && cd '$APP_NAME' && npm install"

echo
echo "Nuxt app berhasil dibuat."
echo "Folder: www/$APP_NAME"
echo "Jalankan: cd www/$APP_NAME lalu ../npm.sh run dev -- --host 0.0.0.0"
