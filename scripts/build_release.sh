#!/usr/bin/env bash
# Release build wrapper: guarantees a safe, production API_BASE is baked
# into the build instead of relying on remembering --dart-define by hand.
# Defaults to the proven production API (see PROJECT_CONTEXT.md §10);
# override with API_BASE=... only for a different, equally real HTTPS host.
#
# Usage: scripts/build_release.sh apk   (or appbundle / ipa / ...)
set -euo pipefail

API_BASE="${API_BASE:-https://web.goalmasters.online/api/}"

case "$API_BASE" in
  https://*) ;;
  *)
    echo "Refusing to build: API_BASE must be HTTPS (got: $API_BASE)" >&2
    exit 1
    ;;
esac

case "$API_BASE" in
  *127.0.0.1*|*localhost*|*10.0.2.2*|*://10.*|*://192.168.*|*://172.1[6-9].*|*://172.2[0-9].*|*://172.3[01].*)
    echo "Refusing to build: API_BASE looks local/LAN ($API_BASE)" >&2
    exit 1
    ;;
esac

echo "Building release with API_BASE=$API_BASE"
flutter build "$@" --dart-define=API_BASE="$API_BASE"
