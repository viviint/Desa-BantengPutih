#!/bin/bash

echo "🚀 Setting up Desa Bantengputih Docker Environment..."

# Copy environment file
if [ ! -f .env ]; then
    cp .env.docker .env
    echo "✅ Environment file created"
fi

# Build and start containers
echo "🔨 Building Docker containers..."
docker-compose up -d --build

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 30

# Generate app key if not exists
echo "🔑 Generating application key..."
docker-compose exec app php artisan key:generate --force

# Run migrations and seeders
echo "📦 Running migrations and seeders..."
docker-compose exec app php artisan migrate --force
docker-compose exec app php artisan db:seed --force

# Create storage link
echo "🔗 Creating storage link..."
docker-compose exec app php artisan storage:link

# Set permissions
echo "🔒 Setting permissions..."
docker-compose exec app chown -R www-data:www-data /var/www/storage
docker-compose exec app chown -R www-data:www-data /var/www/bootstrap/cache

# Clear and cache config
echo "🧹 Clearing and caching configuration..."
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

echo "✅ Setup completed!"
echo ""
echo "🌐 Access your application:"
echo "   Website: http://localhost:8000"
echo "   Admin: http://localhost:8000/admin"
echo "   PhpMyAdmin: http://localhost:8080"
echo "   Mailhog: http://localhost:8025"
echo ""
echo "🔐 Default admin credentials:"
echo "   Email: admin@bantengputihlamongan.com"
echo "   Password: password"
