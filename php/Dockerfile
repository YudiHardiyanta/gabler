FROM php:fpm

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get update \
    && apt-get install -y --no-install-recommends libicu-dev libzip-dev unzip git \
    && docker-php-ext-install intl pdo_mysql mysqli zip \
    && rm -rf /var/lib/apt/lists/*
