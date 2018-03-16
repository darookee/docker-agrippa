#!/bin/bash

# Set UID/GID if not provided with enviromental variable(s).
if [ -z "$APACHE_RUN_UID" ]; then
    APACHE_RUN_UID=$(cat /etc/passwd | grep "$APACHE_RUN_USER" | cut -d: -f3)
    echo "APACHE_RUN_UID variable not specified, defaulting to $APACHE_RUN_UID"
fi

if [ -z "$APACHE_RUN_GID" ]; then
    APACHE_RUN_GID=$(cat /etc/group | grep "$APACHE_RUN_GROUP" | cut -d: -f3)
    echo "APACHE_RUN_GID variable not specified, defaulting to $APACHE_RUN_GID"
fi

# Look for existing group, if not found create $APACHE_RUN_GROUP with specified GID.
FIND_GROUP=$(grep ":$APACHE_RUN_GID:" /etc/group)

if [ -z "$FIND_GROUP" ]; then
    usermod -g users "$APACHE_RUN_USER"
    groupdel "$APACHE_RUN_GROUP"
    groupadd -g $APACHE_RUN_GID "$APACHE_RUN_GROUP"
fi

# Set apache account's UID.
usermod -u $APACHE_RUN_UID -g $APACHE_RUN_GID --non-unique "$APACHE_RUN_USER" > /dev/null 2>&1

pushd /var/www/html

if [ "sqlite" == "$DB_CONNECTION" ]; then
    touch storage/database.sqlite
fi

chown $APACHE_RUN_UID:$APACHE_RUN_GID storage/ -Rf

php artisan migrate

exec apache2-foreground "$@"
