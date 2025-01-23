 # the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/compose/compose-file/#target

ARG PHP_VERSION=8.2
ARG NGINX_VERSION=1.23
ARG ALPINE_VERSION=3
ARG REGISTRY=ghcr.io/itautomotive-dev/golden-docker-images/

#######################################################
# "symfony_php"
#######################################################

FROM ${REGISTRY}php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS symfony_php
ARG APP_ENV=prod
ARG CONF_NAME=${APP_ENV}
ARG BUILD_VERSION
ARG BUILD_SHA
ENV BUILD_VERSION=${BUILD_VERSION}
ENV BUILD_SHA=${BUILD_SHA}
ENV IT_SYMFONY_DOC_MIGRAT_MIGRAT=true

# prevent the reinstallation of vendors at every changes in the source code
COPY --chown=www-data:www-data composer.json ./
COPY --chown=www-data:www-data composer.lock ./
COPY --chown=www-data:www-data symfony.lock ./
COPY --chown=www-data:www-data auth.json ./
COPY --chown=www-data:www-data package*.json ./

RUN set -eux && \
	composer install --prefer-dist --no-autoloader --no-scripts --no-progress && \
	composer clear-cache

# copy only specifically what we need
COPY --chown=www-data:www-data docker/symfony/.env.${CONF_NAME} ./.env
COPY --chown=www-data:www-data docker/symfony/.env.test .env.test
COPY --chown=www-data:www-data bin bin/
COPY --chown=www-data:www-data config config/
COPY --chown=www-data:www-data public public/
COPY --chown=www-data:www-data src src/
COPY --chown=www-data:www-data templates templates/
COPY --chown=www-data:www-data migrations migrations/
COPY --chown=www-data:www-data data_migrations data_migrations/

RUN set -eux && \
    chown www-data:www-data -R var && \
	composer dump-autoload --classmap-authoritative && \
	chmod +x bin/console && \
  rm auth.json && \
	sync

VOLUME /srv/app/var
VOLUME /srv/app/public

#######################################################
# "symfony_php_dev" stage
#######################################################
FROM symfony_php AS symfony_php_dev
ARG APP_ENV=dev

RUN XDEBUG_VERSION=`echo $PHP_VERSION | cut -f1,2 -d . | tr -d .` && \
    apk add php${XDEBUG_VERSION}-pecl-xdebug && \
    extDir="$(php -d 'display_errors=stderr' -r 'echo ini_get("extension_dir");')" && \
    cp /usr/lib/php${XDEBUG_VERSION}/modules/xdebug.so ${extDir} && \
    docker-php-ext-enable xdebug

RUN rm $PHP_INI_DIR/php.ini && ln -s $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

RUN echo "" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "zend_extension=xdebug.so" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.cli_color=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.mode=develop,debug,coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
