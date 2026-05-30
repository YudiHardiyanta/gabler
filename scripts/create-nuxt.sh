#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER Nuxt Project Creator"
echo "Menggunakan Node.js lokal, bukan Docker."
echo

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js belum terinstall atau belum masuk PATH."
  echo "Install Node.js terlebih dahulu dari https://nodejs.org/"
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm belum tersedia. Pastikan Node.js terinstall dengan benar."
  exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "npx belum tersedia. Pastikan Node.js terinstall dengan benar."
  exit 1
fi

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

echo
echo "Membuat project Nuxt: $APP_NAME"
npx nuxi@latest init "www/$APP_NAME" --packageManager npm

echo
echo "Install dependency dan membuat package-lock.json..."
cd "www/$APP_NAME"
npm install --package-lock
cd "$ROOT_DIR"

echo
echo "Nuxt app berhasil dibuat."
echo "Folder: www/$APP_NAME"
echo "Port default: 3000"
echo "File dibuat: package-lock.json"
echo "Folder dibuat: node_modules"
echo "Jalankan:"
echo "  cd www/$APP_NAME"
echo "  npm run dev"
echo "Akses:"
echo "  http://localhost:3000"
