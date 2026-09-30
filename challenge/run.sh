#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="spiral_chall"

# Cleanup function to force-remove container on exit or interrupt
cleanup() {
    echo -e "\n[*] Cleaning up container resources..."
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
}

# Trap SIGINT, SIGTERM, and normal EXIT to ensure cleanup runs
trap cleanup EXIT INT TERM

# 1. Run build script to compile binary and extract glibc/ld artifacts
cd "$SCRIPT_DIR/build"
./build.sh

# 2. Build the runtime challenge container
cd "$SCRIPT_DIR"
docker build --platform linux/arm64 -t spiral .

# 3. Run the challenge container dynamically
docker run --rm --platform linux/arm64 -p 10000:10000 --name "$CONTAINER_NAME" spiral