FROM php:8.2-apache AS builder

#Libraries & Extensions
RUN apt-get update && apt-get install -y --no-install-recommends\
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    git \
    unzip \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install gd bcmath pdo_mysql zip exif

#Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

#PHP Dependencies
WORKDIR /app
COPY app/composer.json app/composer.lock ./
RUN composer install --no-dev --prefer-dist --no-autoloader --no-scripts
COPY app/ .
RUN composer dump-autoload --no-dev --optimize

#Runtime
FROM php:8.2-apache
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng16-16 \
    libjpeg62-turbo \
    libfreetype6 \
    libzip5 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* 

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
RUN docker-php-ext-enable gd bcmath pdo_mysql zip

COPY --from=builder /app /var/www/html

#Tell Apache to serve from the 'public' folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Add rewriting rules directly (no.htaccess needed)
RUN <<EOF cat > /etc/apache2/conf-available/laravel.conf
<Directory /var/www/html/public>
	SetEnvIf X-Forwarded-Proto "https" HTTPS=on    
	Options -Indexes
    	AllowOverride None
    	Require all granted
    	RewriteEngine On
    	RewriteCond %{REQUEST_FILENAME} !-f
    	RewriteCond %{REQUEST_FILENAME} !-d
    	RewriteRule ^ /index.php [L]
</Directory>
EOF

RUN a2enconf laravel && a2enmod rewrite

#Set ownership and permissions
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database \ 
	&& chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database \
	&& chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database


#Copy Entrypoint File
COPY app/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
