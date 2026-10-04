#!/bin/bash
set -e
PORTABLE_DIR="$(cd "$(dirname "$0")" && pwd)"
CLUSTER_NAME="u2-coa-local"

echo "🚀 U²-COA Portable – launching from $PORTABLE_DIR"

if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and retry."
    exit 1
fi

docker run --rm --gpus all nvidia/cuda:12.6-runtime-ubuntu22.04 nvidia-smi > /dev/null 2>&1 || {
    echo "❌ NVIDIA GPU not accessible from Docker. Install nvidia-container-toolkit."
    exit 1
}

if ! command -v k3d &> /dev/null; then
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "🛠️  Creating k3d cluster '$CLUSTER_NAME'..."
    k3d cluster create "$CLUSTER_NAME" \
        --volume "$PORTABLE_DIR/cluster/k3s:/var/lib/rancher/k3s" \
        --port "80:80@loadbalancer" \
        --port "3478:3478@loadbalancer" \
        --gpus all
else
    echo "♻️  Cluster '$CLUSTER_NAME' already exists."
fi

if [ ! -f "$PORTABLE_DIR/images/dlc-standard.tar" ]; then
    echo "❌ Image archive not found at images/dlc-standard.tar. Run build.sh first."
    exit 1
fi

echo "📦 Loading container image..."
k3d image import -c "$CLUSTER_NAME" "$PORTABLE_DIR/images/dlc-standard.tar"

echo "📋 Deploying face-swap services..."
kubectl config use-context "k3d-$CLUSTER_NAME"
kubectl apply -f "$PORTABLE_DIR/kubernetes/"

echo "⏳ Waiting for deployment and TensorRT engine compilation (up to 15 minutes)..."
SECONDS=0
while true; do
    if kubectl -n dlc get pods -l app=dlc-standard --no-headers | grep -q Running; then
        # Check health endpoint
        if curl -s --max-time 2 http://localhost:80/api/health | grep -q '"status":"ok"'; then
            echo ""
            echo "✅ U²-COA is LIVE!"
            echo "   Open in browser: http://localhost"
            echo "   Stop with:        $PORTABLE_DIR/stop.sh"
            exit 0
        fi
    fi
    if [ $SECONDS -gt 900 ]; then
        echo "❌ Timeout waiting for service to become healthy. Check logs with:"
        echo "   kubectl -n dlc logs deployment/dlc-standard"
        exit 1
    fi
    sleep 10
done
