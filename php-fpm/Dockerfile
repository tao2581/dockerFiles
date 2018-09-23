From mileschou/phalcon:7.1-fpm

RUN  apt-get update && apt-get install -y sudo

# redis 扩展
RUN pecl install -o -f redis \    
    && pecl install mongodb  \
    && docker-php-ext-enable mongodb \
    &&  rm -rf /tmp/pear \
    &&  echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \

# composer 
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 
RUN php composer-setup.php 
RUN php -r "unlink('composer-setup.php');" 
RUN mv composer.phar /usr/local/bin/composer

#安装 ldap
RUN apt-get install git -y  
RUN apt-get install ldap-utils libldb-dev libldap2-dev -y
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu 
RUN docker-php-ext-install ldap 
RUN docker-php-ext-install pcntl

#安装 gd
RUN apt-get update && apt-get install -y libpng-dev  && apt-get  install -y zlib1g-dev && apt-get install -y wget

RUN  docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install gd \
    && docker-php-ext-install zip

# 设置时区
RUN echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

ADD ./laravel.ini /usr/local/etc/php/conf.d
ADD ./laravel.pool.conf /usr/local/etc/php-fpm.d/

RUN rm -r /var/lib/apt/lists/*

RUN usermod -u 1000 www-data

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
