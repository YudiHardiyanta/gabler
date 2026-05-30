#!/usr/bin/env sh
case "$(uname -s 2>/dev/null || true)" in
  MINGW*|MSYS*|CYGWIN*)
    echo "Gunakan ..\\npm.bat di Windows. File .sh hanya untuk Linux/macOS."
    exit 1
    ;;
esac

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
exec "$SCRIPT_DIR/../scripts/npm.sh" "$@"
