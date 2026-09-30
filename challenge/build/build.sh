#!/usr/bin/env bash
set -euo pipefail

# Resolve absolute path to repo root directory regardless of execution context
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_FOLDER="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 1. Build the compilation Docker image
docker build --platform linux/arm64 -t spiral-compile "$SCRIPT_DIR"

# 2. Compile binary and copy shared libraries
docker run --rm --platform linux/arm64 -v "$ROOT_FOLDER:/out" spiral-compile bash -c "
    mkdir -p /out/challenge/solution && \
    gcc -fstack-protector-strong -o /out/challenge/chall /out/challenge/chall.c -lresolv && \
    cp /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /out/challenge/solution/ && \
    cp /usr/lib/aarch64-linux-gnu/libc.so.6 /out/challenge/solution/ && \
    cp /usr/lib/aarch64-linux-gnu/libresolv.so.2 /out/challenge/solution/
"

# 3. Fix permissions on created artifacts
sudo chown "$USER":"$USER" \
    "$ROOT_FOLDER/challenge/chall" \
    "$ROOT_FOLDER/challenge/solution/ld-linux-aarch64.so.1" \
    "$ROOT_FOLDER/challenge/solution/libc.so.6" \
    "$ROOT_FOLDER/challenge/solution/libresolv.so.2"

# 4. Sync artifacts to directories
mkdir -p "$ROOT_FOLDER/downloads"
cp -f "$ROOT_FOLDER/challenge/chall" "$ROOT_FOLDER/downloads/chall"
cp -f "$ROOT_FOLDER/challenge/Dockerfile" "$ROOT_FOLDER/downloads/Dockerfile"
cp -f "$ROOT_FOLDER/challenge/chall" "$ROOT_FOLDER/challenge/solution/chall"

echo "[+] Build completed successfully!"