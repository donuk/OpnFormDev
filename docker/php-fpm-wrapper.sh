#!/bin/bash +ex

if [ -d /app/storage ]; then
    rm -rf /etc/initial-storage
    mv /app/storage /etc/initial-storage
fi

if [ ! -d /persist/storage ]; then
    echo "Initialising blank storage dir"
    cp -a /etc/initial-storage /persist/storage
    chmod 777 -R /persist/storage
fi

touch /var/log/opnform.log
chown opnform /var/log/opnform.log

ln -sf /persist/storage /app/storage

export LOG_CHANNEL=errorlog
. /app/.env

[ "x$APP_KEY" != "x" ] || {
    artisan key:generate
    . /app/.env
}
[ "x$JWT_SECRET" != "x" ] || {
    artisan jwt:secret -f
    . /app/.env
}

/usr/sbin/php-fpm8.1

tail -f /var/log/opnform.log
