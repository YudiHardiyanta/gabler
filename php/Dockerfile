FROM php:fpm

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get update \
    && apt-get install -y --no-install-recommends libicu-dev libssl-dev libzip-dev unzip git $PHPIZE_DEPS \
    && docker-php-ext-install intl pdo_mysql mysqli zip \
    && pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis \
    && rm -rf /var/lib/apt/lists/*
