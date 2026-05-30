#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER Vue Project Creator"
printf "Masukkan nama app Vue: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: vue-app"
    exit 1
    ;;
esac

if [ -e "www/$APP_NAME" ]; then
  echo "Folder www/$APP_NAME sudah ada."
  exit 1
fi

docker run --rm -it -v "$ROOT_DIR/www:/app" -w /app node:lts-alpine sh -lc "npm create vue@latest '$APP_NAME' -- --default && cd '$APP_NAME' && npm install"

echo
echo "Vue app berhasil dibuat."
echo "Folder: www/$APP_NAME"
echo "Jalankan: cd www/$APP_NAME lalu ../../scripts/npm.sh run dev -- --host 0.0.0.0"
