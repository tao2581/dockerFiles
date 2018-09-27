FROM php:7.1-fpm

MAINTAINER tao2581 <tao2581@126.com>

RUN apt-get install libcurl4-openssl-dev pkg-config libssl-dev libsslcommon2-dev
# 安装 redis \ mongo
RUN pecl install redis-4.0.1 &&\ 
    pecl install mongodb  &&\
    docker-php-ext-enable redis mongodb

# 安装 mysqli \ opcache \ pdo_mysql
RUN docker-php-ext-install opcache && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-enable opcache mysqli pdo_mysql
    
#安装 ldap
RUN apt-get update && apt-get install git -y  
RUN apt-get install ldap-utils libldb-dev libldap2-dev -y
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu 
RUN docker-php-ext-install ldap 
RUN docker-php-ext-install pcntl

# Copy opcache configration
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# install composer 
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 
RUN php composer-setup.php 
RUN php -r "unlink('composer-setup.php');" 
RUN mv composer.phar /usr/local/bin/composer

# 设置时区
RUN echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

ADD ./laravel.ini /usr/local/etc/php/conf.d
ADD ./laravel.pool.conf /usr/local/etc/php-fpm.d/

RUN usermod -u 1000 www-data

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000