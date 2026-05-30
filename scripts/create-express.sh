#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "GABLER Express Project Creator"
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

printf "Masukkan nama app Express: "
read -r APP_NAME

if [ -z "$APP_NAME" ]; then
  echo "Nama app tidak boleh kosong."
  exit 1
fi

case "$APP_NAME" in
  *" "*|*/*|*\\*)
    echo "Nama app tidak boleh mengandung spasi atau slash. Gunakan contoh: express-app"
    exit 1
    ;;
esac

if [ -e "www/$APP_NAME" ]; then
  echo "Folder www/$APP_NAME sudah ada."
  exit 1
fi

printf "Masukkan port Express [3000]: "
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
echo "Membuat project Express: $APP_NAME"
npx express-generator@latest "www/$APP_NAME" --no-view

echo
echo "Install dependency dan membuat package-lock.json..."
cd "www/$APP_NAME"
npm install --package-lock

echo
echo "Mengatur port default ke $APP_PORT..."
node -e "const fs=require('fs'); const p='bin/www'; let c=fs.readFileSync(p,'utf8'); c=c.replace(/process\\.env\\.PORT \\|\\| '3000'/, \"process.env.PORT || '$APP_PORT'\"); fs.writeFileSync(p,c);"

echo "Menambahkan informasi port di app.js..."
node -e "const fs=require('fs'); const p='app.js'; let c=fs.readFileSync(p,'utf8'); c=c.replace('var app = express();', \"var app = express();\\n\\nvar defaultPort = process.env.PORT || '$APP_PORT';\\napp.set('port', defaultPort);\\nconsole.log('Express app default port: ' + defaultPort);\"); fs.writeFileSync(p,c);"

echo
echo "Express app berhasil dibuat."
echo "Folder: www/$APP_NAME"
echo "Port: $APP_PORT"
echo "File dibuat: package-lock.json"
echo "Folder dibuat: node_modules"
echo "Jalankan:"
echo "  cd www/$APP_NAME"
echo "  npm start"
echo "Akses:"
echo "  http://localhost:$APP_PORT"
