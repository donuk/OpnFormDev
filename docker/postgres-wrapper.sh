#!/bin/bash

DATA_DIR=/persist/pgsql/data
CONFIG_FILE=/etc/postgresql/postgresql.conf
PG_BASE=/usr/lib/postgresql/15/

touch $CONFIG_FILE

mkdir -p $DATA_DIR
chown postgres -R $DATA_DIR
chmod 0700 $DATA_DIR

sudo -u postgres $PG_BASE/bin/initdb -D $DATA_DIR
sudo -u postgres $PG_BASE/bin/postgres -D $DATA_DIR -c config_file=$CONFIG_FILE
