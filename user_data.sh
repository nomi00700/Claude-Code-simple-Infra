#!/bin/bash
set -e

# Log everything to a file for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting Django application setup at $(date)"

# Update system
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install Python 3 and pip
echo "Installing Python 3 and pip..."
apt-get install -y python3 python3-pip python3-venv

# Install Django with specific version
echo "Installing Django 4.2.7..."
pip3 install django==4.2.7

# Create Django app directory
mkdir -p /home/ubuntu/django-app
cd /home/ubuntu/django-app

# Create Django application file
cat > /home/ubuntu/django-app/app.py << 'EOF'
${django_app}
EOF

# Set Django environment variables
cat > /home/ubuntu/django-app/.env << 'EOF'
DJANGO_SECRET_KEY=${django_secret_key}
DJANGO_ALLOWED_HOSTS=${django_allowed_hosts}
DJANGO_DEBUG=false
EOF

# Make the file executable
chmod +x /home/ubuntu/django-app/app.py

# Create systemd service file for Django
cat > /etc/systemd/system/django-app.service << 'EOF'
[Unit]
Description=Django Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/django-app
EnvironmentFile=/home/ubuntu/django-app/.env
ExecStart=/usr/bin/python3 /home/ubuntu/django-app/app.py runserver 0.0.0.0:8000
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Set proper ownership
chown -R ubuntu:ubuntu /home/ubuntu/django-app

# Enable and start the Django service
systemctl daemon-reload
systemctl enable django-app.service
systemctl start django-app.service

# Check service status and wait for it to be active
echo "Checking Django application service status..."
systemctl status django-app.service

# Wait for the service to be fully active
sleep 10
if systemctl is-active --quiet django-app.service; then
    echo "Django application setup completed successfully at $(date)!"
    echo "Application should be accessible on port 8000"
else
    echo "Django application failed to start properly at $(date)"
    systemctl status django-app.service
    exit 1
fi