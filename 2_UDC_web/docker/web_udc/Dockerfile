# Author: R.Lisovenko
# Date: 22.09.2026
# Description: Docker image for the Universal Data Converter web application.

# Use Python 3.11 on Debian 12.
FROM python:3.11-slim-bookworm

# Prevent Python from creating .pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Send Python output directly to the Docker logs.
ENV PYTHONUNBUFFERED=1

# Application directory inside the container.
WORKDIR /app

# Install Microsoft ODBC Driver 18 for SQL Server
# and unixODBC development libraries required by pyodbc.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        unixodbc-dev \
    && curl -sSL -O https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies first.
# This allows Docker to reuse the dependency layer
# when only application source code changes.
COPY app/requirements.txt /app/requirements.txt

# Install Python dependencies.
RUN python -m pip install --no-cache-dir -r requirements.txt

# Copy the UDC application source code.
COPY app/ /app/

# Flask application port.
EXPOSE 5000

# Start the UDC web application.
CMD ["python", "udc_web_app.py"]