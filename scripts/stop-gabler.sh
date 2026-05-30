#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Stopping GABLER services..."
docker compose down

echo
echo "GABLER services stopped."
echo "Local data folders are kept:"
echo "- mysql-data"
echo "- mongodb-data"
echo "- redis-data"
