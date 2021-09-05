FROM php:8.0.10-fpm

# xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# mysqli & pdo_mysql
RUN docker-php-ext-install mysqli \
    && docker-php-ext-install pdo_mysql

# php-intl
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        zlib1g-dev \
        libicu-dev \
        g++ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# php-apcu
RUN pecl install apcu \
    && docker-php-ext-enable apcu

# opcache
RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache

# Install GD
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Install zip
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        zlib1g-dev \
        libzip-dev \
    && docker-php-ext-install zip

# Use the default development configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
