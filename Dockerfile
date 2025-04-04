FROM python:3.9-slim-bookworm

WORKDIR /app

COPY requirements.txt /app/

# Update package lists and install patched versions of vulnerable packages
RUN apt-get update && \
    echo "deb http://deb.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
       perl-base=5.36.0-10+deb12u1 \
       zlib1g=1:1.3.dfsg-3.1 \
       liblzma5=5.6.2-1 \
    && pip install --no-cache-dir -r requirements.txt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY app.py /app/
COPY templates/ /app/templates/

EXPOSE 5000

RUN useradd -m appuser && chown appuser:appuser /app
USER appuser

CMD ["python", "app.py"]