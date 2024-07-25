FROM php:8.3-fpm

# syntax=docker/dockerfile:1.3-labs

RUN apt-get update
RUN apt-get install -y libzip-dev libpng-dev
RUN apt-get install -y postgresql-client libpq-dev

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
# RUN apt-get -y install --fix-missing apt-utils build-essential git curl libcurl4 libcurl4-openssl-dev zlib1g-dev libzip-dev zip libbz2-dev locales libmcrypt-dev libicu-dev libonig-dev libxml2-dev
#RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pgsql pdo_pgsql gd bcmath zip
RUN pecl install redis
RUN docker-php-ext-enable redis


WORKDIR /usr/share/nginx/html/
ADD composer.json composer.lock artisan ./

# NOTE: The project would build more reliably if all php files were added before running
# composer install.  This would though introduce a dependency which would cause every
# dependency to be re-installed each time any php file is edited.  It may be necessary in
# future to remove this 'optimisation' by moving the `RUN composer install` line after all
# the following ADD commands.

# Running artisan requires the full php app to be installed so we need to remove the
# post-autoload command from the composer file if we want to run composer without
# adding a dependency to all the php files.
RUN sed 's_@php artisan package:discover_/bin/true_;' -i composer.json
ADD app/helpers.php app/helpers.php
RUN composer install --ignore-platform-req=php

ADD app ./app
ADD bootstrap ./bootstrap
ADD config ./config
ADD database ./database
ADD public public
ADD routes routes
ADD tests tests
ADD storage ./storage
RUN chmod 777 -R storage

# Manually run the command we deleted from composer.json earlier
RUN php artisan package:discover --ansi

COPY docker/php-fpm-entrypoint /usr/local/bin/opnform-entrypoint
COPY docker/generate-api-secret.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*

ENTRYPOINT [ "/usr/local/bin/opnform-entrypoint" ]
ADD .env.docker .env
CMD php-fpm
