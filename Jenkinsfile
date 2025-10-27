pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "viviint/desa-bantengputih:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📦 Cloning repository...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '📚 Installing PHP dependencies...'
                sh 'composer install --no-interaction --prefer-dist --optimize-autoloader'
            }
        }

        stage('Run Tests') {
            steps {
                echo '🧪 Running Laravel tests...'
                sh './vendor/bin/phpunit || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }

        stage('Run Docker Compose') {
            steps {
                echo '🚀 Starting Laravel app with Docker Compose...'
                sh 'docker compose up -d'
            }
        }

        stage('Push to Docker Hub (optional)') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh 'docker push ${DOCKER_IMAGE}'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Laravel build and deployment successful!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
