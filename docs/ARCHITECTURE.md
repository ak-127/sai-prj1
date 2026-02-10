# Architecture Documentation

Comprehensive technical architecture documentation for the Saikrupa application.

## Table of Contents

- [System Overview](#system-overview)
- [Technology Stack](#technology-stack)
- [Application Architecture](#application-architecture)
- [Deployment Architecture](#deployment-architecture)
- [Database Schema](#database-schema)
- [Security Architecture](#security-architecture)
- [Scalability](#scalability)

---

## System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                             │
│  (Browsers, Mobile Apps, REST Clients)                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ↓ HTTP/HTTPS
┌─────────────────────────────────────────────────────────────────┐
│                    AWS EC2 Instance                             │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Nginx Reverse Proxy                         │ │
│  │  • SSL/TLS Termination                                   │ │
│  │  • Load Balancing                                        │ │
│  │  • Static/Media File Serving                             │ │
│  │  • Compression (Gzip)                                    │ │
│  └───────────┬───────────────────────────────────┬──────────┘ │
│              │                                   │             │
│              ↓ http://web:8000                   ↓             │
│  ┌──────────────────────┐        ┌──────────────────────┐    │
│  │ Django Application   │        │ Static Files Volume  │    │
│  │ (Gunicorn WSGI)      │        │ /vol/web/static      │    │
│  │ • Blog Management    │        └──────────────────────┘    │
│  │ • User Auth          │                                     │
│  │ • Admin Panel        │        ┌──────────────────────┐    │
│  │ (Workers: 5)         │        │ Media Files Volume   │    │
│  │ (Timeout: 60s)       │        │ /vol/web/media       │    │
│  └──────────┬───────────┘        └──────────────────────┘    │
│             │                                                  │
│             ↓ psycopg2 tcp://db:5432                          │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │         PostgreSQL Database                             │ │
│  │  • User Data                                            │ │
│  │  • Blog Posts                                           │ │
│  │  • Categories                                           │ │
│  │  • Media Metadata                                       │ │
│  │  (Persistent Storage: postgres_data volume)            │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
│              ↑ Jenkins CI/CD Deployment                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Backend Stack

```
┌─────────────────────────────────────────┐
│     Application Layer                   │
├─────────────────────────────────────────┤
│ Django 5.0.6                            │
│  • URL Routing (urls.py)                │
│  • Views (views.py)                     │
│  • Models (models.py)                   │
│  • Forms (forms.py)                     │
│  • Admin Interface (admin.py)           │
│  • Middleware Stack                     │
│  • Template Engine                      │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│     WSGI Application Server             │
├─────────────────────────────────────────┤
│ Gunicorn 25.0.3                         │
│  • Worker Pool (sync workers)           │
│  • Request Threading                    │
│  • Graceful Shutdown                    │
│  • Bind: 0.0.0.0:8000                   │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│     Database Layer                      │
├─────────────────────────────────────────┤
│ PostgreSQL 15                           │
│  • Psycopg2 Adapter                     │
│  • Connection Pooling                   │
│  • Transactions Support                 │
│  • ACID Compliance                      │
└─────────────────────────────────────────┘
```

### Frontend Stack

```
HTML5 + CSS3 + JavaScript
    ↓
Bootstrap 4 (Responsive Framework)
    ↓
SB Admin 2 (Admin Dashboard Template)
    ↓
jQuery + Chart.js + DataTables
```

### Infrastructure Stack

```
┌──────────────────────────────┐
│ Container Orchestration      │
├──────────────────────────────┤
│ Docker-Compose               │
│  • Service Definition        │
│  • Network Configuration     │
│  • Volume Management         │
│  • Environment Setup         │
└──────────────────────────────┘
           ↓
┌──────────────────────────────┐
│ Containerization             │
├──────────────────────────────┤
│ Docker                       │
│  • Image Building            │
│  • Container Management      │
│  • Networking                │
│  • Storage                   │
└──────────────────────────────┘
           ↓
┌──────────────────────────────┐
│ Cloud Infrastructure         │
├──────────────────────────────┤
│ AWS EC2                      │
│  • Compute Instance          │
│  • Security Groups           │
│  • Elastic IPs               │
│  • Storage (EBS)             │
└──────────────────────────────┘
```

---

## Application Architecture

### Django Project Structure

```
saikrupax/
├── settings.py              • Database configuration
                            • Installed apps
                            • Middleware stack
                            • Static/Media files
                            • Security settings
│
├── urls.py                 • Main URL router
                            • Path includes from apps
│
├── wsgi.py                 • WSGI entry point
                            • Application object
│
└── asgi.py                 • ASGI entry point (for async)
```

### Blog App

```
blog/
├── models.py              • Category model
                          • Blog model
                          • Image optimization
│
├── views.py              • Blog list view
                         • Blog detail view
                         • Create/Update/Delete views
│
├── urls.py               • /blog/ routes
                         • /blog/<id>/ route
│
├── admin.py              • Admin registration
                         • Admin customization
│
├── forms.py              • Blog creation form
                         • Blog update form
│
├── migrations/           • Database schema changes
│
└── templates/
    └── blog/
        ├── all_blog.html     • Blog listing page
        └── blog_post.html    • Single blog detail
```

### Core App

```
core/
├── models.py             • User Profile model
                         • Profile picture field
│
├── views.py             • User registration
                        • User login/logout
                        • Profile management
                        • Change password
│
├── urls.py              • /register/ route
                        • /login/ route
                        • /profile/ route
│
├── forms.py             • Registration form
                        • Login form
                        • Profile form
│
├── signals.py           • Signal handlers
                        • Post-save signals
                        • Profile creation
│
├── admin.py             • Admin registration
│
├── migrations/          • Database schema changes
│
└── templates/
    └── core/
        ├── base.html         • Base template
        ├── login.html        • Login page
        ├── register.html     • Registration page
        ├── profile.html      • User profile
        ├── dashboard.html    • Admin dashboard
        └── navbar.html       • Navigation bar
```

### Request Flow

```
HTTP Request
    ↓
Nginx (nginx.conf)
    ├─ Static file request? → /vol/web/static/
    ├─ Media file request? → /vol/web/media/
    └─ Dynamic request? ↓
    
Django Application
    ↓
URL Router (urls.py)
    ├─ Match URL pattern
    ├─ Select appropriate app
    └─ Call view ↓
    
View (views.py)
    ├─ Process request
    ├─ Interact with models
    ├─ Business logic execution
    └─ Render template ↓
    
Model (models.py)
    ├─ Query database
    ├─ Apply ORM operations
    └─ Return data ↓
    
Template (*.html)
    ├─ Render HTML
    ├─ Apply CSS/JavaScript
    └─ Response ↓

HTTP Response
```

---

## Deployment Architecture

### Docker-Compose Services

#### PostgreSQL Service
```yaml
Service: db
Image: postgres:15
Container Name: postgres_db
Port: 5432 (internal)
Volumes: postgres_data:/var/lib/postgresql/data
Health Check: enabled
Restart Policy: always
Network: saikrupa_default
Environment:
  - POSTGRES_DB=saikrupa_db
  - POSTGRES_USER=saikrupa_user
  - POSTGRES_PASSWORD=<from .env>
```

#### Django Web Service
```yaml
Service: web
Build: Dockerfile
Port: 8000
Volumes:
  - static_volume:/vol/web/static
  - media_volume:/vol/web/media
Depends On: db (with health check)
Network: saikrupa_default
Environment:
  - All variables from .env
Command: gunicorn saikrupax.wsgi:application --bind 0.0.0.0:8000
```

#### Nginx Service
```yaml
Service: nginx
Image: nginx:latest
Ports: 80:80 (443:443 with SSL)
Volumes:
  - nginx.conf:/etc/nginx/nginx.conf
  - static_volume:/vol/web/static (read-only)
  - media_volume:/vol/web/media (read-only)
Depends On: web
Network: saikrupa_default
```

### Volume Architecture

```
Named Volumes (Persistent):
│
├── postgres_data
│   └─ /var/lib/postgresql/data/
│      ├─ base/ (database files)
│      ├─ pg_wal/ (transaction logs)
│      └─ pg_xact/ (transaction data)
│
├── static_volume
│   └─ /vol/web/static/
│      ├─ admin/ (Django admin static)
│      ├─ blog/ (Blog app static)
│      ├─ core/ (Core app static)
│      └─ vendor/ (Third-party libraries)
│
└── media_volume
    └─ /vol/web/media/
       ├─ blog_feature_image/
       └─ user_profile_images/
```

### Network Architecture

```
┌─────────────────────────────────────┐
│ Default Docker Network              │
│ (saikrupa_default)                  │
│                                     │
│ ┌──────────┐  ┌──────────┐         │
│ │ postgres │  │  web     │         │
│ │ (db)     │  │ (web)    │         │
│ │ 5432     │  │ 8000     │         │
│ └────┬─────┘  └────┬─────┘         │
│      │             │               │
│      └─────────────┼───────────────┼──┐
│                    │               │  │
│             ┌──────▼────────┐      │  │
│             │   nginx       │      │  │
│             │  80, 443      │      │  │
│             └───────────────┘      │  │
│                                    │  │
└────────────────────────────────────┘  │
                                        │
         ┌──────────────────────────────┘
         │
    ┌────▼────────┐
    │   Host      │
    │ localhost   │
    │ Port 80     │
    └─────────────┘
```

---

## Database Schema

### User Model (Django Built-in)
```sql
Table: auth_user
Columns:
  - id (INTEGER, PRIMARY KEY)
  - username (VARCHAR, UNIQUE)
  - email (VARCHAR)
  - password (VARCHAR - hashed)
  - first_name (VARCHAR)
  - last_name (VARCHAR)
  - is_active (BOOLEAN)
  - is_staff (BOOLEAN)
  - is_superuser (BOOLEAN)
  - last_login (TIMESTAMP)
  - date_joined (TIMESTAMP)
```

### Profile Model (Custom)
```sql
Table: core_profile
Columns:
  - id (INTEGER, PRIMARY KEY)
  - user_id (INTEGER, FOREIGN KEY → auth_user)
  - profile_image (VARCHAR - file path)
  - mobile_number (VARCHAR)

Relationships:
  - OneToOne with auth_user
```

### Blog Model
```sql
Table: blog_blog
Columns:
  - id (INTEGER, PRIMARY KEY)
  - title (VARCHAR)
  - feature_image (VARCHAR - file path)
  - content (TEXT)
  - author_id (INTEGER, FOREIGN KEY → auth_user)
  - publish_date (TIMESTAMP)

Relationships:
  - ForeignKey to auth_user (author)
  - ManyToMany with blog_category
```

### Category Model
```sql
Table: blog_category
Columns:
  - id (INTEGER, PRIMARY KEY)
  - name (VARCHAR, UNIQUE)

Relationships:
  - ManyToMany with blog_blog (reverse)
```

### Blog-Category Junction Table
```sql
Table: blog_blog_category
Columns:
  - id (INTEGER, PRIMARY KEY)
  - blog_id (INTEGER, FOREIGN KEY → blog_blog)
  - category_id (INTEGER, FOREIGN KEY → blog_category)

Relationships:
  - Implements ManyToMany relationship
```

---

## Security Architecture

### Authentication & Authorization

```
User Login
   ↓
Verify Credentials (auth.authenticate)
   ├─ Username exists?
   ├─ Password matches (bcrypt/PBKDF2)?
   └─ User active? ↓
Create Session
   ├─ Session token
   ├─ Session data (user_id)
   ├─ Expiration time
   └─ Store in database ↓
Set Cookie
   ├─ HTTP-only flag
   ├─ Secure flag (HTTPS only)
   ├─ SameSite attribute
   └─ Send to client ↓
Client Authenticated
```

### Password Security

```
Plain Text Password:
   ↓ (PBKDF2)
Hashed Password (in database)
   ↓ (on login attempt)
Verify against stored hash
```

### CSRF Protection

```
Form Submission:
   ├─ Generate CSRF token
   ├─ Include in form {{ csrf_token }}
   ├─ Client submits token with form data
   └─ Server validates token ↓
Token Valid? → Process Form
Token Invalid? → Reject (403 Forbidden)
```

### Environment Variable Security

```
Production .env (Never in Git)
   ├─ SECRET_KEY (50+ characters, random)
   ├─ DATABASE credentials
   ├─ AWS credentials (if using)
   ├─ API keys
   └─ Email passwords ↓
   
Docker-Compose Load
   ├─ Parse .env file
   ├─ Inject into containers
   ├─ Set as environment variables
   └─ Access in settings.py via os.getenv()
```

### SSL/TLS Configuration

```
Client → HTTPS Request (encrypted)
   ↓
Nginx (SSL/TLS Termination)
   ├─ Decrypt request
   ├─ Verify certificate validity
   ├─ Check cipher suite
   └─ Pass to Django (HTTP) ↓

Django (Internal Communication)
   ├─ Process request
   ├─ Generate response
   └─ Return to Nginx ↓

Nginx → HTTPS Response (encrypted)
   └─ Encrypt response
   └─ Send to client
```

### Security Headers

```
Strict-Transport-Security
   → Force HTTPS for future requests

X-Content-Type-Options: nosniff
   → Prevent MIME type sniffing

X-Frame-Options: SAMEORIGIN
   → Prevent clickjacking

X-XSS-Protection: 1; mode=block
   → Enable browser XSS protection

Content-Security-Policy
   → Control resource loading
```

---

## Scalability

### Horizontal Scaling Strategy

```
Multiple EC2 Instances:
┌─────────────────┐
│ Load Balancer   │ (AWS ELB/ALB)
│ (Port 80/443)   │
└────────┬────────┘
         │
         ├─────────────┬──────────────┬──────────────┐
         ↓             ↓              ↓              ↓
    ┌─────────────┐┌─────────────┐┌─────────────┐
    │ EC2 #1      ││ EC2 #2      ││ EC2 #3      │
    │ Django App  ││ Django App  ││ Django App  │
    │ + Nginx     ││ + Nginx     ││ + Nginx     │
    └─────┬───────┘└─────┬───────┘└─────┬───────┘
          │              │              │
          └──────────────┬──────────────┘
                         ↓
                    ┌─────────────────┐
                    │ RDS PostgreSQL  │
                    │ (Shared DB)     │
                    │ (Multi-AZ)      │
                    └─────────────────┘
```

### Vertical Scaling Strategy

```
Increase Instance Resources:
t3.micro → t3.small → t3.medium → t3.large

Scale Django Application:
Adjust Gunicorn workers: (2 × CPU_cores) + 1

Increase Database Resources:
Switch from t3.small RDS to t3.large or dedicated instance
```

### Database Scaling

```
Single Database (Current):
All reads and writes → Single PostgreSQL instance

Read Replicas (Future):
Primary DB (writes) → Replica 1 (reads) → Replica 2 (reads)

Sharding (Advanced):
Blog Data → Shard 1
User Data → Shard 2
Category Data → Shard 1
```

### Caching Strategy

```
Browser Cache
   ├─ Cache-Control headers
   └─ Expires headers
   
Application Cache
   ├─ Django caching framework
   ├─ Redis cache backend
   └─ Query caching
   
CDN Cache
   ├─ CloudFront for static files
   ├─ Static content distribution
   └─ Reduced server load
   
Database Cache
   ├─ Query result caching
   ├─ Redis/Memcached
   └─ Reduces DB queries
```

### Performance Optimization

```
Static File Serving:
Django (compress) + Nginx (serve) + CDN (distribute)

Database Queries:
Query optimization → Indexing → Caching → Replication

Application Code:
Middleware optimization → View caching → Background tasks

Infrastructure:
Right-sized instances → Auto-scaling → Load balancing
```

---

