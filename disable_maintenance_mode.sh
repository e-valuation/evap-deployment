#!/bin/bash

set -e # abort on error

rm --verbose --force /var/www/html/*
a2ensite -q evap.conf
a2dissite -q evap-maintenance.conf
service apache2 restart
echo "Maintenance mode disabled."
