#!/bin/bash

set -e # abort on error

cp /opt/evap/evap/static/maintenance/maintenance.html /var/www/html/
cp /opt/evap/evap/static/images/triangles_gray.svg /var/www/html/
cp /opt/evap/evap/static/images/triangles_color.svg /var/www/html/
cp /opt/evap/evap/static/css/evap.css /var/www/html/maintenance.css
cp /opt/evap/evap/static/images/favicon_64.png /var/www/html/favicon.png
a2ensite -q evap-maintenance.conf
a2dissite -q evap.conf
service apache2 restart
echo "Maintenance mode enabled."
