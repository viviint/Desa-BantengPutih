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

        stage('Install PHP Dependencies') {
            steps {
                echo '📚 Installing PHP dependencies…'
                sh 'composer install --no-interaction --prefer-dist --optimize-autoloader'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image…'
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Deploy via Docker Compose') {
            steps {
                echo '🚀 Starting services with Docker Compose…'
                sh 'docker-compose down'
                sh 'docker-compose up -d --build'
            }
        }

        stage('Push Docker Image to Registry') {
            when {
                branch 'main'
            }
            steps {
                echo '📤 Pushing Docker image to registry…'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build & deployment successful!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
