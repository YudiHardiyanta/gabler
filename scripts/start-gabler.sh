#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Starting GABLER services..."
docker compose up -d --build

echo
echo "GABLER is running."
echo "Home:            http://localhost:8080"
echo "phpMyAdmin:      http://localhost:8081"
echo "mongo-express:   http://localhost:8082"
echo "Redis Commander: http://localhost:8083"
