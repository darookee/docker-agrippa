FROM php:apache
MAINTAINER Nils Uliczka <nils.uliczka@darookee.net>

# Install all requirements
ENV APACHE_RUN_UID 1000
ENV APACHE_RUN_GID 1000
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
       apt-get update > /dev/null && apt-get install -yyq \
           libssl-dev \
           libsqlite3-dev \
           git \
           libbz2-dev \
           curl \
           build-essential \
       > /dev/null \
       && docker-php-ext-install \
           bz2 \
           pdo_mysql \
           mysqli \
           pdo_sqlite \
           pdo \
           iconv \
       > /dev/null \
       && docker-php-ext-enable \
           pdo_mysql \
           bz2 \
           mysqli \
           pdo_sqlite \
           pdo \
           iconv \
       > /dev/null \
       && echo "date.timezone = \"Europe/Berlin\"" > /usr/local/etc/php/php.ini \
       && a2enmod \
           rewrite \
       > /dev/null \
       && apt-get clean \
       > /dev/null && \
       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
       > /dev/null

# Add the entrypoint
COPY entrypoint.sh /usr/sbin/entrypoint.sh
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

ENTRYPOINT ["entrypoint.sh"]

# Get the current version of composer
RUN curl -sLo /usr/local/bin/composer https://getcomposer.org/composer.phar && \
    chmod +x /usr/local/bin/composer && \
    composer create-project unicalabs/agrippa /var/www/html && \
    chown www-data:www-data /var/www/html -Rf

ENV DB_CONNECTION="sqlite"

VOLUME ["/var/www/html/storage"]
