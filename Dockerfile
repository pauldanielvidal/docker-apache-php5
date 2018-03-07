FROM nimmis/apache:14.04
MAINTAINER pauldanielvidal
EXPOSE 80 443

# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
apt-get install -y php5 libapache2-mod-php5  \
php5-fpm php5-cli php5-mysqlnd php5-pgsql php5-sqlite php5-redis \
php5-apcu php5-intl php5-imagick php5-mcrypt php5-json php5-gd php5-curl && \
php5enmod mcrypt && \
rm -rf /var/lib/apt/lists/* && \
cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

#apache rewrite
RUN php5enmod mcrypt
RUN a2enmod rewrite
RUN a2enmod ssl

ADD ./build/install/ /tmp/
ADD ./build/apache2/sites-enabled/ /tmp/apache2/sites-enabled-cms/
RUN cp /tmp/apache2/sites-enabled-cms/*.conf /etc/apache2/sites-enabled/

RUN sed -i 's/AccessFileName .htaccess/AccessFileName .htaccess.mine/g' /etc/apache2/apache2.conf
RUN awk '/<Directory \/var\/www\/>/,/AllowOverride None/{sub("None", "All",$0)}{print}' /etc/apache2/apache2.conf > /tmp/apache2.conf

RUN cp /tmp/apache2.conf /etc/apache2/apache2.conf



