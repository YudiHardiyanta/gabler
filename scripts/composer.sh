#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CURRENT_DIR="$(pwd)"

case "$CURRENT_DIR" in
  "$ROOT_DIR"/www/*) ;;
  *)
    echo "Jalankan scripts/composer.sh dari folder project di dalam folder www."
    echo "Contoh: cd /path/to/gabler/www/nama-project"
    exit 1
    ;;
esac

PROJECT_DIR="${CURRENT_DIR#"$ROOT_DIR"/www/}"

docker compose -f "$ROOT_DIR/docker-compose.yml" up -d --build php
docker compose -f "$ROOT_DIR/docker-compose.yml" exec php sh -lc "cd /var/www/html/$PROJECT_DIR && composer $*"
