#!/bin/bash
set -e

if [ -z "$APP_KEY" ]; then
    echo "APP_KEY not set. Generating a new one..."
    php artisan key:generate --force
fi

exec "$@"
