FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt \
    && apt-get update \
    && apt-get install -y --no-install-recommends perl-base zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY app.py /app/
COPY templates/ /app/templates/

EXPOSE 5000

RUN useradd -m appuser && chown appuser:appuser /app
USER appuser

CMD ["python", "app.py"]