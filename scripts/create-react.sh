#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER React Project Creator"
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

printf "Masukkan nama app React: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: react-app"
    exit 1
    ;;
esac

if [ -e "www/$APP_NAME" ]; then
  echo "Folder www/$APP_NAME sudah ada."
  exit 1
fi

printf "Masukkan port React [5173]: "
read -r APP_PORT
APP_PORT="${APP_PORT:-5173}"

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
echo "Membuat project React: $APP_NAME"
npm create vite@latest "www/$APP_NAME" -- --template react

echo
echo "Install dependency dan membuat package-lock.json..."
cd "www/$APP_NAME"
npm install --package-lock
cd "$ROOT_DIR"

echo
echo "Mengatur script dev/preview ke port $APP_PORT..."
cd "www/$APP_NAME"
npm pkg set scripts.dev="vite --host 0.0.0.0 --port $APP_PORT --strictPort"
npm pkg set scripts.preview="vite preview --host 0.0.0.0 --port $APP_PORT --strictPort"
cd "$ROOT_DIR"

echo
echo "React app berhasil dibuat."
echo "Folder: www/$APP_NAME"
echo "Port: $APP_PORT"
echo "File dibuat: package-lock.json"
echo "Folder dibuat: node_modules"
echo "Jalankan:"
echo "  cd www/$APP_NAME"
echo "  npm run dev"
echo "Akses:"
echo "  http://localhost:$APP_PORT"
