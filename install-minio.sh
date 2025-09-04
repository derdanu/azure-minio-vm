#!/bin/bash
set -e

# Variables
MINIO_USER="$1"
MINIO_PASSWORD="$2"
MINIO_DOWNLOAD_URL="$3"

# Download and install MinIO
echo "Downloading MinIO server..."
wget "$MINIO_DOWNLOAD_URL" -O /usr/local/bin/minio
chmod +x /usr/local/bin/minio

# Create minio user and data directory
echo "Creating minio user and data directory..."
useradd -r -s /bin/false minio || true
mkdir -p /data
chown minio:minio /data

# Download and install systemd service file
echo "Installing systemd service file..."
wget https://raw.githubusercontent.com/derdanu/azure-minio-vm/main/minio.service -O /etc/systemd/system/minio.service

# Create configuration file
echo "Creating MinIO configuration..."
cat > /etc/default/minio << EOF
MINIO_OPTS="--address :9000"
MINIO_VOLUMES="/data"
MINIO_ROOT_USER=$MINIO_USER
MINIO_ROOT_PASSWORD=$MINIO_PASSWORD
EOF

# Enable and start the service
echo "Enabling and starting MinIO service..."
systemctl daemon-reload
systemctl enable minio
systemctl start minio

echo "MinIO installation completed successfully!"
echo "Service status:"
systemctl status minio --no-pager
