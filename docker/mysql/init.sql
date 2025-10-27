-- MySQL initialization script for Desa Bantengputih
-- This script will be executed when the database container starts

-- Create additional database users if needed
-- CREATE USER 'app_user'@'%' IDENTIFIED BY 'app_password';
-- GRANT ALL PRIVILEGES ON desa_bantengputih.* TO 'app_user'@'%';

-- Set timezone
SET time_zone = '+07:00';

-- Optimize MySQL for Laravel
SET GLOBAL innodb_buffer_pool_size = 268435456; -- 256MB
SET GLOBAL max_connections = 151;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL interactive_timeout = 28800;

-- Flush privileges
FLUSH PRIVILEGES;
