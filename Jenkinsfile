pipeline {
    agent any

    environment {
        SECRET_KEY                 = credentials('SECRET_KEY')
        POSTGRES_PASSWORD          = credentials('POSTGRES_PASSWORD')
        DJANGO_SUPERUSER_PASSWORD  = credentials('DJANGO_SUPERUSER_PASSWORD')

        DEBUG                      = "False"
        POSTGRES_DB                = credentials('POSTGRES_DB')
        POSTGRES_USER              = credentials('POSTGRES_USER')
        DJANGO_SUPERUSER_USERNAME  = credentials('DJANGO_SUPERUSER_USERNAME')
        DJANGO_SUPERUSER_EMAIL     = credentials('DJANGO_SUPERUSER_EMAIL')
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Create .env File') {
            steps {
                sh '''
                cat <<EOF > .env
SECRET_KEY=${SECRET_KEY}
DEBUG=${DEBUG}

POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

DJANGO_SUPERUSER_USERNAME=${DJANGO_SUPERUSER_USERNAME}
DJANGO_SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL}
DJANGO_SUPERUSER_PASSWORD=${DJANGO_SUPERUSER_PASSWORD}
EOF
                '''
            }
        }

        stage('Docker Compose Build & Deploy') {
            steps {
                sh '''
                docker-compose down
                docker-compose up -d --build
                '''
            }
        }
    }

    post {
        success {
            echo "🚀 Django app deployed successfully"
        }
        failure {
            echo "❌ Deployment failed"
        }
    }
}
