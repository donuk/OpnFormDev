FROM --platform=linux/amd64 ubuntu:23.04

RUN apt-get update && apt-get install -y supervisor php8.1 php8.1-pgsql php8.1-fpm postgresql-15 nodejs nginx sudo composer php8.1-simplexml php8.1-bcmath php8.1-gd php8.1-curl php8.1-zip npm && apt-get clean

CMD ["/usr/bin/supervisord"]

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

WORKDIR /app
ADD package.json /app/package.json
ADD package-lock.json /app/package-lock.json
RUN npm install

ADD resources /app/resources
ADD tailwind.config.js vite.config.js postcss.config.js /app/
RUN npm run build

ADD app /app/app
ADD bootstrap /app/bootstrap
ADD config /app/config
ADD database /app/database
ADD public public
ADD routes routes
ADD tests tests
ADD composer.json composer.lock artisan phpunit.xml ./
RUN composer install


ADD docker/postgres-wrapper.sh /usr/local/bin/
ADD docker/php-fpm-wrapper.sh /usr/local/bin/
RUN ln -s /app/artisan /usr/local/bin/artisan
RUN chmod a+x /usr/local/bin/*.sh /app/artisan
RUN useradd opnform
ADD docker/php-fpm.conf /etc/php/8.1/fpm/pool.d
ADD docker/nginx.conf /etc/nginx/sites-enabled/default
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD . .
ADD .env.example .env
