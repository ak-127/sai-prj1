# Troubleshooting Guide

Common issues and their solutions for Saikrupa development, deployment, and production environments.

## Table of Contents

- [Docker & Docker-Compose Issues](#docker--docker-compose-issues)
- [Database Issues](#database-issues)
- [Django Application Issues](#django-application-issues)
- [Nginx & Web Server Issues](#nginx--web-server-issues)
- [Deployment Issues](#deployment-issues)
- [Performance Issues](#performance-issues)
- [Security Issues](#security-issues)

---

## Docker & Docker-Compose Issues

### Issue: Docker daemon not running

**Symptoms**: `Cannot connect to Docker daemon`

**Solution**:

```bash
# Check Docker status
sudo systemctl status docker

# Start Docker daemon
sudo systemctl start docker

# Enable auto-start on boot
sudo systemctl enable docker

# Verify installation
docker --version
```

### Issue: Permission denied while trying to connect to Docker socket

**Symptoms**: `permission denied while trying to connect to Docker daemon`

**Solution**:

```bash
# Add current user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify without sudo
docker ps

# If still having issues, restart Docker
sudo systemctl restart docker
```

### Issue: Containers not starting after reboot

**Symptoms**: `docker-compose ps` shows no running containers

**Solution**:

```bash
# Navigate to application directory
cd /home/ubuntu/saikrupa

# Start containers with verbose output
docker-compose up -d --verbose

# Check logs for errors
docker-compose logs

# If services have restart: always policy, they should auto-start
# Verify this in docker-compose.yml
```

### Issue: Out of disk space / Docker layers too large

**Symptoms**: `no space left on device`

**Solution**:

```bash
# Check disk usage
df -h

# Remove unused Docker images
docker image prune -a

# Remove unused containers
docker container prune

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Aggressive cleanup (WARNING: removes all unused resources)
docker system prune -a --volumes

# Check space again
df -h
```

### Issue: Build fails with "Build cache invalidated"

**Symptoms**: Docker build takes very long or fails unexpectedly

**Solution**:

```bash
# Clear Docker build cache
docker builder prune

# Rebuild without cache
docker-compose build --no-cache .

# If still failing, check Docker daemon logs
sudo journalctl -u docker -n 100
```

---

## Database Issues

### Issue: PostgreSQL connection refused

**Symptoms**: `psycopg2.OperationalError: could not connect to server`

**Solution**:

```bash
# Check if database container is running
docker-compose ps

# Check database logs
docker-compose logs db

# Verify environment variables in .env
cat .env | grep POSTGRES

# Ensure db service is healthy
docker-compose exec db pg_isready -U saikrupa_user

# If container crashed, check for corruption
docker-compose down
docker volume rm saikrupa_postgres_data  # WARNING: DATA LOSS
docker-compose up -d db
```

### Issue: Database migrations fail

**Symptoms**: `django.db.migrations.exceptions.MigrationError`

**Solution**:

```bash
# Check migration status
docker-compose exec web python manage.py showmigrations

# Show pending migrations
docker-compose exec web python manage.py showmigrations --plan

# Rollback to specific migration
docker-compose exec web python manage.py migrate blog 0003

# Re-apply migrations
docker-compose exec web python manage.py migrate

# Create fresh migrations if conflicting
docker-compose exec web python manage.py makemigrations --merge
```

### Issue: Database size keeps growing

**Symptoms**: Disk space fills up quickly with postgresql_data volume

**Solution**:

```bash
# Analyze database size
docker-compose exec db psql -U saikrupa_user -d saikrupa_db -c \
    "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname.'.'tablename)) 
     FROM pg_tables 
     ORDER BY pg_total_relation_size(schemaname.'.'tablename) DESC;"

# Analyze table bloat
docker-compose exec db psql -U saikrupa_user -d saikrupa_db -c \
    "SELECT tablename, round(100 * (EXTRACT(EPOCH FROM now()) - EXTRACT(EPOCH FROM last_vacuum)) / 86400) as days_since_vacuum
     FROM pg_stat_user_tables;"

# Manually vacuum database
docker-compose exec db vacuumdb -U saikrupa_user -d saikrupa_db --analyze

# Enable autovacuum (check postgresql.conf)
docker-compose exec db psql -U saikrupa_user -d saikrupa_db -c \
    "SHOW autovacuum;"
```

### Issue: Restore from backup fails

**Symptoms**: `ERROR: role "saikrupa_user" does not exist`

**Solution**:

```bash
# Create user before restoring
docker-compose exec db psql -U postgres -d postgres << EOF
    CREATE USER saikrupa_user WITH PASSWORD 'password';
    CREATE DATABASE saikrupa_db OWNER saikrupa_user;
EOF

# Restore backup
docker-compose exec -T db psql -U saikrupa_user -d saikrupa_db < backup.sql

# Verify restoration
docker-compose exec db psql -U saikrupa_user -d saikrupa_db -c "SELECT COUNT(*) FROM blog_blog;"
```

---

## Django Application Issues

### Issue: Secret key not set or invalid

**Symptoms**: `Exception: SECRET_KEY is not set` or `Improper configuration`

**Solution**:

```bash
# Generate new secret key
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Add to .env file
echo "SECRET_KEY=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" >> .env

# Restart containers
docker-compose restart web
```

### Issue: Static files not loading (404 errors)

**Symptoms**: CSS/JavaScript files return 404, pages look broken

**Solution**:

```bash
# Collect static files
docker-compose exec web python manage.py collectstatic --noinput --clear

# Verify they were collected
docker-compose exec web ls -la /vol/web/static/

# Check Nginx configuration
docker-compose exec nginx nginx -t

# Restart Nginx
docker-compose restart nginx

# Verify from host
curl -I http://localhost/static/admin/css/base.css
```

### Issue: Media files not accessible

**Symptoms**: Uploaded images return 404, media directory empty

**Solution**:

```bash
# Check if media volume exists
docker volume ls | grep media_volume

# Verify media files in container
docker-compose exec web ls -la /vol/web/media/

# Check file permissions
docker-compose exec web stat /vol/web/media/blog_feature_image/

# Verify Nginx can serve them
docker-compose exec nginx ls -la /vol/web/media/

# Test access via Nginx
curl -I http://localhost/media/blog_feature_image/sample.jpg
```

### Issue: DEBUG mode enabled in production

**Symptoms**: Sensitive information leaked, security warnings

**Solution**:

```bash
# Check current DEBUG setting
docker-compose exec web python manage.py shell -c "from django.conf import settings; print(f'DEBUG: {settings.DEBUG}')"

# Update .env file
sed -i 's/DEBUG=True/DEBUG=False/' .env

# Restart application
docker-compose restart web

# Verify DEBUG is False
docker-compose exec web python manage.py shell -c "from django.conf import settings; print(f'DEBUG: {settings.DEBUG}')"
```

### Issue: ALLOWED_HOSTS misconfiguration

**Symptoms**: `DisallowedHost at /` error

**Solution**:

```bash
# Update .env with correct hosts
echo "ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com,your-ec2-ip" >> .env

# Restart application
docker-compose restart web

# Verify setting
docker-compose exec web python manage.py shell -c "from django.conf import settings; print(settings.ALLOWED_HOSTS)"
```

### Issue: Superuser not created

**Symptoms**: Cannot access admin panel, login fails

**Solution**:

```bash
# Create superuser manually
docker-compose exec web python manage.py createsuperuser

# Or create non-interactively via .env variables
docker-compose exec web python manage.py createsuperuser --noinput

# Verify superuser exists
docker-compose exec db psql -U saikrupa_user -d saikrupa_db \
    -c "SELECT * FROM auth_user WHERE is_superuser=true;"

# Reset superuser password
docker-compose exec web python manage.py changepassword admin
```

### Issue: Email sending not configured

**Symptoms**: Reset password emails not sent, SMTP errors

**Solution**:

```bash
# Add to .env for Gmail
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# For development (console backend)
email_BACKEND=django.core.mail.backends.console.EmailBackend

# Restart application
docker-compose restart web

# Test email sending
docker-compose exec web python manage.py shell << EOF
from django.core.mail import send_mail
send_mail(
    'Test Subject',
    'Test Message',
    'from@example.com',
    ['to@example.com'],
)
print("Email sent successfully")
EOF
```

---

## Nginx & Web Server Issues

### Issue: Nginx container not starting

**Symptoms**: `docker-compose up` fails for nginx service

**Solution**:

```bash
# Check nginx configuration syntax
docker-compose exec nginx nginx -t

# View nginx error logs
docker-compose logs nginx

# Rebuild nginx image
docker-compose build --no-cache nginx

# Restart nginx
docker-compose restart nginx

# Verify it's listening on port 80
docker-compose exec nginx netstat -tlnp | grep 80
```

### Issue: 502 Bad Gateway errors

**Symptoms**: Nginx returns "502 Bad Gateway" error

**Solution**:

```bash
# Check if Django app is running
docker-compose ps web

# Check web service logs
docker-compose logs web

# Verify web service is listening on port 8000
docker-compose exec web netstat -tlnp | grep 8000

# Check Nginx upstream configuration
docker-compose exec nginx cat /etc/nginx/nginx.conf | grep upstream

# Try restarting web service
docker-compose restart web

# Increase Nginx timeout if app is slow
# Edit nginx.conf and add:
# proxy_connect_timeout 60s;
# proxy_send_timeout 60s;
# proxy_read_timeout 60s;
```

### Issue: Port 80/443 already in use

**Symptoms**: `bind: address already in use` error

**Solution**:

```bash
# Find process using the port
sudo lsof -i :80
sudo lsof -i :443

# Kill the process
sudo kill -9 <PID>

# Or change Docker port mapping
# Edit docker-compose.yml:
# ports:
#   - "8080:80"  # Use 8080 instead
#   - "8443:443"

# Restart containers
docker-compose up -d
```

### Issue: SSL certificate issues

**Symptoms**: `ERR_SSL_VERSION_OR_CIPHER_MISMATCH` or certificate warnings

**Solution**:

```bash
# Check certificate validity
openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -text -noout

# Check certificate expiry
openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -noout -dates

# Manually renew certificate
sudo certbot renew --force-renewal

# Verify Nginx is using correct certificates
docker-compose exec nginx cat /etc/nginx/nginx.conf | grep ssl_certificate

# Reload Nginx after certificate update
docker-compose exec nginx nginx -s reload

# Test SSL configuration
openssl s_client -connect your-domain.com:443 -tls1_2
```

---

## Deployment Issues

### Issue: Git clone fails during deployment

**Symptoms**: `git clone: command not found` or authentication fails

**Solution**:

```bash
# SSH to EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install git
sudo apt-get update && sudo apt-get install -y git

# Configure git credentials (one-time)
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# If using SSH key for Git
eval "$(ssh-agent -s)"
ssh-add /path/to/github/key.pem

# Test Git connection
ssh -T git@github.com
```

### Issue: Docker images not downloading (pulling)

**Symptoms**: `manifest not found` or timeout errors during build/deployment

**Solution**:

```bash
# Check internet connectivity
ping -c 5 8.8.8.8

# Restart Docker daemon
sudo systemctl restart docker

# Pull images with retry
docker-compose pull --no-parallel || docker-compose pull --no-parallel

# Check available disk space
df -h

# Use official mirrors if available (for China regions)
# Add daemon.json configuration
```

### Issue: Environment variables not loaded in containers

**Symptoms**: Configuration errors, missing settings

**Solution**:

```bash
# Verify .env file exists and is accessible
ls -la /home/ubuntu/saikrupa/.env

# Check .env file format
cat /home/ubuntu/saikrupa/.env

# Verify variables are passed to containers
docker-compose config | grep -A 20 "environment:"

# Check environment inside running container
docker-compose exec web env | grep POSTGRES

# Rebuild containers if env file changed
docker-compose down
docker-compose up -d --build
```

### Issue: Health checks failing / services considered unhealthy

**Symptoms**: Services marked as "Unhealthy" in `docker-compose ps`

**Solution**:

```bash
# Check health check configuration in docker-compose.yml
docker-compose config | grep -A 10 "healthcheck:"

# Verify health check command manually
docker-compose exec db pg_isready -U saikrupa_user

# View health check history
docker inspect postgres_db | grep -A 20 "Health"

# Increase health check timeouts if services are just slow
# docker-compose.yml example:
# healthcheck:
#   test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER"]
#   interval: 10s
#   timeout: 10s
#   retries: 10
```

---

## Performance Issues

### Issue: Application runs slowly

**Symptoms**: Slow page load times, high response latency

**Solution**:

```bash
# Check container resource usage
docker stats

# Monitor Django application performance
docker-compose exec web python manage.py shell_plus

# Analyze database query performance
docker-compose exec web python manage.py shell << EOF
from django.db import connection
from blog.models import Blog
blogs = Blog.objects.all()[:10]
print(connection.queries)
EOF

# Enable Django query logging
# In settings.py, add:
# LOGGING = {
#     'version': 1,
#     'handlers': {
#         'console': {'class': 'logging.StreamHandler'},
#     },
#     'loggers': {
#         'django.db.backends': {'handlers': ['console'], 'level': 'DEBUG'},
#     },
# }

# Optimize Gunicorn workers
# arch/Dockerfile:
# CMD ["gunicorn", "saikrupax.wsgi:application", "--workers", "5", "--worker-class", "sync", "--max-requests", "1000"]

# Enable Django template caching
# settings.py:
# TEMPLATES = [{
#     'OPTIONS': {
#         'loaders': [
#             ('django.template.loaders.cached.Loader', [
#                 'django.template.loaders.filesystem.Loader',
#                 'django.template.loaders.app_directories.Loader',
#             ]),
#         ],
#     },
# }]
```

### Issue: High memory usage

**Symptoms**: `docker stats` shows high memory consumption

**Solution**:

```bash
# Check which container uses most memory
docker stats

# Limit container memory in docker-compose.yml:
# services:
#   web:
#     deploy:
#       resources:
#         limits:
#           memory: 512M
#         reservations:
#           memory: 256M

# Check for memory leaks in application
docker-compose exec web python manage.py shell << EOF
import gc
gc.collect()
import sys
print(sys.getsizeof(sys.modules))
EOF

# Restart container to free memory
docker-compose restart web

# Investigate database bloat
docker-compose exec db vacuumdb -U saikrupa_user -d saikrupa_db --analyze --full
```

### Issue: Database slow query logs flooded

**Symptoms**: Slow queries happening frequently

**Solution**:

```bash
# Enable query logging
docker-compose exec db psql -U saikrupa_user -d saikrupa_db << EOF
ALTER SYSTEM SET log_min_duration_statement = 1000;
SELECT pg_reload_conf();
EOF

# Check slow query log
docker-compose exec db tail -f /var/log/postgresql/postgresql.log | grep duration

# Add indexes to frequently queried columns
docker-compose exec db psql -U saikrupa_user -d saikrupa_db << EOF
CREATE INDEX CONCURRENTLY idx_blog_author ON blog_blog(author_id);
CREATE INDEX CONCURRENTLY idx_blog_publish_date ON blog_blog(publish_date);
EOF

# Optimize queries in Django views using select_related/prefetch_related
```

---

## Security Issues

### Issue: SSL certificate expired or about to expire

**Symptoms**: Browser warns about expired certificate

**Solution**:

```bash
# Check certificate expiry
sudo openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -noout -dates

# Manually renew
sudo certbot renew --force-renewal -v

# Update Nginx to use new certificate
docker-compose restart nginx

# Automate renewal
sudo certbot renew --dry-run  # Test

# Add to crontab
# 0 2 1 * * /usr/bin/certbot renew --quiet
```

### Issue: Secrets exposed in logs or error messages

**Symptoms**: Database password, API keys, etc. visible in logs

**Solution**:

```bash
# Remove sensitive data from logs
docker-compose logs | grep -i password  # Find exposed secrets

# Update logging configuration in settings.py
# Use getpass or environment variables instead of hardcoding

# Rotate affected secrets
# 1. Generate new SECRET_KEY
# 2. Update database password
# 3. Restart containers

# Check git history for committed secrets
git log -p | grep -i password  # Find if committed

# Use git-secrets to prevent future commits
pip install git-secrets
git secrets --install
git secrets --register-aws
```

### Issue: CORS errors when accessing API

**Symptoms**: `Access to XMLHttpRequest blocked by CORS policy`

**Solution**:

```bash
# Install django-cors-headers
docker-compose exec web pip install django-cors-headers

# Add to settings.py
INSTALLED_APPS = [
    # ...
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    # ...
]

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8000",
    "https://your-domain.com",
]

# Restart application
docker-compose restart web
```

---

## Getting Help

### Useful Debugging Commands

```bash
# View all container logs
docker-compose logs --follow

# Get inside a container
docker-compose exec web bash

# Check container networking
docker-compose exec web ping db

# View Docker container details
docker inspect <container-name>

# Monitor in real-time
watch -n 1 'docker-compose ps'

# Export full logs to file
docker-compose logs > /tmp/logs.txt 2>&1

# Check system journal for Docker errors
sudo journalctl -u docker -n 50
```

### Resources

- [Docker Troubleshooting](https://docs.docker.com/config/containers/troubleshoot/)
- [Django Troubleshooting](https://docs.djangoproject.com/en/5.0/faq/troubleshoot/)
- [PostgreSQL Troubleshooting](https://www.postgresql.org/docs/current/trouble.html)
- [Nginx Troubleshooting](https://nginx.org/en/docs/ngx_core_module.html)

