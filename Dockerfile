# OS alpine 3.13
FROM nginx:alpine3.17

LABEL Maintainer="KhCloud <wdmsyf@yahoo.com>"
LABEL Description="Lightweight container with Nginx 1.24 & PHP 8.1 based on Alpine Linux."

# alpine & nginx version
RUN cat /etc/os-release | grep PRETTY_NAME && nginx -v

# build arguments
ARG timezone="Asia/Shanghai"
# /usr/share/zoneinfo/Asia/Shanghai

RUN set -x; \
  ## if you get error like this:  php7 (no such package), you need to open line alpine community and edge\testing
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  ## Set Mirror in china
  && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories


# packages
RUN apk update && apk add --no-cache \
	bash \
	supervisor \
	tzdata \
	gettext \
	curl \
	# php
	php7 \
	php7-curl \
	php7-dom \
	php7-fileinfo \
	php7-fpm \
	php7-gd \
	php7-zip \
	php7-gettext \
	php7-json \
	php7-mbstring \
	php7-openssl \
	php7-pdo \
	php7-phar \
	php7-psr \
	php7-opcache \
	php7-session \
	php7-simplexml \
	php7-tokenizer \
	php7-xml \
	php7-zlib \
	&& rm -rf /var/cache/apk/*

# directory links
RUN ln -sf /etc/php7 /etc/php && \
	ln -sf /usr/bin/php7 /usr/bin/php && \
	ln -sf /usr/sbin/php-fpm7 /usr/bin/php-fpm && \
	ln -sf /usr/lib/php7 /usr/lib/php

# timezone
ENV TZ=$timezone \
	COMPOSER_ALLOW_SUPERUSER=1

# RUN cp /usr/share/zoneinfo/${timezone} /etc/localtime \
#   && echo ${timezone} > /etc/timezone \
#   && date

## php composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# set www-data group (82 is the standard uid/gid for www-data in Alpine)
RUN set -x; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -G www-data www-data && exit 0; exit 1

# prepare folders
RUN rm /etc/nginx/conf.d/default.conf && \
	mkdir -p /var/www/public /var/log/supervisord

# copy files
COPY init/bashrc /root/.bashrc
COPY init/supervisord.conf /etc/supervisord.conf
COPY init/nginx.conf /etc/nginx/nginx.conf
COPY init/nginx-sites.conf /etc/nginx/sites-enabled/default
COPY init/php-fpm.conf /etc/php7/php-fpm.d/www.conf
COPY init/index.php /var/www/public
COPY init/start /root/start

#COPY config/conf.d /etc/nginx/http.d/
#COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
#COPY config/fpm-root.conf /etc/php7/php-fpm.d/fpm-root.conf
#COPY config/php.ini /etc/php7/conf.d/custom.ini
#COPY config/supervisord.conf /etc/supervisor.d/supervisord.ini

RUN chmod +x /root/start

# expose
EXPOSE 80

RUN whoami && cat /etc/passwd


# entrypoint
ENTRYPOINT ["/root/start"]

# # Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping


