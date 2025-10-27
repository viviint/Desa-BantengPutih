.PHONY: help build up down restart logs shell db-shell setup clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build Docker containers
	docker-compose build --no-cache

up: ## Start containers
	docker-compose up -d

down: ## Stop containers
	docker-compose down

restart: ## Restart containers
	docker-compose restart

logs: ## Show logs
	docker-compose logs -f

shell: ## Access app container shell
	docker-compose exec app bash

db-shell: ## Access database shell
	docker-compose exec db mysql -u desa_user -p desa_bantengputih

setup: ## Initial setup
	chmod +x docker/setup.sh
	./docker/setup.sh

clean: ## Clean everything
	docker-compose down -v
	docker system prune -f
	docker volume prune -f

migrate: ## Run migrations
	docker-compose exec app php artisan migrate

seed: ## Run seeders
	docker-compose exec app php artisan db:seed

fresh: ## Fresh migrate with seed
	docker-compose exec app php artisan migrate:fresh --seed

cache-clear: ## Clear all caches
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

optimize: ## Optimize application
	docker-compose exec app php artisan config:cache
	docker-compose exec app php artisan route:cache
	docker-compose exec app php artisan view:cache
