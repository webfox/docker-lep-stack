FROM ubuntu:15.10

MAINTAINER Webfox Developers "developers@webfox.co.nz"

# Install required packages
RUN apt-get dist-upgrade; \
    apt-get update; \
    apt-get install -y \
    openssh-server \
    supervisor \
    git \
    zsh \
    vim \
    htop \
    wget \
    curl \
    imagemagick \
    graphicsmagick \
    mysql-client \
    nginx \
    php5-fpm \
    php5-mysql \
    php5-pgsql \
    php5-xdebug \
    php5-memcached \
    php5-redis \
    php5-gd \
    php5-imagick \
    php5-curl

# Add blackfire repo to sources list
RUN wget -O - https://packagecloud.io/gpg.key | apt-key add -
RUN echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list

# Add elastic.co repo to sources list
RUN wget -O - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb http://packages.elastic.co/beats/apt stable main" | tee -a /etc/apt/sources.list.d/beats.list

# Install:
# - Elastic Filebeat: https://www.elastic.co/downloads/beats/filebeat/
# - Elastic Topbeat: https://www.elastic.co/downloads/beats/topbeat/
# - Elastic Packetbeat: https://www.elastic.co/downloads/beats/packetbeat/
RUN apt-get update; \
    apt-get install -y \
    filebeat \
    topbeat \
    packetbeat

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

# NGINX: copy config files to container
ADD resources/nginx/nginx.conf /etc/nginx/nginx.conf
ADD resources/nginx/default-site.conf /etc/nginx/sites-available/default

# PHP-FPM: copy config files to container
ADD resources/php/php.ini /etc/php5/fpm/php.ini
ADD resources/php/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD resources/php/pool.d /etc/php5/fpm/pool.d
ADD resources/php/conf.d/9999-blackfire.ini /etc/php5/fpm/conf.d/9999-blackfire.ini

# Elastic Beats: copy config files to container
ADD resources/elastic-beats/filebeat.yml /etc/filebeat/filebeat.yml
ADD resources/elastic-beats/topbeat.yml /etc/topbeat/topbeat.yml
ADD resources/elastic-beats/packetbeat.yml /etc/packetbeat/packetbeat.yml

# Supervisord: copy config file to container
ADD resources/supervisord/lep-stack.conf /etc/supervisor/supervisord.conf

# Expose container ports
EXPOSE 80 443

VOLUME /app

# Use supervisord to keep processes alive
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
