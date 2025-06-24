# FROM python:3.9

# WORKDIR /app/backend

# COPY requirements.txt /app/backend
# RUN apt-get update \
#     && apt-get upgrade -y \
#     && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
#     && rm -rf /var/lib/apt/lists/*


# # Install app dependencies
# RUN pip install mysqlclient
# RUN pip install --no-cache-dir -r requirements.txt

# COPY . /app/backend

# EXPOSE 8000
#RUN python manage.py migrate
#RUN python manage.py makemigrations
FROM python:3.9

WORKDIR /app/backend

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt /app/backend/

# Install system dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install mysqlclient
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /app/backend/

# Apply database migrations automatically on container start
# Use an entrypoint script to handle this safely
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

# Use Gunicorn in production
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "your_project_name.wsgi:application"]
