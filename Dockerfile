FROM ubuntu:23.04

RUN apt-get update && apt-get install -y supervisor php8.1 php8.1-pgsql php8.1-fpm postgresql-15 nodejs nginx sudo composer php8.1-simplexml php8.1-bcmath php8.1-gd php8.1-curl php8.1-zip npm && apt-get clean

CMD ["/usr/bin/supervisord"]

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ADD docker/postgres-wrapper.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

WORKDIR /app
ADD package.json /app/package.json
ADD package-lock.json /app/package-lock.json
RUN npm install
RUN npm run build


ADD / /app
RUN composer install



ADD docker/php-fpm-wrapper.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh
RUN useradd opnform
ADD docker/php-fpm.conf /etc/php/8.1/fpm/pool.d
ADD docker/nginx.conf /etc/nginx/sites-enabled/default
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

