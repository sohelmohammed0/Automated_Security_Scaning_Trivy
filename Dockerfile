FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt \
    && apt-get update \
    && apt-get install -y perl-base zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY app.py /app/
COPY templates/ /app/templates/

EXPOSE 5000

CMD ["python", "app.py"]