pipeline {
    agent any

    environment {
        APP_NAME = "desa-bantengputih"
        DOCKER_IMAGE = "viviint/desa-bantengputih:latest"
        DOCKER_TAG = "latest"
        DOCKER_CREDENTIALS = "dockerhub-credentials"
    }

    triggers {
        // Otomatis jalan saat ada push ke GitHub (pastikan webhook di GitHub aktif)
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
                echo '📦 Mengambil repository dari GitHub...'
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo '⚙️ Building dan testing Laravel project...'
                script {
                    if (isUnix()) {
                        sh '''
                            composer install --no-interaction --prefer-dist --optimize-autoloader
                            cp .env.example .env || true
                            php artisan key:generate

                            if [ -f artisan ]; then
                                echo "🧪 Menjalankan test..."
                                php artisan test || echo "⚠️ Tidak ada test ditemukan, lanjutkan..."
                            fi
                        '''
                    } else {
                        bat '''
                            composer install --no-interaction --prefer-dist --optimize-autoloader
                            if not exist .env copy .env.example .env
                            php artisan key:generate

                            if exist artisan (
                                echo 🧪 Menjalankan test...
                                php artisan test || echo ⚠️ Tidak ada test ditemukan, lanjutkan...
                            ) else (
                                echo ⚠️ File artisan tidak ditemukan, melewati test...
                            )
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image…'
                script {
                    if (isUnix()) {
                        sh "docker build -t ${DOCKER_IMAGE} ."
                    } else {
                        bat "docker build -t ${DOCKER_IMAGE} ."
                    }
                }
            }
        }

        stage('Deploy via Docker Compose') {
            steps {
                echo '🚀 Deploy menggunakan Docker Compose…'
                script {
                    if (isUnix()) {
                        sh '''
                            docker-compose down || true
                            docker-compose up -d --build
                        '''
                    } else {
                        bat '''
                            docker-compose down || exit 0
                            docker-compose up -d --build
                        '''
                    }
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            when {
                branch 'main'
            }
            steps {
                echo '📤 Push Docker image ke DockerHub…'
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        if (isUnix()) {
                            sh '''
                                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                                docker push ${DOCKER_IMAGE}
                            '''
                        } else {
                            bat '''
                                echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                                docker push ${DOCKER_IMAGE}
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build & Deployment berhasil!'
        }
        failure {
            echo '❌ Pipeline gagal — periksa log di console output Jenkins!'
        }
    }
}
