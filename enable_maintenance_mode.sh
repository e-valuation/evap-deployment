#!/bin/bash

set -e # abort on error

cp --verbose "$0/../maintenance/*" /var/www/html/
a2ensite -q evap-maintenance.conf
a2dissite -q evap.conf
service apache2 restart
echo "Maintenance mode enabled."
