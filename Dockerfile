FROM python:3.9-slim

WORKDIR /app

# Copy requirements first for caching
COPY requirements.txt /app/

# Update package lists and upgrade vulnerable packages
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
       perl-base \
       zlib1g \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY app.py /app/
COPY templates/ /app/templates/

# Expose port
EXPOSE 5000

# Run as non-root user
RUN useradd -m appuser && chown appuser:appuser /app
USER appuser

CMD ["python", "app.py"]
