#!/bin/bash

if [ -d /app/storage ]; then
    rm -rf /app/initial-storage
    mv /app/storage /app/initial-storage
fi

if [ ! -d /persist/storage ]; then
    cp -a /app/initial-storage /persist/storage
    chmod 777 -R /persist/storage
fi

touch /var/log/opnform.log
chown opnform /var/log/opnform.log

ln -sf /persist/storage /app/storage

export LOG_CHANNEL=errorlog

/usr/sbin/php-fpm8.1

tail -f /var/log/opnform.log
