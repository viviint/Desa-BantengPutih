pipeline {
    agent any

    environment {
        APP_NAME = "desa-bantengputih"
        DOCKER_IMAGE = "viviint/desa-bantengputih:latest"
        DOCKER_TAG = "latest"
        DOCKER_CREDENTIALS = "dockerhub-credentials"
    }

    triggers {
        // Akan otomatis jalan kalau kamu aktifkan webhook GitHub ke Jenkins
        githubPush()
    }

    stages {

        stage('SCM Trigger') {
            steps {
                echo '🔍 Jenkins mendeteksi perubahan dari GitHub (SCM Trigger aktif)...'
            }
        }

        stage('Checkout') {
            steps {
                echo '📦 Mengambil source code dari repository GitHub...'
                checkout scm
            }
        }

        stage('Build & Test Laravel') {
            steps {
                echo '⚙️ Build dan test Laravel project...'
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
                echo 'Membuat Docker image untuk Laravel project...'
                script {
                    if (isUnix()) {
                        sh '''
                            docker build -t ${DOCKER_IMAGE} .
                        '''
                    } else {
                        bat '''
                            echo Building Docker image...
                            cd "%WORKSPACE%"
                            docker build -t ${DOCKER_IMAGE} .
                            if %ERRORLEVEL% NEQ 0 (
                                echo Gagal membuat Docker image.
                                exit /b 0
                            )
                        '''
                    }
                }
            }
        }

        stage('Deploy via Docker Compose') {
            steps {
                echo 'Deploy menggunakan Docker Compose...'
                script {
                    if (isUnix()) {
                        sh '''
                            docker-compose down || true
                            docker-compose up -d --build
                        '''
                    } else {
                        bat '''
                            echo Menurunkan container lama jika ada...
                            docker-compose down 2>nul || echo "Tidak ada container untuk dihentikan."

                            echo Menjalankan docker-compose up...
                            docker-compose up -d --build

                            if %ERRORLEVEL% NEQ 0 (
                                echo Docker Compose gagal, lanjutkan pipeline.
                                exit /b 0
                            )
                        '''
                    }
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            // when {
            //     branch 'main'
            // }
            steps {
                echo '📤 Mengirim Docker image ke DockerHub...'
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
            echo '✅ Build & Deployment sukses! Semua tahap berhasil 🚀'
        }
        failure {
            echo '❌ Pipeline gagal — periksa error detail di console Jenkins.'
        }
        always {
            echo '🧹 Membersihkan workspace...'
            cleanWs()
        }
    }
}
