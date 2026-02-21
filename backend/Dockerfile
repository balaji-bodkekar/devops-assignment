# ---------- builder ----------
FROM python:3.11-slim-bookworm AS builder

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /src

# copy only requirements first for layer caching
COPY requirements.txt .

# install minimal build deps, upgrade pip, install python packages into /install
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends build-essential ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    python -m pip install --upgrade pip setuptools wheel; \
    pip install --prefix=/install -r requirements.txt

# copy application sources
COPY backend/ /src

# drop ownership to a non-root UID that matches runtime image if needed
RUN mkdir -p /install && chown -R 1000:1000 /install /src


# ---------- runtime ----------
FROM python:3.11-slim-bookworm

# create nonroot group/user matching builder UID and copy app
RUN groupadd -g 1000 nonroot || true && useradd -r -u 1000 -g nonroot nonroot || true
COPY --from=builder /install /usr/local
COPY --from=builder /src /app
COPY requirements.txt /tmp/requirements.txt

# Install runtime requirements to ensure console-scripts and deps are available
RUN python -m pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

WORKDIR /app

ENV PATH=/usr/local/bin:$PATH

# Expose port used by Gunicorn/Uvicorn
EXPOSE 8000

# Ensure we don't inherit a Python entrypoint from base image
ENTRYPOINT []

# ensure installed files are owned by the runtime user
RUN chown -R 1000:1000 /usr/local /app || true

# run as the non-root user and use Gunicorn + Uvicorn workers
USER nonroot
CMD ["/usr/local/bin/gunicorn", "-k", "uvicorn.workers.UvicornWorker", "main:app", "-w", "4", "-b", "0.0.0.0:8000", "--log-level", "info", "--proxy-protocol"]
