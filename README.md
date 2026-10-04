# U²-COA Portable — Self-Contained Face-Swap Production System

This repository contains all necessary files to build and run a
GPU-accelerated, cloud‑independent, face‑swap system from any
Linux host with an NVIDIA GPU.

## Quick Start

1. **Build the image** (requires a Linux machine with Docker and
   NVIDIA GPU). Run:
   ```bash
   bash build.sh
   ```
   This clones Deep-Live-Cam, builds the container, and exports
   it to `images/dlc-standard.tar`.

2. **Copy the entire folder** to your target machine (any Linux
   host with an NVIDIA GPU, Docker, and `nvidia-container-toolkit`).

3. **Launch**:
   ```bash
   bash start.sh
   ```

4. Open **http://localhost** in a browser.

5. To stop:
   ```bash
   bash stop.sh
   ```

## Requirements

- Ubuntu 22.04 LTS (or similar)
- Docker & NVIDIA Container Toolkit
- k3d (auto‑installed by start.sh if missing)
- An NVIDIA GPU with driver ≥ 550

## Folder Structure

```
.
├── build.sh              # Build & export the container image
├── start.sh              # Launch everything locally
��── stop.sh               # Stop and clean up
├── install-deps.sh       # Install Docker & NVIDIA runtime on target machine
├── docker/
│   └── Dockerfile
├── kubernetes/
│   ├── namespace.yaml
│   ├── dlc-standard-deployment.yaml
│   └── dlc-service.yaml
├── images/               # dlc-standard.tar placed here after build
└── cluster/              # k3s state (persistent)
```

## Workflow

### On Your Development Machine (with GPU)

```bash
git clone https://github.com/pamela795/u2-coa-portable.git
cd u2-coa-portable
bash build.sh
```

This will:
1. Clone Deep-Live-Cam RC6
2. Build the Docker image with GPU support
3. Export it as `images/dlc-standard.tar`

### On Your Target Machine (any Linux with NVIDIA GPU)

1. Optionally run `bash install-deps.sh` to install Docker and NVIDIA Container Toolkit.
2. Copy the entire `u2-coa-portable/` folder to your machine.
3. Run `bash start.sh`.
4. Wait for the service to come up (first run compiles TensorRT engines, ~5-15 minutes).
5. Open http://localhost in a browser.

## Troubleshooting

**Pod won't start?**
```bash
kubectl -n dlc logs deployment/dlc-standard
```

**Health check fails?**
Ensure Deep-Live-Cam's `app.py` exposes `/api/health` endpoint. Check Deep-Live-Cam documentation for your RC version.

**GPU not detected?**
```bash
docker run --rm --gpus all nvidia/cuda:12.6-runtime-ubuntu22.04 nvidia-smi
```

If this fails, reinstall `nvidia-container-toolkit` and restart Docker.

## Notes

- The `cluster/` folder persists k3s state across restarts. Delete it to reset.
- The `images/dlc-standard.tar` is portable and can be moved to any machine.
- TensorRT engines are compiled on first run and cached in the pod's volume.

## License

Understand and follow applicable laws; you are responsible for your own choices.
