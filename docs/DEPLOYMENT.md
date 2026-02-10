# Deployment Guide

Complete guide for deploying Saikrupa to AWS EC2 with production-ready configurations.

## Table of Contents

- [Prerequisites](#prerequisites)
- [AWS EC2 Setup](#aws-ec2-setup)
- [Application Deployment](#application-deployment)
- [SSL/TLS Configuration](#ssltls-configuration)
- [Database Backup Strategy](#database-backup-strategy)
- [Monitoring & Alerts](#monitoring--alerts)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### AWS Account Setup
- AWS account with appropriate IAM permissions
- EC2 permissions for instance creation
- VPC and Security Group configuration access
- Route53 for DNS management (optional but recommended)

### Local Requirements
- SSH client (OpenSSH or PuTTY on Windows)
- Git for code repository access
- Terminal/Command prompt access

### Domain Setup (Optional)
- Domain registered with Route53 or external registrar
- DNS records pointing to EC2 instance

---

## AWS EC2 Setup

### Step 1: Launch EC2 Instance

1. **Log in to AWS Console**
   - Go to EC2 Dashboard
   - Click "Launch Instance"

2. **Choose AMI**
   - **Recommended**: Ubuntu Server 22.04 LTS
   - **Free Tier**: t2.micro (if eligible)
   - **Recommended for Production**: t3.small or t3.medium

3. **Instance Type Selection**
   ```
   Development: t3.micro (1 GB RAM, 1 vCPU)
   Staging: t3.small (2 GB RAM, 2 vCPU)
   Production: t3.medium or larger (4+ GB RAM, 2+ vCPU)
   ```

4. **Configure Instance Details**
   - **Network**: Choose default VPC or custom VPC
   - **Subnet**: Select appropriate subnet
   - **Auto-assign Public IP**: Enable
   - **IAM Instance Profile**: Create or select EC2 role

5. **Storage Configuration**
   - **Volume Size**: Minimum 20GB (SSD recommended)
   - **Volume Type**: gp3 (General Purpose SSD)
   - **Delete on Termination**: Yes

6. **Add Tags** (Recommended)
   ```
   Name: saikrupa-production
   Environment: production
   Project: saikrupa
   ManagedBy: DevOps
   ```

7. **Security Group Configuration**
   ```
   Inbound Rules:
   - Type: SSH (22) | Source: Your IP or 0.0.0.0/0
   - Type: HTTP (80) | Source: 0.0.0.0/0
   - Type: HTTPS (443) | Source: 0.0.0.0/0
   
   Outbound Rules:
   - All traffic allowed (default)
   ```

8. **Key Pair**
   - Create or select existing keypair
   - **Important**: Download and save securely (.pem file)
   - Never share or commit to version control

### Step 2: Retrieve Instance Information

After instance is running:
- Note the **Public IP Address**
- Note the **Instance ID**
- Verify connection via SSH

### Step 3: Connect to Instance

```bash
# Set correct permissions on key pair
chmod 400 /path/to/your-keypair.pem

# Connect to instance
ssh -i /path/to/your-keypair.pem ubuntu@<your-instance-public-ip>

# Verify connection
echo "Connected to $(hostname)"
```

---

## Application Deployment

### Step 1: Update System Packages

```bash
# Login to EC2 instance (from previous step)
sudo apt-get update && sudo apt-get upgrade -y

# Install essential packages
sudo apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev
```

### Step 2: Install Docker and Docker-Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Add ubuntu user to docker group (allows running docker without sudo)
sudo usermod -aG docker ubuntu
newgrp docker

# Install Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version
```

### Step 3: Create Application Environment

```bash
# Create application directory
mkdir -p /home/ubuntu/saikrupa
cd /home/ubuntu/saikrupa

# Clone repository
git clone https://github.com/yourusername/saikrupa.git .

# Create .env file with production settings
cat > .env << 'EOF'
# Django Settings
SECRET_KEY=$(openssl rand -base64 50)
DEBUG=False
ALLOWED_HOSTS=your-domain.com,your-ec2-ip,www.your-domain.com

# PostgreSQL Settings
POSTGRES_DB=saikrupa_db
POSTGRES_USER=saikrupa_user
POSTGRES_PASSWORD=$(openssl rand -base64 20)
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Django Superuser
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_PASSWORD=$(openssl rand -base64 20)
DJANGO_SUPERUSER_EMAIL=admin@your-domain.com

# AWS S3 (Optional)
USE_S3=False

# Email Configuration (Optional)
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
EOF

# Restrict access to .env file
chmod 600 .env

# Verify file was created
cat .env
```

**Important**: Update the values in the .env file with your actual configuration.

### Step 4: Start Application

```bash
# Navigate to application directory
cd /home/ubuntu/saikrupa

# Build and start containers
docker-compose up -d

# Verify all services are running
docker-compose ps

# Expected output:
# NAME            STATUS
# postgres_db     Up (healthy)
# web             Up
# nginx           Up

# Check logs for any errors
docker-compose logs -f web

# After confirming success, detach from logs (Ctrl+C)
```

### Step 5: Verify Deployment

```bash
# Check if application is responding
curl -I http://localhost

# Expected: HTTP/1.1 200 OK

# Check admin interface
curl -I http://localhost/admin/

# View application logs
docker-compose logs web

# Check database connection
docker-compose exec db pg_isready -U saikrupa_user
```

---

## SSL/TLS Configuration

### Option 1: Let's Encrypt with Certbot (Recommended for Free)

#### Step 1: Install Certbot

```bash
sudo apt-get install -y certbot python3-certbot-nginx
```

#### Step 2: Generate SSL Certificate

```bash
# Stop Nginx temporarily (port 80 must be free)
docker-compose stop nginx

# Generate certificate
sudo certbot certonly --standalone \
    -d your-domain.com \
    -d www.your-domain.com \
    -m your-email@example.com \
    --agree-tos

# Certificate location:
# /etc/letsencrypt/live/your-domain.com/fullchain.pem
# /etc/letsencrypt/live/your-domain.com/privkey.pem
```

#### Step 3: Update nginx.conf

```nginx
# /home/ubuntu/saikrupa/nginx.conf
events {}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name your-domain.com www.your-domain.com;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS server block
    server {
        listen 443 ssl http2;
        server_name your-domain.com www.your-domain.com;

        # SSL certificates
        ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

        # SSL protocols and ciphers
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # Gzip compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript;

        # Static files
        location /static/ {
            alias /vol/web/static/;
            autoindex off;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }

        # Media files
        location /media/ {
            alias /vol/web/media/;
            expires 7d;
        }

        # Proxy to Django
        location / {
            proxy_pass http://web:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect off;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
    }
}
```

#### Step 4: Mount SSL Certificates in Docker-Compose

```yaml
# docker-compose.yml
nginx:
  image: nginx:latest
  container_name: nginx
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf:ro
    - static_volume:/vol/web/static:ro
    - media_volume:/vol/web/media:ro
    - /etc/letsencrypt:/etc/letsencrypt:ro  # Mount SSL certs
  depends_on:
    - web
  restart: always
```

#### Step 5: Restart Services

```bash
# Restart Docker containers with new configuration
docker-compose up -d

# Verify SSL is working
curl -I https://your-domain.com/

# Expected: HTTP/1.1 200 OK + SSL certificate info
```

#### Step 6: Auto-Renew SSL Certificate

```bash
# Create renewal script
sudo nano /home/ubuntu/renew-cert.sh
```

```bash
#!/bin/bash
cd /home/ubuntu/saikrupa
sudo certbot renew --quiet
docker-compose restart nginx
```

```bash
# Make executable
sudo chmod +x /home/ubuntu/renew-cert.sh

# Add to crontab for automatic renewal (runs monthly)
sudo crontab -e

# Add this line:
0 2 1 * * /home/ubuntu/renew-cert.sh >> /var/log/certbot-renewal.log 2>&1
```

### Option 2: AWS Certificate Manager (For AWS-Managed Domains)

1. Go to AWS Certificate Manager
2. Request new certificate
3. Validate domain ownership
4. Configure CloudFront with the certificate
5. Update Route53 records to point to CloudFront

---

## Database Backup Strategy

### Automated Daily Backups

#### Create Backup Script

```bash
# /home/ubuntu/backup-db.sh
#!/bin/bash

BACKUP_DIR="/home/ubuntu/backups"
DB_CONTAINER="postgres_db"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/saikrupa_backup_$BACKUP_DATE.sql"

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Create database dump
cd /home/ubuntu/saikrupa
docker-compose exec -T db pg_dump \
    -U saikrupa_user \
    -d saikrupa_db \
    > "$BACKUP_FILE"

# Compress backup
gzip "$BACKUP_FILE"
BACKUP_FILE="${BACKUP_FILE}.gz"

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "saikrupa_backup_*.sql.gz" -mtime +7 -delete

# Upload to S3 (optional)
# aws s3 cp "$BACKUP_FILE" s3://your-backup-bucket/saikrupa/

echo "Backup completed: $BACKUP_FILE"
```

#### Schedule with Cron

```bash
# Make script executable
chmod +x /home/ubuntu/backup-db.sh

# Edit crontab
crontab -e

# Add this line for daily backup at 2 AM:
0 2 * * * /home/ubuntu/backup-db.sh >> /var/log/db-backup.log 2>&1
```

### Restore from Backup

```bash
# List available backups
ls -lh /home/ubuntu/backups/

# Decompress backup
gunzip /home/ubuntu/backups/saikrupa_backup_20260210_020000.sql.gz

# Stop application
cd /home/ubuntu/saikrupa
docker-compose stop web

# Restore database
docker-compose exec -T db psql \
    -U saikrupa_user \
    -d saikrupa_db \
    < /home/ubuntu/backups/saikrupa_backup_20260210_020000.sql

# Start application
docker-compose up -d web

# Verify restoration
docker-compose exec db pg_isready -U saikrupa_user
```

---

## Monitoring & Alerts

### AWS CloudWatch Integration

#### Enable Detailed Monitoring

```bash
# Via AWS CLI
aws ec2 monitor-instances --instance-ids <instance-id> --region us-east-1

# Check status
aws ec2 describe-instances --instance-ids <instance-id> --region us-east-1
```

#### Create CloudWatch Alarms

```bash
# High CPU usage alarm
aws cloudwatch put-metric-alarm \
    --alarm-name saikrupa-high-cpu \
    --alarm-description "Alert when CPU usage is high" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --alarm-actions arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:your-sns-topic

# Low disk space alarm
aws cloudwatch put-metric-alarm \
    --alarm-name saikrupa-low-disk \
    --alarm-description "Alert when disk usage is high" \
    --metric-name DiskSpaceUsage \
    --namespace CWAgent \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold
```

### Application Health Monitoring

```bash
# Create health check script
cat > /home/ubuntu/health-check.sh << 'EOF'
#!/bin/bash

# Check if services are running
cd /home/ubuntu/saikrupa

# Check Docker
if ! docker-compose ps | grep -q "postgres_db.*Up"; then
    echo "CRITICAL: Database is down" && exit 1
fi

if ! docker-compose ps | grep -q "web.*Up"; then
    echo "CRITICAL: Application is down" && exit 1
fi

if ! docker-compose ps | grep -q "nginx.*Up"; then
    echo "CRITICAL: Nginx is down" && exit 1
fi

# Check HTTP response
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_CODE" != "200" ]; then
    echo "CRITICAL: Application returned HTTP $HTTP_CODE"
    exit 1
fi

echo "OK: All services healthy"
exit 0
EOF

chmod +x /home/ubuntu/health-check.sh

# Add to crontab (runs every 5 minutes)
crontab -e
# 0,5,10,15,20,25,30,35,40,45,50,55 * * * * /home/ubuntu/health-check.sh
```

### Application Logging

```bash
# View recent logs
docker-compose logs --tail=100 web

# Follow live logs
docker-compose logs -f web

# Export logs to file
docker-compose logs web > /home/ubuntu/logs/app-$(date +%Y%m%d).log
```

---

## Troubleshooting

### Common Deployment Issues

#### Issue: Containers not starting after reboot

```bash
# Check if docker daemon is running
sudo systemctl status docker

# Start docker
sudo systemctl start docker

# Restart containers
cd /home/ubuntu/saikrupa
docker-compose up -d
```

#### Issue: Out of disk space

```bash
# Check disk usage
df -h

# Free up space - remove old logs
docker-compose logs --tail=0 | tail -c +1 > /dev/null

# Clean up Docker images and volumes (USE WITH CAUTION)
docker system prune -a --volumes

# Alternative: expand EBS volume (requires reboot)
```

#### Issue: Database won't connect after restart

```bash
# Check database logs
docker-compose logs db

# Restore from backup if corrupted
# (See Database Backup Strategy section)

# Reset database (WARNING: DATA LOSS)
docker-compose down -v
docker-compose up -d
```

#### Issue: SSL certificate not working

```bash
# Check certificate validity
sudo openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -text -noout

# Verify nginx configuration
docker-compose exec nginx nginx -t

# Reload nginx
docker-compose restart nginx

# Check certificate renewal
sudo certbot renew --dry-run
```

#### Issue: High memory usage

```bash
# Check container resource usage
docker stats

# Limit container memory (update docker-compose.yml)
services:
  web:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

# Restart containers
docker-compose up -d
```

---

## Performance Tuning

### Database Performance

```sql
-- Create indexes for frequently queried fields
CREATE INDEX idx_blog_author ON blog_blog(author_id);
CREATE INDEX idx_blog_publish_date ON blog_blog(publish_date);
CREATE INDEX idx_blog_category ON blog_blog_category(category_id);
```

### Gunicorn Optimization

```bash
# Calculate optimal worker count: (2 × CPU_cores) + 1
WORKER_COUNT=$((2 * $(nproc) + 1))
echo "Recommended workers: $WORKER_COUNT"

# Update in docker-compose.yml or Dockerfile:
# CMD ["gunicorn", "saikrupax.wsgi:application", "--workers", "5", "--worker-class", "sync", "--max-requests", "1000", "--timeout", "60"]
```

### Nginx Performance

```nginx
# Enable caching
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m;

location / {
    proxy_cache api_cache;
    proxy_cache_valid 200 10m;
    proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_503 http_504;
}
```

---

