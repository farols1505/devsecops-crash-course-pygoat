# 1. Use Bookworm (Debian 12) - the most stable and current version
FROM python:3.11-slim-bookworm

WORKDIR /app

# 2. Fix the apt-get line
# In newer Debian versions, 'dnsutils' is often a virtual package for 'bind9-host' or 'knot-dnsutils'
# Using 'bind9-host' or 'dnsutils' on Bookworm is much more stable.
RUN apt-get update && apt-get install --no-install-recommends -y \
    bind9-host \
    libpq-dev \
    gcc \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Standardize dependency installation
RUN python -m pip install --no-cache-dir --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# 4. Use the JSON array format for CMD to satisfy the warning in your 3rd image
# This also combines the migration and server start safely
CMD ["sh", "-c", "python manage.py migrate && gunicorn --bind 0.0.0.0:8000 --workers 6 pygoat.wsgi"]
