FROM php:fpm

RUN apt-get update \
    && apt-get install -y --no-install-recommends libicu-dev libzip-dev unzip git \
    && docker-php-ext-install intl pdo_mysql mysqli zip \
    && rm -rf /var/lib/apt/lists/*
