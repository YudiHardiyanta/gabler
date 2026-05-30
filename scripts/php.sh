#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CURRENT_DIR="$(pwd)"

case "$CURRENT_DIR" in
  "$ROOT_DIR"/www)
    CONTAINER_DIR="/var/www/html"
    ;;
  "$ROOT_DIR"/www/*)
    PROJECT_DIR="${CURRENT_DIR#"$ROOT_DIR"/www/}"
    CONTAINER_DIR="/var/www/html/$PROJECT_DIR"
    ;;
  *)
    echo "Jalankan scripts/php.sh dari folder www atau folder project di dalam www."
    echo "Contoh: cd /path/to/gabler/www"
    echo "Contoh: cd /path/to/gabler/www/nama-project"
    exit 1
    ;;
esac

if [ "$#" -eq 0 ]; then
  echo "Pakai: php.sh [argumen php]"
  echo "Contoh: php.sh -v"
  echo "Contoh: php.sh artisan --version"
  exit 1
fi

docker compose -f "$ROOT_DIR/docker-compose.yml" up -d --build php
docker compose -f "$ROOT_DIR/docker-compose.yml" exec php sh -lc "cd $CONTAINER_DIR && php $*"
