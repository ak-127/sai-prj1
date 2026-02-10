# Saikrupa - Django Application with DevOps Architecture

<div align="center">

[![Python](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)
[![Django](https://img.shields.io/badge/Django-5.0.6-darkgreen.svg)](https://www.djangoproject.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-ready **Django web application** showcasing modern **DevOps practices** with containerization, orchestration, and CI/CD pipeline integration for AWS deployment.

[Features](#-key-features) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture) • [Quick Start](#-quick-start) • [Deployment](#-deployment) • [CI/CD](#-cicd-pipeline)

</div>

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Docker & Docker-Compose](#-docker--docker-compose)
- [Environment Configuration](#-environment-configuration)
- [Database Management](#-database-management)
- [Deployment on AWS EC2](#-deployment-on-aws-ec2)
- [CI/CD Pipeline with Jenkins](#-cicd-pipeline-with-jenkins)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Project Overview

**Saikrupa** is a full-stack Django web application demonstrating enterprise-grade DevOps practices. The application features a blog management system with user authentication and profile management, all deployed using containerization technologies and automated CI/CD pipelines.

### Core Functionality:
- **Blog Management**: Create, read, and manage blog posts with categories and featured images
- **User Authentication**: Secure user registration, login, and profile management
- **Image Optimization**: Automatic image resizing for feature images and profile pictures
- **Admin Dashboard**: Django admin interface for content management
- **Responsive Design**: Bootstrap-based responsive UI with SB Admin 2 template

---

## ✨ Key Features

### Application Features
- ✅ User authentication and authorization
- ✅ Blog post creation with rich content support
- ✅ Category-based blog organization
- ✅ User profile management with profile pictures
- ✅ Admin dashboard for content management
- ✅ Responsive web interface

### DevOps & Infrastructure Features
- ✅ **Containerization**: Dockerfile for consistent application deployment
- ✅ **Orchestration**: Docker-Compose for multi-container coordination
- ✅ **Database**: PostgreSQL with health checks and persistent volumes
- ✅ **Reverse Proxy**: Nginx for load balancing and static file serving
- ✅ **Static & Media Files**: Separate volume management
- ✅ **Environment Management**: .env-based configuration for secrets
- ✅ **Database Migrations**: Automated migrations on container startup
- ✅ **Auto-scaling Ready**: Can be deployed across multiple EC2 instances
- ✅ **CI/CD Ready**: Jenkins pipeline integration for automated testing and deployment
- ✅ **AWS Ready**: Optimized for deployment on AWS EC2 instances

---

## 🛠 Tech Stack

### Backend
| Technology | Version | Purpose |
|-----------|---------|---------|
| **Python** | 3.12 | Core programming language |
| **Django** | 5.0.6 | Web framework |
| **Gunicorn** | 25.0.3 | WSGI application server |
| **PostgreSQL** | 15 | Relational database |
| **Psycopg2** | 2.9.11 | PostgreSQL adapter for Python |

### Frontend
| Technology | Purpose |
|-----------|---------|
| **Bootstrap 4** | Responsive UI framework |
| **SB Admin 2** | Admin dashboard template |
| **jQuery** | DOM manipulation |
| **Chart.js** | Data visualization |
| **DataTables** | Advanced table functionality |

### DevOps & Infrastructure
| Technology | Purpose |
|-----------|---------|
| **Docker** | Containerization |
| **Docker-Compose** | Container orchestration |
| **Nginx** | Reverse proxy & load balancer |
| **AWS EC2** | Cloud compute instance |
| **Jenkins** | CI/CD pipeline automation |

### Additional Libraries
- **Django Crispy Forms**: Enhanced form rendering
- **Pillow**: Image processing
- **python-dotenv**: Environment variable management
- **SQLFormat**: SQL query formatting

---

## 🏗 Architecture

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     AWS EC2 Instance                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Docker-Compose Environment               │  │
│  │                                                        │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │           Nginx (Port 80)                    │   │  │
│  │  │   • Reverse Proxy                            │   │  │
│  │  │   • Static Files Serving (/static/)          │   │  │
│  │  │   • Media Files Serving (/media/)            │   │  │
│  │  │   • SSL/TLS Termination                      │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  │                      ↓                               │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │    Django App (Gunicorn, Port 8000)         │   │  │
│  │  │   • Blog Management System                  │   │  │
│  │  │   • User Authentication                     │   │  │
│  │  │   • Admin Dashboard                         │   │  │
│  │  │   • Image Processing                        │   │  │
│  │  │   • Database Migration Handling             │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  │                      ↓                               │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │       PostgreSQL Database (Port 5432)       │   │  │
│  │  │   • Persistent Data Storage                 │   │  │
│  │  │   • Health Checks Enabled                   │   │  │
│  │  │   • Automated Backups Support               │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  │                                                        │  │
│  │           Named Volumes (Persistent)                 │  │
│  │   • postgres_data → DB Files                         │  │
│  │   • static_volume → Static Assets                    │  │
│  │   • media_volume → User Uploads                      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          ↑
                    Jenkins CI/CD
            (Automated Testing & Deployment)
```

### Data Flow

```
Client Request
    ↓
Nginx Reverse Proxy (Port 80)
    ↓
    ├─ Static Files → Served from static_volume
    ├─ Media Files → Served from media_volume
    └─ Dynamic Requests → Django Application
                    ↓
            Django (Gunicorn)
                    ↓
            PostgreSQL Database
```

---

## 📂 Project Structure

```
saikrupa/
├── blog/                              # Blog app
│   ├── migrations/                    # Database migrations
│   ├── models.py                      # Blog & Category models
│   ├── views.py                       # Blog views & logic
│   ├── urls.py                        # Blog URL routing
│   ├── admin.py                       # Admin configuration
│   └── forms.py                       # Blog forms
│
├── core/                              # Core app
│   ├── migrations/                    # Database migrations
│   ├── models.py                      # User Profile model
│   ├── views.py                       # Authentication & profile views
│   ├── urls.py                        # Core URL routing
│   ├── forms.py                       # Custom forms
│   ├── signals.py                     # Django signals
│   └── admin.py                       # Admin configuration
│
├── saikrupax/                         # Project configuration
│   ├── settings.py                    # Django settings
│   ├── urls.py                        # Main URL configuration
│   ├── wsgi.py                        # WSGI configuration
│   └── asgi.py                        # ASGI configuration
│
├── templates/                         # HTML templates
│   ├── core/                          # Core app templates
│   │   ├── base.html                  # Base template
│   │   ├── dashboard.html             # Admin dashboard
│   │   ├── login.html                 # Login page
│   │   └── profile.html               # User profile
│   └── blog/                          # Blog app templates
│       ├── all_blog.html              # Blog listing
│       └── blog_post.html             # Single blog post
│
├── static/                            # Static files
│   ├── blog/                          # Blog static files
│   ├── core/                          # Core static files
│   └── vendor/                        # Third-party libraries
│
├── media/                             # User-uploaded files (volumes)
│   ├── blog_feature_image/            # Blog featured images
│   └── user_profile_images/           # User profile pictures
│
├── env/                               # Python virtual environment
│
├── docker-compose.yml                 # Container orchestration config
├── Dockerfile                         # Docker image definition
├── entrypoint.sh                      # Container startup script
├── nginx.conf                         # Nginx configuration
├── manage.py                          # Django management script
├── requirements.txt                   # Python dependencies
└── .env                               # Environment variables (not in repo)
```

---

## 📋 Prerequisites

### System Requirements
- **OS**: Linux/macOS/Windows (with WSL2) or Mac
- **Docker**: Version 20.10+
- **Docker-Compose**: Version 1.29+
- **Git**: For version control

### For Local Development (without Docker)
- **Python**: 3.12+
- **PostgreSQL**: 15+
- **pip**: Python package manager
- **virtualenv**: Python virtual environment tool

---

## 🚀 Quick Start

### Option 1: Using Docker & Docker-Compose (Recommended)

#### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/saikrupa.git
cd saikrupa
```

#### 2. Create Environment File
```bash
cat > .env << EOF
# Django Settings
SECRET_KEY=your-super-secret-key-change-this-in-production
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,your-ec2-ip

# PostgreSQL Settings
POSTGRES_DB=saikrupa_db
POSTGRES_USER=saikrupa_user
POSTGRES_PASSWORD=strong-password-change-this
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Django Superuser
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_PASSWORD=admin-password
DJANGO_SUPERUSER_EMAIL=admin@example.com
EOF
```

#### 3. Build and Start Containers
```bash
docker-compose up --build
```

#### 4. Access the Application
- **Web Application**: http://localhost
- **Admin Dashboard**: http://localhost/admin
- **Default Credentials**: admin / admin-password

#### 5. Stop Containers
```bash
docker-compose down
```

---

### Option 2: Local Development Setup

#### 1. Clone Repository
```bash
git clone https://github.com/yourusername/saikrupa.git
cd saikrupa
```

#### 2. Create Virtual Environment
```bash
python3.12 -m venv env
source env/bin/activate  # On Windows: env\Scripts\activate
```

#### 3. Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### 4. Configure Environment Variables
```bash
cp .env.example .env
# Edit .env with your local PostgreSQL credentials
```

#### 5. Database Setup
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

#### 6. Collect Static Files
```bash
python manage.py collectstatic --noinput
```

#### 7. Run Development Server
```bash
python manage.py runserver
```

#### 8. Access Application
- **Web Application**: http://localhost:8000
- **Admin Dashboard**: http://localhost:8000/admin

---

## 🐳 Docker & Docker-Compose

### Dockerfile Explanation

```dockerfile
FROM python:3.12-slim              # Lightweight Python base image
ENV PYTHONDONTWRITEBYTECODE=1      # Prevent .pyc file creation
ENV PYTHONUNBUFFERED=1             # Unbuffered output for logs
WORKDIR /app                       # Set working directory
RUN apt-get update && apt-get install -y \
    gcc \                          # C compiler for dependencies
    libpq-dev \                    # PostgreSQL client libraries
    netcat-openbsd \               # Network utilities
    && rm -rf /var/lib/apt/lists/* # Clean up apt cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt  # Install Python deps
COPY . .
RUN mkdir -p /vol/web/static /vol/web/media  # Create volume directories
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 8000                        # Expose Gunicorn port
ENTRYPOINT ["/entrypoint.sh"]      # Run entrypoint script
CMD ["gunicorn", "saikrupax.wsgi:application", "--bind", "0.0.0.0:8000"]
```

### Docker-Compose Services

#### PostgreSQL Database Service
```yaml
db:
  image: postgres:15                    # Official PostgreSQL image
  environment:
    POSTGRES_DB: saikrupa_db           # Database name
    POSTGRES_USER: saikrupa_user       # Database user
    POSTGRES_PASSWORD: ${DB_PASSWORD}  # From .env file
  volumes:
    - postgres_data:/var/lib/postgresql/data  # Persistent storage
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER"]
    interval: 5s
    timeout: 5s
    retries: 5
```

**Purpose**: Stores all application data persistently across container restarts.

#### Django Web Application Service
```yaml
web:
  build: .                          # Build from Dockerfile
  environment:
    - DATABASE_URL=postgresql://...
  volumes:
    - static_volume:/vol/web/static
    - media_volume:/vol/web/media
  depends_on:
    db:
      condition: service_healthy   # Wait for DB to be ready
  ports:
    - "8000:8000"
```

**Purpose**: Runs the Django application with Gunicorn WSGI server.

#### Nginx Reverse Proxy Service
```yaml
nginx:
  image: nginx:latest               # Official Nginx image
  ports:
    - "80:80"                      # Listen on port 80
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf
    - static_volume:/vol/web/static
    - media_volume:/vol/web/media
  depends_on:
    - web
```

**Purpose**: Reverse proxy for Django app, serves static files, terminates HTTPS.

### Volume Management

| Volume | Purpose | Mount Point |
|--------|---------|-------------|
| `postgres_data` | Database files persistence | `/var/lib/postgresql/data` |
| `static_volume` | Django static files | `/vol/web/static` |
| `media_volume` | User uploads | `/vol/web/media` |

---

## ⚙️ Environment Configuration

### Required Environment Variables

Create a `.env` file in the project root:

```bash
# Django Configuration
SECRET_KEY=your-django-secret-key-min-50-chars
DEBUG=False                        # Set to True only for development
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com,your-ec2-ip

# PostgreSQL Database
POSTGRES_DB=saikrupa_db
POSTGRES_USER=saikrupa_user
POSTGRES_PASSWORD=strong-secure-password-min-12-chars
POSTGRES_HOST=db                  # Docker service name
POSTGRES_PORT=5432

# Django Superuser (created on first run)
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_PASSWORD=admin-password-min-12-chars
DJANGO_SUPERUSER_EMAIL=admin@example.com

# AWS S3 (Optional for media storage)
USE_S3=False
AWS_STORAGE_BUCKET_NAME=your-bucket-name
AWS_S3_REGION_NAME=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key

# Email Configuration (Optional)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

### Environment Variable Security Best Practices

✅ **DO**:
- Keep `.env` in `.gitignore` (never commit secrets)
- Use strong, random passwords (min 12 characters)
- Rotate secrets regularly in production
- Use AWS Secrets Manager or Vault for production
- Set `DEBUG=False` in production
- Use unique `SECRET_KEY` per environment

❌ **DON'T**:
- Commit `.env` to version control
- Use default passwords in production
- Share secrets in chat or emails
- Use predictable secret values

---

## 💾 Database Management

### Database Migrations

Migrations are automatically applied on container startup via `entrypoint.sh`.

#### Manual Migration Commands

```bash
# Create new migrations after model changes
docker-compose exec web python manage.py makemigrations

# Apply pending migrations
docker-compose exec web python manage.py migrate

# Show migration status
docker-compose exec web python manage.py showmigrations

# Rollback to previous migration
docker-compose exec web python manage.py migrate app_name 0001
```

### Database Backup & Restore

#### Backup PostgreSQL Database
```bash
# Backup to file
docker-compose exec db pg_dump -U saikrupa_user -d saikrupa_db > backup.sql

# Restore from backup
docker-compose exec -T db psql -U saikrupa_user -d saikrupa_db < backup.sql
```

#### Verify Database Connection
```bash
# Connect to PostgreSQL
docker-compose exec db psql -U saikrupa_user -d saikrupa_db

# Test queries
\dt                    # List all tables
\l                     # List all databases
SELECT VERSION();      # PostgreSQL version
```

---

## ☁️ Deployment on AWS EC2

### Step 1: Launch EC2 Instance

1. **Choose AMI**: Ubuntu 22.04 LTS (t3.micro for free tier)
2. **Security Group**: Allow ports 80 (HTTP), 443 (HTTPS), 22 (SSH)
3. **Storage**: At least 20GB for application and data
4. **Key Pair**: Download and save securely

### Step 2: Connect to EC2

```bash
chmod 400 your-key-pair.pem
ssh -i your-key-pair.pem ubuntu@your-ec2-public-ip
```

### Step 3: Install Required Software

```bash
# Update system packages
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version
```

### Step 4: Clone Application and Configure

```bash
# Clone repository
git clone https://github.com/yourusername/saikrupa.git
cd saikrupa

# Create environment file with production settings
nano .env
# Copy and edit the environment variables above
```

### Step 5: Start Application with Docker-Compose

```bash
# Build and start all services
docker-compose up -d

# Verify services are running
docker-compose ps

# Check logs
docker-compose logs -f web       # Django app logs
docker-compose logs -f db        # Database logs
docker-compose logs -f nginx     # Nginx logs
```

### Step 6: Configure Domain and SSL/TLS

#### Use Let's Encrypt with Certbot

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx -y

# Generate SSL certificate
sudo certbot certonly --standalone -d your-domain.com

# Update nginx.conf to use SSL
sudo nano nginx.conf
```

#### Updated nginx.conf with SSL

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    location / {
        proxy_pass http://web:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Step 7: Setup Auto-Restart and Monitoring

#### Docker-Compose Restart Policy
The `docker-compose.yml` already includes `restart: always` for all services.

#### Monitor Application Health

```bash
# Check container health
docker-compose ps

# View real-time logs
docker-compose logs -f

# Check resource usage
docker stats
```

### Production Checklist

- [ ] Set `DEBUG=False` in `.env`
- [ ] Use strong `SECRET_KEY` (50+ characters)
- [ ] Configure `ALLOWED_HOSTS` with actual domain
- [ ] Setup SSL/TLS certificate
- [ ] Configure backup strategy for PostgreSQL
- [ ] Setup CloudWatch for monitoring
- [ ] Enable VPC security groups
- [ ] Configure Route53 for DNS
- [ ] Setup CloudFront for CDN
- [ ] Enable auto-scaling groups
- [ ] Configure RDS for database (optional)

---

## 🔄 CI/CD Pipeline with Jenkins

### Pipeline Architecture

```
GitHub Repository
    ↓
    ├─ Webhook Trigger (on push)
    ↓
Jenkins Pipeline
    ├─ Stage 1: Checkout Code
    ├─ Stage 2: Run Tests
    ├─ Stage 3: Build Docker Image
    ├─ Stage 4: Push to Registry (Docker Hub/ECR)
    ├─ Stage 5: Deploy to AWS EC2
    ├─ Stage 6: Health Check
    └─ Stage 7: Notify Slack/Email
    ↓
AWS EC2 Instance
    ├─ Pull Latest Image
    ├─ Stop Old Containers
    ├─ Start New Containers
    └─ Run Smoke Tests
```

### Jenkinsfile

Create a `Jenkinsfile` in your project root:

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE_NAME = "yourusername/saikrupa"
        DOCKER_REGISTRY = "docker.io"
        AWS_EC2_IP = "your-ec2-ip"
        AWS_EC2_USER = "ubuntu"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh 'python3 -m venv venv'
                sh 'source venv/bin/activate && pip install -r requirements.txt'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'source venv/bin/activate && python manage.py test'
            }
        }
        
        stage('Code Quality Check') {
            steps {
                sh 'source venv/bin/activate && pip install pylint'
                sh 'source venv/bin/activate && pylint blog/ core/ saikrupax/ || true'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest
                '''
            }
        }
        
        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE_NAME}:latest
                '''
            }
        }
        
        stage('Deploy to EC2') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    ssh -i ${JENKINS_EC2_KEY} ${AWS_EC2_USER}@${AWS_EC2_IP} << EOF
                    cd /home/ubuntu/saikrupa
                    
                    # Pull latest code
                    git pull origin main
                    
                    # Stop old containers
                    docker-compose down
                    
                    # Start new containers
                    docker-compose up -d --build
                    
                    # Run migrations
                    docker-compose exec -T web python manage.py migrate
                    
                    # Collect static files
                    docker-compose exec -T web python manage.py collectstatic --noinput
                    EOF
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sh '''
                        sleep 10
                        response=$(curl -s -o /dev/null -w "%{http_code}" http://${AWS_EC2_IP})
                        if [ $response -eq 200 ]; then
                            echo "✓ Application is healthy"
                        else
                            echo "✗ Health check failed with status $response"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Notify') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deployment completed successfully!'
                // Add Slack/Email notification here
            }
        }
    }
    
    post {
        failure {
            echo 'Pipeline failed! Notifying team...'
            // Add failure notification
        }
        success {
            echo 'Pipeline succeeded! Application deployed.'
        }
    }
}
```

### Jenkins Setup Instructions

#### 1. Install Jenkins

```bash
# On your Jenkins server
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | \
  sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] \
  https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install -y jenkins openjdk-11-jdk
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

#### 2. Configure GitHub Webhook

1. Go to GitHub Repository Settings → Webhooks → Add Webhook
2. **Payload URL**: `http://your-jenkins-server:8080/github-webhook/`
3. **Content Type**: `application/json`
4. **Events**: Push events

#### 3. Create Jenkins Pipeline Job

1. New Job → Pipeline
2. Configure Git Repository URL
3. Paste above Jenkinsfile content
4. Configure credentials (Docker Hub, AWS EC2 key)
5. Save and trigger manually first

#### 4. Add Jenkins Credentials

1. Manage Jenkins → Manage Credentials
2. Add Docker Hub credentials
3. Add AWS EC2 private key
4. Add GitHub personal access token

### Pipeline Triggers

#### Automatic Trigger (GitHub Webhook)
```
Configured in GitHub repository settings
Triggers on push to main branch
```

#### Manual Trigger
```bash
# Via Jenkins UI or using Jenkins CLI
java -jar jenkins-cli.jar -s http://jenkins-server:8080 build saikrupa -p BUILD_ID=123
```

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Docker-Compose Build Fails
```bash
# Clear cache and rebuild
docker-compose down
docker system prune -a
docker-compose up --build
```

#### PostgreSQL Connection Error
```bash
# Check database service is running
docker-compose ps

# Check database logs
docker-compose logs db

# Verify credentials in .env match docker-compose.yml
```

#### Static Files Not Loading
```bash
# Collect static files again
docker-compose exec web python manage.py collectstatic --noinput --clear

# Check Nginx configuration
docker-compose exec nginx nginx -t
```

#### Port Already in Use
```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :8000

# Kill process and retry
sudo kill -9 <PID>
docker-compose up -d
```

#### Database Migration Issues
```bash
# Rollback to previous state
docker-compose exec web python manage.py migrate blog 0003

# Create and apply new migrations
docker-compose exec web python manage.py makemigrations
docker-compose exec web python manage.py migrate
```

---

## 📊 Monitoring and Logging

### View Application Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs django_app

# Follow logs in real-time
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# With timestamps
docker-compose logs -t
```

### Monitor Container Performance

```bash
# Resource usage statistics
docker stats

# Container details
docker inspect <container_id>

# Disk usage
docker system df
```

### Application Health Monitoring

```bash
# Check if application is responding
curl -I http://localhost/

# Check Django admin
curl -I http://localhost/admin/

# Check API endpoints
curl http://localhost/api/blogs/
```

---

## 🔐 Security Best Practices

### Application Security
- ✅ Keep Django and dependencies updated
- ✅ Use `SECRET_KEY` from environment variables
- ✅ Enable CSRF protection (default in Django)
- ✅ Use HTTPS in production
- ✅ Implement rate limiting
- ✅ Validate and sanitize user inputs
- ✅ Use prepared statements for queries

### Container Security
- ✅ Use non-root user in Dockerfile
- ✅ Scan images for vulnerabilities: `trivy image yourusername/saikrupa`
- ✅ Keep base images updated
- ✅ Don't store secrets in images
- ✅ Use `.dockerignore` to exclude sensitive files

### Infrastructure Security
- ✅ Restrict Security Group to necessary ports only
- ✅ Use VPC for EC2 deployment
- ✅ Enable CloudTrail for audit logging
- ✅ Implement auto-scaling for HA
- ✅ Use RDS for managed database
- ✅ Enable encryption for EBS volumes
- ✅ Regular security patches and updates

---

## 📈 Performance Optimization

### Database Optimization
```python
# Use select_related for foreign keys
Blog.objects.select_related('author').all()

# Use prefetch_related for many-to-many
Blog.objects.prefetch_related('category').all()

# Use only() and defer() to reduce queries
Blog.objects.only('title', 'content').all()
```

### Caching Strategy
```python
# Cache view results
from django.views.decorators.cache import cache_page

@cache_page(60 * 15)  # Cache for 15 minutes
def blog_list(request):
    pass
```

### Static File Optimization
- ✅ Use CDN (CloudFront) for static files
- ✅ Enable gzip compression in Nginx
- ✅ Minimize CSS/JS files
- ✅ Optimize images

### Gunicorn Tuning
```bash
# Adjust workers based on CPU cores
# Formula: (2 × CPU_cores) + 1
gunicorn saikrupax.wsgi:application --workers 5 --worker-class sync

# Use async workers for I/O bound tasks
gunicorn saikrupax.wsgi:application --workers 3 --worker-class gevent
```

---

## 📚 Additional Resources

### Documentation
- [Django Official Documentation](https://docs.djangoproject.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker-Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

### Useful Tools
- [Docker Hub](https://hub.docker.com/) - Container Registry
- [Trivy](https://github.com/aquasecurity/trivy) - Container Security Scanning
- [Docker Bench Security](https://github.com/docker/docker-bench-security) - Security Audit Tool
- [AWS CLI](https://aws.amazon.com/cli/) - AWS Command Line Tool

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the Repository**
   ```bash
   git clone https://github.com/yourusername/saikrupa.git
   cd saikrupa
   git checkout -b feature/your-feature
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make Changes and Commit**
   ```bash
   git add .
   git commit -m "Add amazing feature"
   ```

4. **Push to Branch**
   ```bash
   git push origin feature/amazing-feature
   ```

5. **Open a Pull Request**
   - Describe your changes
   - Link related issues
   - Request review from maintainers

### Code Standards
- Follow PEP 8 for Python code
- Write meaningful commit messages
- Add tests for new features
- Update documentation

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📧 Contact & Support

- **GitHub Issues**: Report bugs and request features via GitHub Issues
- **Discussions**: Join discussions for questions and ideas
- **Email**: your-email@example.com

---

## 🎓 Learning Resources

This project demonstrates several important DevOps concepts:

1. **Containerization**: Docker for creating consistent, reproducible environments
2. **Orchestration**: Docker-Compose for managing multi-container applications
3. **Infrastructure as Code**: Configuration as code approach
4. **CI/CD**: Automated testing and deployment pipeline
5. **Security**: Environment variables, secrets management
6. **Monitoring**: Logging and health checks
7. **Scalability**: Designed for horizontal scaling

---

<div align="center">

**Made with ❤️ by [Your Name]**

⭐ If you found this project helpful, please consider giving it a star!

[⬆ back to top](#saikrupa---django-application-with-devops-architecture)

</div>
