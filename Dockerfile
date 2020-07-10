FROM php:apache

EXPOSE 80

VOLUME /config
VOLUME /logs

RUN apt-get update -y && \
        apt-get upgrade -y
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libonig-dev \
        libpq-dev
RUN cd /tmp && \
        docker-php-ext-configure gd --with-freetype --with-jpeg && \
        docker-php-ext-install pgsql && \
        docker-php-ext-install gd && \
        docker-php-ext-install mbstring && \
        docker-php-ext-install fileinfo && \
        curl -sSL https://downloads.sourceforge.net/project/mantisbt/mantis-stable/2.24.1/mantisbt-2.24.1.tar.gz | tar xzC /tmp && \
        mv mantisbt-*/* /var/www/html && \
        chown -R www-data:www-data /var/www/html && \
        apt-get -y autoremove && \
        rm -rf /*.zip /tmp/* /var/tmp/* /var/lib/apt/lists/* && \
        mkdir /config && \
        cp /var/www/html/config/* /config && \
        rm -rf /var/www/html/config && \
        ln -s /config /var/www/html	&& \
        chown -R www-data:www-data /config && \
        chown -R www-data:www-data /logs


COPY ./httpd.conf /etc/apache2/sites-available/000-default.conf

COPY ./php.ini $PHP_INI_DIR/conf.d/

COPY ./cleanup.sh ./entrypoint.sh /

RUN chmod 500 /entrypoint.sh /cleanup.sh

ENTRYPOINT /entrypoint.sh
