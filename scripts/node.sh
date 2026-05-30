#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CURRENT_DIR="$(pwd)"

case "$CURRENT_DIR" in
  "$ROOT_DIR"/www/*) ;;
  *)
    echo "Jalankan scripts/node.sh dari folder project di dalam folder www."
    echo "Contoh: cd /path/to/gabler/www/nama-project"
    exit 1
    ;;
esac

PROJECT_DIR="${CURRENT_DIR#"$ROOT_DIR"/www/}"
PORT_ARGS="-p 3000:3000 -p 5173:5173"

case "${1:-}" in
  --version|-v) PORT_ARGS="" ;;
esac

docker run --rm $PORT_ARGS -v "$ROOT_DIR/www:/app" -w "/app/$PROJECT_DIR" node:lts-alpine node "$@"
