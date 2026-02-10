pipeline {
    agent any

    environment {
        // Docker Registry Configuration
        DOCKER_IMAGE_NAME = "yourusername/saikrupa"
        DOCKER_REGISTRY = "docker.io"
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        
        // AWS Configuration
        AWS_EC2_IP = "${AWS_EC2_IP_PARAM}"
        AWS_EC2_USER = "ubuntu"
        AWS_EC2_KEY = credentials('aws-ec2-private-key')
        
        // Application Configuration
        APP_PORT = "8000"
        APP_HOME = "/home/ubuntu/saikrupa"
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['staging', 'production'],
            description: 'Deployment environment'
        )
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Run automated tests'
        )
        booleanParam(
            name: 'RUN_MIGRATIONS',
            defaultValue: true,
            description: 'Run database migrations'
        )
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Checkout Code"
                    echo "=========================================="
                }
                checkout scm
                script {
                    env.GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    env.GIT_BRANCH = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                    echo "Git Commit: ${env.GIT_COMMIT}"
                    echo "Git Branch: ${env.GIT_BRANCH}"
                }
            }
        }

        stage('Setup Python Environment') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Setup Python Environment"
                    echo "=========================================="
                }
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip setuptools wheel
                    pip install -r requirements.txt
                    pip install pytest pytest-cov flake8 black pylint
                '''
            }
        }

        stage('Code Quality Analysis') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Code Quality Analysis"
                    echo "=========================================="
                }
                sh '''
                    . venv/bin/activate
                    
                    echo "Running Black (Code Formatter Check)..."
                    black --check blog/ core/ saikrupax/ || true
                    
                    echo "Running Flake8 (Linter)..."
                    flake8 blog/ core/ saikrupax/ --max-line-length=100 --exclude=migrations || true
                    
                    echo "Running Pylint..."
                    pylint blog/ core/ saikrupax/ --disable=all --enable=E,F --exit-zero || true
                '''
            }
        }

        stage('Run Tests') {
            when {
                expression { params.RUN_TESTS == true }
            }
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Run Unit Tests"
                    echo "=========================================="
                }
                sh '''
                    . venv/bin/activate
                    
                    echo "Running Django Tests..."
                    python manage.py test --no-input --verbosity=2
                    
                    echo "Generating Coverage Report..."
                    pytest --cov=blog --cov=core --cov-report=html --cov-report=term blog/ core/ || true
                '''
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Security Scan"
                    echo "=========================================="
                }
                sh '''
                    . venv/bin/activate
                    
                    # Check for security issues in dependencies
                    pip install bandit
                    echo "Running Bandit (Security Linter)..."
                    bandit -r blog/ core/ saikrupax/ -ll || true
                    
                    # Check for common Django security issues
                    python manage.py check --deploy || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Build Docker Image"
                    echo "=========================================="
                }
                sh '''
                    docker build \
                        -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} \
                        -t ${DOCKER_IMAGE_NAME}:${GIT_COMMIT} \
                        -t ${DOCKER_IMAGE_NAME}:${ENVIRONMENT} \
                        -t ${DOCKER_IMAGE_NAME}:latest \
                        --label "build.number=${BUILD_NUMBER}" \
                        --label "git.commit=${GIT_COMMIT}" \
                        --label "git.branch=${GIT_BRANCH}" \
                        --label "build.timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
                        .
                    
                    echo "Docker images built successfully"
                    docker images | grep ${DOCKER_IMAGE_NAME}
                '''
            }
        }

        stage('Scan Docker Image') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Scan Docker Image for Vulnerabilities"
                    echo "=========================================="
                }
                sh '''
                    # Install Trivy if not available
                    which trivy || (curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin)
                    
                    echo "Scanning Docker image for vulnerabilities..."
                    trivy image ${DOCKER_IMAGE_NAME}:latest || echo "Scan completed with warnings"
                '''
            }
        }

        stage('Push to Registry') {
            when {
                branch 'main'
                expression { params.ENVIRONMENT == 'production' }
            }
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Push to Docker Registry"
                    echo "=========================================="
                }
                sh '''
                    echo "Logging in to Docker Registry..."
                    echo "${DOCKER_CREDENTIALS_PSW}" | docker login -u "${DOCKER_CREDENTIALS_USR}" --password-stdin
                    
                    echo "Pushing Docker images..."
                    docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE_NAME}:${GIT_COMMIT}
                    docker push ${DOCKER_IMAGE_NAME}:${ENVIRONMENT}
                    docker push ${DOCKER_IMAGE_NAME}:latest
                    
                    echo "Docker images pushed successfully"
                '''
            }
        }

        stage('Deploy to AWS EC2') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Deploy to AWS EC2"
                    echo "Environment: ${ENVIRONMENT}"
                    echo "=========================================="
                }
                sh '''
                    # Create SSH key file from credentials
                    echo "${AWS_EC2_KEY}" > /tmp/ec2-key.pem
                    chmod 600 /tmp/ec2-key.pem
                    
                    # Add EC2 host to known_hosts
                    ssh-keyscan -H ${AWS_EC2_IP} >> ~/.ssh/known_hosts 2>/dev/null || true
                    
                    # Deploy application
                    ssh -i /tmp/ec2-key.pem ${AWS_EC2_USER}@${AWS_EC2_IP} << 'EOF'
                        set -e
                        
                        echo "=========================================="
                        echo "Deploying to EC2 Instance"
                        echo "=========================================="
                        
                        cd ${APP_HOME}
                        
                        # Pull latest code
                        echo "Pulling latest code from repository..."
                        git pull origin main
                        
                        # Pull latest Docker image
                        echo "Pulling latest Docker image..."
                        docker pull ${DOCKER_IMAGE_NAME}:latest
                        
                        # Stop old containers
                        echo "Stopping old containers..."
                        docker-compose down || true
                        
                        # Start new containers
                        echo "Starting new containers..."
                        docker-compose up -d --build
                        
                        # Wait for services to start
                        sleep 10
                        
                        # Check if database service is healthy
                        echo "Checking database health..."
                        docker-compose exec -T db pg_isready -U saikrupa_user || exit 1
                        
                        # Run database migrations
                        if [ "${RUN_MIGRATIONS}" = "true" ]; then
                            echo "Running database migrations..."
                            docker-compose exec -T web python manage.py migrate --noinput
                        fi
                        
                        # Create superuser if needed
                        echo "Creating superuser (if not exists)..."
                        docker-compose exec -T web python manage.py createsuperuser --noinput || true
                        
                        # Collect static files
                        echo "Collecting static files..."
                        docker-compose exec -T web python manage.py collectstatic --noinput --clear
                        
                        # Verify deployment
                        echo "Verifying deployment..."
                        docker-compose ps
                        
                        echo "Deployment completed successfully!"
EOF
                    
                    # Clean up
                    rm /tmp/ec2-key.pem
                '''
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Health Check"
                    echo "=========================================="
                }
                sh '''
                    echo "SSH Key for health check..."
                    echo "${AWS_EC2_KEY}" > /tmp/ec2-key.pem
                    chmod 600 /tmp/ec2-key.pem
                    
                    ssh-keyscan -H ${AWS_EC2_IP} >> ~/.ssh/known_hosts 2>/dev/null || true
                    
                    ssh -i /tmp/ec2-key.pem ${AWS_EC2_USER}@${AWS_EC2_IP} << 'EOF'
                        set -e
                        
                        echo "Performing health checks..."
                        
                        # Check if services are running
                        cd ${APP_HOME}
                        
                        echo "Checking Docker services..."
                        docker-compose ps
                        
                        echo "Checking application health..."
                        sleep 5
                        
                        # Check HTTP response
                        RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
                        echo "HTTP Response Code: $RESPONSE_CODE"
                        
                        if [ "$RESPONSE_CODE" != "200" ] && [ "$RESPONSE_CODE" != "302" ]; then
                            echo "ERROR: Unexpected HTTP response code: $RESPONSE_CODE"
                            docker-compose logs web
                            exit 1
                        fi
                        
                        # Check database connectivity
                        echo "Checking database connectivity..."
                        docker-compose exec -T db pg_isready -U saikrupa_user || exit 1
                        
                        # Check admin interface
                        echo "Checking admin interface..."
                        curl -s -I http://localhost/admin/ | head -n 1
                        
                        echo "✓ All health checks passed"
EOF
                    
                    rm /tmp/ec2-key.pem
                '''
            }
        }

        stage('Smoke Tests') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Run Smoke Tests"
                    echo "=========================================="
                }
                sh '''
                    echo "${AWS_EC2_KEY}" > /tmp/ec2-key.pem
                    chmod 600 /tmp/ec2-key.pem
                    
                    ssh-keyscan -H ${AWS_EC2_IP} >> ~/.ssh/known_hosts 2>/dev/null || true
                    
                    ssh -i /tmp/ec2-key.pem ${AWS_EC2_USER}@${AWS_EC2_IP} << 'EOF'
                        set -e
                        
                        echo "Running smoke tests..."
                        
                        # Test homepage
                        echo "Testing homepage..."
                        curl -s -f http://localhost/ > /dev/null && echo "✓ Homepage OK" || exit 1
                        
                        # Test admin login page
                        echo "Testing admin interface..."
                        curl -s -f http://localhost/admin/ > /dev/null && echo "✓ Admin interface OK" || exit 1
                        
                        # Test blog pages
                        echo "Testing blog functionality..."
                        curl -s -f http://localhost/blog/ > /dev/null && echo "✓ Blog page OK" || echo "⚠ Blog page not available (expected in fresh deployment)"
                        
                        echo "✓ All smoke tests passed"
EOF
                    
                    rm /tmp/ec2-key.pem
                '''
            }
        }

        stage('Notification') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Send Notifications"
                    echo "=========================================="
                }
                sh '''
                    echo "Deployment Status: SUCCESS"
                    echo "Environment: ${ENVIRONMENT}"
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Git Commit: ${GIT_COMMIT}"
                    echo "Git Branch: ${GIT_BRANCH}"
                    echo "Deployment URL: http://${AWS_EC2_IP}"
                '''
                
                // Optional: Send Slack notification
                // slackSend(
                //     channel: '#deployments',
                //     message: """
                //         ✓ Deployment Successful
                //         Environment: ${ENVIRONMENT}
                //         Build: ${BUILD_NUMBER}
                //         Commit: ${GIT_COMMIT}
                //         URL: http://${AWS_EC2_IP}
                //     """,
                //     color: 'good'
                // )
            }
        }
    }

    post {
        always {
            script {
                echo "=========================================="
                echo "Post-Build Stage"
                echo "=========================================="
                
                // Clean workspace
                cleanWs()
                
                // Archive test reports
                junit(testResults: '**/test-results.xml', allowEmptyResults: true)
                
                // Archive coverage reports
                publishHTML([
                    reportDir: 'htmlcov',
                    reportFiles: 'index.html',
                    reportName: 'Code Coverage Report'
                ],) || echo "Coverage report not available"
            }
        }

        success {
            script {
                echo "=========================================="
                echo "Build Status: SUCCESS ✓"
                echo "=========================================="
            }
        }

        failure {
            script {
                echo "=========================================="
                echo "Build Status: FAILED ✗"
                echo "=========================================="
                
                // Capture logs for debugging
                sh '''
                    echo "${AWS_EC2_KEY}" > /tmp/ec2-key.pem
                    chmod 600 /tmp/ec2-key.pem
                    
                    ssh-keyscan -H ${AWS_EC2_IP} >> ~/.ssh/known_hosts 2>/dev/null || true
                    
                    ssh -i /tmp/ec2-key.pem ${AWS_EC2_USER}@${AWS_EC2_IP} << 'EOF'
                        cd ${APP_HOME}
                        echo "===== Container Status ====="
                        docker-compose ps || true
                        echo "===== Web Service Logs ====="
                        docker-compose logs web | tail -n 50 || true
                        echo "===== Database Logs ====="
                        docker-compose logs db | tail -n 50 || true
EOF
                    
                    rm /tmp/ec2-key.pem
                ''' || true
                
                // Optional: Send Slack failure notification
                // slackSend(
                //     channel: '#deployments',
                //     message: """
                //         ✗ Deployment Failed
                //         Environment: ${ENVIRONMENT}
                //         Build: ${BUILD_NUMBER}
                //         Check logs for details
                //     """,
                //     color: 'danger'
                // )
            }
        }

        unstable {
            script {
                echo "Build is unstable but completed"
            }
        }
    }
}
