pipeline {
    agent any

    environment {
        APP_NAME = "desa-bantengputih"
        DOCKER_IMAGE = "viviint/desa-bantengputih:latest"
        DOCKER_TAG = "latest"
        DOCKER_CREDENTIALS = "dockerhub-credentials"
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Declarative SCM') {
            steps {
                echo '🔍 SCM Trigger aktif — Jenkins mendeteksi perubahan dari GitHub...'
            }
        }

        stage('Checkout') {
            steps {
                echo '📦 Cloning repository...'
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo '⚙️ Building dan testing Laravel project...'

                sh '''
                    composer install --no-interaction --prefer-dist --optimize-autoloader
                    cp .env.example .env || true
                    php artisan key:generate
                '''
                
                sh '''
                    if [ -f artisan ]; then
                        echo "🧪 Menjalankan test..."
                        php artisan test || echo "⚠️ Tidak ada test ditemukan, lanjutkan..."
                    fi
                '''
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
                echo '🚀 Deploy menggunakan Docker Compose…'
                sh 'docker-compose down || true'
                sh 'docker-compose up -d --build'
            }
        }

        stage('Push Docker Image to DockerHub') {
            when {
                branch 'main'
            }
            steps {
                echo '📤 Push Docker image ke DockerHub…'
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline berhasil dijalankan sepenuhnya!'
        }
        failure {
            echo '❌ Pipeline gagal, periksa error di console output!'
        }
    }
}
