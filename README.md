# EvaP Deployment Configuration

This repository contains an example configuration of EvaP. To set up an instance of EvaP on an Ubuntu server, follow these steps:

1. Update the system (`apt update -y; apt upgrade -y`).
2. Install Python (`apt install python3 python3-venv`).
3. Install and enable Apache, Postgres, and Redis (`apt install apache2 libapache2-mod-wsgi-py3 postgresql redis`, `service apache2 start; service postgresql start; service redis-server start`).
4. Create Postgres `evap` user and database (in `sudo -u postgres psql` run `create user evap password 'evap' createdb; create database evap owner evap;`).
5. Create system `evap` user (`useradd -m evap`) and run the following in `sudo -i -u evap`:
    1. (You probably want to clone the `evap-deployment` repository at this point).
    2. Make a virtual environment and enter it (`python3 -m venv venv; . venv/bin/activate`).
    3. Install `evap` (`pip install evap[psycopg-binary]`). Note: Instead of using `evap` from PyPI, you can also install EvaP through a wheel by using `pip install evap-0.0.0-py-none-any.whl[psycopg-binary]`.
    4. Set up settings (see `productionsettings.template.py`) and set the `DJANGO_SETTINGS_MODULE` shell variable accordingly (for example `export DJANGO_SETTINGS_MODULE="productionsettings"`).
    6. Set up wsgi (see `wsgi.template.py`).
    7. Run `python3 -m evap collectstatic` and `python3 -m evap migrate`.
6. Make the directory of the EvaP installation accessible to Apache (for example by `chown -R evap:www-data /home/evap`).
7. Configure Apache:
    1. Set up two sites based on `apache/evap.conf` and `apache/maintenance.conf`.
    2. Run `a2enmod rewrite`, `a2enmod headers`, and `a2enmod wsgi`.
    3. Disable the default site and enable the `evap` site.
    4. Restart Apache.

EvaP should now be available according to your Apache configuration.

## Additional Notes

The repository also contains:
- `maintenance_mode.sh`: Enable or disable the maintenance mode.
- `update_production.sh`: Make a backup, update the installed `evap` package, and refresh caches etc.
- `load_production.sh`: Load a backup made by `update_production.sh`.
