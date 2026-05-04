# Use a minimal Python base image
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy dependency file first (for layer caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY liveliness_probe_app_version.py .

# Expose application port
EXPOSE 8000

# Start FastAPI using uvicorn
CMD ["uvicorn", "liveliness_probe_app_version:app", "--host", "0.0.0.0", "--port", "8000"]
