#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER Next.js Project Creator"
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

printf "Masukkan nama app Next.js: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: next-app"
    exit 1
    ;;
esac

if [ -e "www/$APP_NAME" ]; then
  echo "Folder www/$APP_NAME sudah ada."
  exit 1
fi

printf "Masukkan port Next.js [3000]: "
read -r APP_PORT
APP_PORT="${APP_PORT:-3000}"

case "$APP_PORT" in
  ''|*[!0-9]*)
    echo "Port harus angka 1 sampai 65535."
    exit 1
    ;;
esac

if [ "$APP_PORT" -lt 1 ] || [ "$APP_PORT" -gt 65535 ]; then
  echo "Port harus angka 1 sampai 65535."
  exit 1
fi

echo
echo "Membuat project Next.js: $APP_NAME"
npx create-next-app@latest "www/$APP_NAME" --yes --use-npm

echo
echo "Mengatur script dev/start ke port $APP_PORT..."
node -e "const fs=require('fs'); const p='www/$APP_NAME/package.json'; const pkg=JSON.parse(fs.readFileSync(p,'utf8')); pkg.scripts=pkg.scripts||{}; pkg.scripts.dev='next dev -p $APP_PORT'; pkg.scripts.start='next start -p $APP_PORT'; fs.writeFileSync(p, JSON.stringify(pkg,null,2)+'\n');"

echo
echo "Next.js app berhasil dibuat."
echo "Folder: www/$APP_NAME"
echo "Port: $APP_PORT"
echo "File dibuat: package-lock.json"
echo "Folder dibuat: node_modules"
echo "Jalankan:"
echo "  cd www/$APP_NAME"
echo "  npm run dev"
echo "Akses:"
echo "  http://localhost:$APP_PORT"
