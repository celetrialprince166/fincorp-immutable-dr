# Stage 1: Build environment
# Base images via the ECR Public mirror (public.ecr.aws) to dodge Docker Hub
# anonymous pull rate limits (HTTP 429) inside CodeBuild.
# PHASE 3: intentionally vulnerable base to prove the scan gate — REVERTED after the demo
# (3.12-slim-bullseye = Debian 11; Debian 11 standard security support ended 2024-08-14,
#  so it carries known HIGH/CRITICAL OS CVEs that ECR basic (Clair) scanning flags.
#  Python stays 3.12 so the venv built here still runs in the runtime stage.)
FROM public.ecr.aws/docker/library/python:3.12-slim-bullseye AS builder

WORKDIR /app

# Install OS dependencies for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY backend/requirements.txt .

# Install dependencies into a virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# --- CodeArtifact proxy (securing-supply-chain control #1) -------------------
# CI passes a pre-rendered pip.conf as a BuildKit secret so pip resolves EVERY
# package (incl. daphne + dj-database-url) through CodeArtifact's pip repo, never
# directly from PyPI. The secret mount keeps the short-lived token out of layers.
# Locally (no secret) pip falls back to public PyPI, so dev laptops still build.
RUN --mount=type=secret,id=pipconf,target=/etc/pip.conf,required=false \
    pip install --no-cache-dir -r requirements.txt \
    daphne \
    dj-database-url

# Stage 2: Runtime environment
# PHASE 3: intentionally vulnerable base to prove the scan gate — REVERTED after the demo
FROM public.ecr.aws/docker/library/python:3.12-slim-bullseye AS runtime

# Set up environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    DJANGO_SETTINGS_MODULE="table_tennis_app.settings"

WORKDIR /app

# Install runtime dependencies ONLY (much smaller than build-essential)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create and switch to non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy virtual environment from builder stage
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv

# Copy application code
COPY --chown=appuser:appuser backend/ .


# Copy entrypoint script
COPY --chown=appuser:appuser docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create necessary directories and set permissions
RUN mkdir -p /app/staticfiles /app/media \
    && chown -R appuser:appuser /app/staticfiles /app/media

USER appuser

# Expose Django port
EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
