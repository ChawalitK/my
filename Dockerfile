# Use an official PHP runtime as a base image
FROM php:7.2-apache

RUN apt-get update && \
    apt-get install --yes \
    cron vim g++ gettext libicu-dev openssl bzip2 

RUN apt-get update && \
    apt-get install --yes \
    libbz2-dev libtidy-dev libcurl4-openssl-dev \
    libz-dev libmemcached-dev libxslt-dev git-core libpq-dev

RUN apt-get update && \
    apt-get install --yes  \
    libc-client-dev libkrb5-dev  \
    libxml2-dev libfreetype6-dev \
    libgd-dev libmcrypt-dev bzip2

RUN apt-get update && \
    apt-get install --yes  \
    git unzip curl gnupg zlib1g-dev libpng-dev libonig-dev unixodbc-dev

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev

# Microsoft SQL Server Drivers & Tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools msodbcsql17 \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    source ~/.bashrc


# version fix for PHP7.2
RUN pecl install sqlsrv-5.7.1preview
RUN pecl install pdo_sqlsrv-5.7.1preview


RUN pecl install xdebug-2.9.0
RUN pecl install mongodb
RUN pecl install redis

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd

RUN docker-php-ext-install bz2 bcmath calendar  dba exif gettext iconv intl && \
    docker-php-ext-install soap tidy xsl mbstring zip && \
    docker-php-ext-install mysqli pgsql pdo pdo_mysql pdo_pgsql  && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap && \
    docker-php-ext-configure hash --with-mhash && \
    docker-php-ext-enable xdebug && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-enable redis && \
    docker-php-ext-enable sqlsrv && \
    docker-php-ext-enable pdo_sqlsrv

# Apache Configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && a2enmod remoteip \
    && a2enmod rewrite \
    && a2enmod headers 

# PHP Configuration File 
COPY php.ini /usr/local/etc/php/

# SSL
COPY 000-default-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf

RUN a2enmod ssl 
RUN a2ensite 000-default-ssl.conf
RUN openssl req -subj '/CN=*.viriyah.co.th/O=The Viriyah Insurance Public Company Limited/C=TH' -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/ssl/private/ssl-cert-viriyah.key -out /etc/ssl/certs/ssl-cert-viriyah.pem

# Time Zone
ENV TZ=Asia/Bangkok
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

EXPOSE 80
EXPOSE 443

# './configure' '--build=x86_64-linux-gnu' '--with-config-file-path=/usr/local/etc/php' '--with-config-file-scan-dir=/usr/local/etc/php/conf.d' '--enable-option-checking=fatal' '--with-mhash' '--with-pic' '--enable-ftp' '--enable-mbstring' '--enable-mysqlnd' '--with-password-argon2' '--with-sodium=shared' '--with-pdo-sqlite=/usr' '--with-sqlite3=/usr' '--with-curl' '--with-libedit' '--with-openssl' '--with-zlib' '--with-libdir=lib/x86_64-linux-gnu' '--with-apxs2' '--disable-cgi' 'build_alias=x86_64-linux-gnu'

# docker image build -t viriya-com-webapp-php72-test-build .
# docker run -it --rm -p 8000:80 -p 8443:443 --name vstore-dlt-apache2-ssl-php8.2-sqlsrv5.11 -v ./src:/var/www/html/ vstore-dlt-webapp

