############
# Base image
############
ARG BASE_IMAGE_VERSION=alpine3.18
ARG PHPVERSION=8.3
FROM php:${PHPVERSION}-${BASE_IMAGE_VERSION}

############
# Args
############
ARG APK_CACHE=--no-cache
ARG VERSION_ADMINEREVO=4.8.2

#############
# Set env var
#############
ENV WEB_USERNAME www-data
ENV WEB_GROUPNAME www-data

#############
# MAIN
#############

# Ensure Username and Groupname are present
# www-data on Alpine (uid=82, gid=82) --> switch to 33 as in Debian
#          remove (xfs:33) user before.
RUN set -eux \
 && sed -i -e "/:33:/d" -e "s/:82/:${WEB_GID:=33}/g" /etc/group \
 && sed -i -e "/:33:/d" -e "s/:82/:${WEB_UID:=33}/g" /etc/passwd \
 && install -d -o ${WEB_USERNAME} -g ${WEB_GROUPNAME} -m 775 /var/www/html

## Default dir for apps
WORKDIR /var/www/html

# Entrypoint -> scripts in /ep.d/*.sh
RUN mkdir -p -m 755 /ep.d
COPY .docker/config/fpm/ep.sh /ep.sh
RUN chmod -R 755 /ep.sh /ep.d/
## At the end, ep.sh does "exec $@" (CMD)
ENTRYPOINT ["/ep.sh"]
CMD ["/usr/local/bin/php", "--server 0.0.0.0:8000"]

COPY .docker/config/scripts/*.sh /

RUN set -eux; \
    apk update \
    && apk add $APK_CACHE $PHPIZE_DEPS git icu-dev icu-data-full libzip-dev zip libpng-dev libjpeg-turbo-dev freetype-dev postgresql-dev libaio libnsl gcompat \
      libc6-compat zlib-dev \
    && docker-php-ext-install pgsql pdo_pgsql \
    && docker-php-ext-enable pdo_pgsql \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

RUN git clone https://github.com/adminerevo/adminerevo.git \
    && git config --global --add safe.directory /var/www/html/adminerevo

RUN chown -R ${WEB_USERNAME}:${WEB_GROUPNAME} ./ \
    && chmod -R 755 ./

RUN cd adminerevo \
    && php compile.php \
    && git submodule update --init --recursive

EXPOSE 8000

WORKDIR /var/www/html/adminerevo
