# Use a stable version instead of a beta (b1) for reliability
FROM python:3.11-slim-buster

# set work directory
WORKDIR /app

# Install system dependencies
# Using slim-buster reduces image size significantly
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    gcc \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables using the correct key=value syntax
# This fixes the "LegacyKeyValueFormat" warnings from your logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Upgrade pip and install Python dependencies
RUN python -m pip install --no-cache-dir --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose the port
EXPOSE 8000

# Final execution
# We move migrations to the CMD or an entrypoint so they run when the container starts
CMD python manage.py migrate && gunicorn --bind 0.0.0.0:8000 --workers 6 pygoat.wsgi
