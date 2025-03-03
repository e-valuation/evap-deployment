#!/usr/bin/env bash

set -e # abort on error

MAIN_CONF=evap.conf
MAINTENANCE_CONF=evap-maintenance.conf

case $1 in
    enable)
        cp --verbose "$(dirname $0)"/maintenance/* /var/www/html/
        a2ensite -q "$MAINTENANCE_CONF"
        a2dissite -q "$MAIN_CONF"
        service apache2 restart
        echo "Maintenance mode enabled."
        ;;
    disable)
        rm --verbose --force /var/www/html/*
        a2ensite -q "$MAIN_CONF"
        a2dissite -q "$MAINTENANCE_CONF"
        service apache2 restart
        echo "Maintenance mode disabled."
        ;;
    *)
        echo "USAGE: $0 {enable,disable}"
        exit 1
        ;;
esac
