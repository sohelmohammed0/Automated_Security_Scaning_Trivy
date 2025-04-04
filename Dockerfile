FROM python:3.9-slim-bookworm

WORKDIR /app

COPY requirements.txt /app/

RUN apt-get update && \
    echo "deb http://deb.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
       perl-base \
       zlib1g \
    && pip install --no-cache-dir -r requirements.txt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY app.py /app/
COPY templates/ /app/templates/

EXPOSE 5000

RUN useradd -m appuser && chown appuser:appuser /app
USER appuser

CMD ["python", "app.py"]