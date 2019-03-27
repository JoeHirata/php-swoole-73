FROM centos:7

# Setup
RUN yum -y install epel-release wget
RUN cd /tmp && wget https://downloads.php.net/~cmb/php-7.3.0RC5.tar.gz -O php-7.3.0RC5 && tar zxvf php-7.3.0RC5

RUN yum -y upgrade

# Dependencies installation
RUN yum -y install git gcc gcc-c++ make libxml2-devel libicu-devel openssl-devel autoconf

RUN wget https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz -O cmake-3.12.0-Linux-x86_64.tar.gz && \
    tar zxvf cmake-3.12.0-Linux-x86_64.tar.gz

RUN rm -rf /usr/share/aclocal && \
    rm -rf /usr/share/applications && \
    rm -rf /usr/share/mime

RUN mv -f cmake-3.12.0-Linux-x86_64/bin/* /usr/bin/ && \
    mv -f cmake-3.12.0-Linux-x86_64/share/* /usr/share/

RUN mkdir /tmp/libzip && \
    cd /tmp/libzip && \
    curl -sSLO https://libzip.org/download/libzip-1.4.0.tar.gz && \
    tar zxf libzip-1.4.0.tar.gz && \
    cd libzip-1.4.0/ && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install

# PHP installation
RUN cd /tmp/php-7.3.0RC5 && \
    ./configure --enable-pcntl --enable-intl --enable-zip --enable-pdo --enable-sockets --with-openssl && \
    make && \
    make install

RUN yum -y install autoconf

RUN cd /tmp && wget https://getcomposer.org/download/1.6.5/composer.phar && \
    mv composer.phar /bin/composer && \
    chmod a=rx /bin/composer

# Swoole Installation
RUN git clone https://github.com/swoole/swoole-src.git && \
    cd swoole-src && \
    phpize && \
    ./configure && \
    make && \
    make install

# Add an extension to php.ini
RUN echo extension=swoole.so >> /usr/local/lib/php.ini

CMD cd /var/www/html && \
    php -S 0.0.0.0:8080
