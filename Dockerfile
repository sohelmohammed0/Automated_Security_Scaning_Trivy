FROM python:3.9-slim

WORKDIR /app

# Copy requirements and install
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py /app/
COPY templates/ /app/templates/

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]