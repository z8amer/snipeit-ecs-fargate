#!/bin/sh
# force rebuild
set -e

echo "Optimizing framework caches..."
php artisan config:cache
php artisan route:cache

echo "Container booting up cleanly..."
exec "$@"
