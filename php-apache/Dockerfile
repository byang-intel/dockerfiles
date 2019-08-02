FROM php:7.2-apache

RUN set -ex; \
        \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                libfreetype6-dev \
                libjpeg-dev \
                libpng-dev \
                libwebp-dev \
                libxpm-dev \
        ; \
        \
        docker-php-ext-install exif gd mysqli ; \
        \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        rm -rf /var/lib/apt/lists/*
