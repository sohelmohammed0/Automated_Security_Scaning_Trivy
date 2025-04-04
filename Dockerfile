FROM python:3.9-slim-bookworm AS builder

WORKDIR /app

# Copy requirements for caching
COPY requirements.txt .

# Install build dependencies and Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM python:3.9-slim-bookworm

WORKDIR /app

# Add security repository and install latest secure packages
RUN apt-get update && \
    echo "deb http://deb.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        perl-base \
        zlib1g \
        liblzma5 && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.9/site-packages/ /usr/local/lib/python3.9/site-packages/

# Copy application files
COPY app.py .
COPY templates/ templates/

# Expose port
EXPOSE 5000

# Run as non-root user
RUN useradd -m appuser && chown appuser:appuser /app
USER appuser

CMD ["python", "app.py"]
