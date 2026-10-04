#!/bin/bash
set -e
CLUSTER_NAME="u2-coa-local"
TIMEOUT=900

echo "🔍 U²-COA Validation Harness — Deep‑Live‑Cam 2.7‑RC1"

# 1. Readiness: pod running & GPU visible
kubectl config use-context "k3d-$CLUSTER_NAME"
echo "⏳ Waiting for dlc-standard pod to be Running..."
kubectl -n dlc wait --for=condition=Ready pod -l app=dlc-standard --timeout=${TIMEOUT}s

POD=$(kubectl -n dlc get pods -l app=dlc-standard -o jsonpath='{.items[0].metadata.name}')
echo "✅ Pod $POD is ready"

# Check GPU presence inside container
NVIDIA_SMI_OUT=$(kubectl -n dlc exec "$POD" -- nvidia-smi -L 2>/dev/null || true)
if [[ -n "$NVIDIA_SMI_OUT" ]]; then
    echo "🎮 GPU detected: $NVIDIA_SMI_OUT"
else
    echo "❌ GPU not visible inside container!"
    exit 1
fi

# 2. Liveness: HTTP port responds
echo "🌐 Probing liveness on port 80..."
HTTP_CODE=$(kubectl -n dlc exec "$POD" -- curl -s -o /dev/null -w "%{http_code}" http://localhost:80/ || echo "000")
if [[ "$HTTP_CODE" != "200" ]]; then
    echo "❌ HTTP liveness probe failed (got $HTTP_CODE). Container may still be compiling TensorRT engines."
    echo "   Check pod logs: kubectl -n dlc logs $POD"
    exit 1
fi
echo "✅ HTTP port responds (200 OK)"

# 3. Performance: quick headless swap test
echo "🧪 Running headless face-swap smoke test (30s timeout)..."
kubectl -n dlc exec -i "$POD" -- timeout 30 python app.py \
    --execution-provider cuda \
    --frame-processor face_swapper \
    --source /test-media/source.jpg \
    --target /test-media/target.mp4 \
    --output /test-media/validation-output.mp4 || true

# Check if output was created
if kubectl -n dlc exec "$POD" -- test -f /test-media/validation-output.mp4; then
    SIZE=$(kubectl -n dlc exec "$POD" -- stat -c%s /test-media/validation-output.mp4)
    echo "✅ Smoke test produced output file (size: $SIZE bytes)"
else
    echo "❌ Smoke test failed — no output file generated."
    exit 1
fi

echo ""
echo "🎉 Validation passed. U²-COA is fully operational on your GPU."
