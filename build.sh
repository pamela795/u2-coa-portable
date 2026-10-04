#!/bin/bash
# u2-coa-portable/build.sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_CONTEXT="$SCRIPT_DIR/docker"
IMAGE_NAME="dlc-standard:latest"
EXPORT_PATH="$SCRIPT_DIR/images/dlc-standard.tar"

echo "🔨 Building U²-COA portable image..."

# 1. Ensure Deep-Live-Cam source is present
if [ ! -d "$DOCKER_CONTEXT/deep-live-cam/.git" ]; then
    echo "📥 Cloning Deep-Live-Cam (RC6 branch)..."
    git clone --branch RC6 https://github.com/hacksider/Deep-Live-Cam.git \
        "$DOCKER_CONTEXT/deep-live-cam"
fi

# 2. Build the Docker image (requires NVIDIA GPU if you want to compile engines now;
#    however, the image itself will compile TensorRT engines at runtime via the CMD)
cd "$DOCKER_CONTEXT"
docker build -t "$IMAGE_NAME" .

# 3. Export for portability
mkdir -p "$(dirname "$EXPORT_PATH")"
echo "📦 Exporting to $EXPORT_PATH ..."
docker save "$IMAGE_NAME" -o "$EXPORT_PATH"

echo "✅ Build complete. Image saved to $EXPORT_PATH"
