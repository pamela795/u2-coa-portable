# u2-coa-portable/docker/Dockerfile
FROM nvidia/cuda:12.6-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libnvidia-encode-550 \
    python3.11 python3.11-venv python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python3.11 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY deep-live-cam /app
WORKDIR /app

# Install base requirements, then enforce GPU runtime
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir onnxruntime-gpu>=1.18.0

EXPOSE 80/tcp 3478/udp

ENTRYPOINT ["python", "app.py"]
CMD ["--tensorrt"]
