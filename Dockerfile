############################################################
# Dockerfile to be built CentOS,Nginx and PHP 7.2 image
# Based on CentOS
############################################################

# Set the base image to centos
FROM centos:latest

# File Author / Maintainer
MAINTAINER Zhihu Wang <vagranttiger@gmail.com>

# Add the ngix and PHP dependent repository
ADD nginx.repo /etc/yum.repos.d/nginx.repo

# Installing nginx 
RUN yum -y install nginx

# Installing PHP
RUN yum -y install nginx php-fpm php-common

# Installing supervisor
RUN yum install -y epel-release
RUN yum install -y supervisor


# Adding the configuration file of the nginx
ADD nginx-conf/nginx.conf /etc/nginx/nginx.conf
ADD nginx-conf/default.conf /etc/nginx/conf.d/default.conf
ADD nginx-conf/fastcgi.conf /etc/nginx/conf.d/fastcgi.conf

# Adding the configuration file of the Supervisor
ADD supervisord.conf /etc/

#install php 7.2
RUN yum install -y wget
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN wget http://rpms.remirepo.net/enterprise/remi-release-8.rpm
RUN rpm -Uvh remi-release-8.rpm epel-release-latest-8.noarch.rpm
RUN yum install -y yum-utils
#RUN yum-config-manager --enable remi-php72

RUN yum install -y php
RUN yum update -y

#install php module
RUN yum install -y mod_ssl php-gd php-bcmath php-intl php-mbstring php72-php-pecl-mcrypt php-process php-pdo php72-php-pecl-mysql php-mysqlnd php-xml php-pecl-zendopcache php-pear php72-php-pecl-mongodb php72-php-pecl-couchbase2 php72-php-pecl-igbinary php72-php-pecl-redis5 php72-php-json

# Configure and secure PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini && \
    sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php.ini && \
    sed -i '/^listen = /clisten = 0.0.0.0:9000' /etc/php-fpm.d/www.conf && \
    sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php-fpm.d/www.conf && \
    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php-fpm.d/www.conf && \
    sed -i "s/php_admin_flag\[log_errors\] = .*/;php_admin_flag[log_errors] =/" /etc/php-fpm.d/www.conf && \
    sed -i "s/php_admin_value\[error_log\] =.*/;php_admin_value[error_log] =/" /etc/php-fpm.d/www.conf && \
    sed -i "s/php_admin_value\[error_log\] =.*/;php_admin_value[error_log] =/" /etc/php-fpm.d/www.conf && \
    echo "php_admin_value[display_errors] = 'stderr'" >> /etc/php-fpm.d/www.conf

# create the pid default dir
RUN mkdir /run/php-fpm

ADD php-modules/20-json.ini /etc/php.d/
ADD php-modules/20-igbinary.ini /etc/php.d/
ADD php-modules/20-msgpack.ini /etc/php.d/
ADD php-modules/30-redis.ini /etc/php.d/

# Set the port to 80 
EXPOSE 80

# Executing supervisord
CMD ["supervisord", "-n"]