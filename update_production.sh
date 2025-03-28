#!/usr/bin/env bash

set -e # abort on error
ROOT="$(dirname "$0")"

echo "$PWD"

# used for constructing the backup file name
EVAP_VERSION=$(pip show evap | sed -nE 's/(Version: )(.*)/\2/p')
BACKUP_TITLE="backup"
TIMESTAMP="$(date +%Y-%m-%d_%H:%M:%S)"
EVAP_DEFAULT_PACKAGES="evap[psycopg-binary]"
EVAP_PACKAGES=${EVAP_PACKAGES:-$EVAP_DEFAULT_PACKAGES}

# argument 1 is the title for the backupfile.
if [ $# -eq 1 ]
    then
        BACKUP_TITLE=$1
fi

FILENAME="${BACKUP_TITLE}_${TIMESTAMP}_${EVAP_VERSION}.json"

[[ -z "$EVAP_OVERRIDE_BACKUP_FILENAME" ]] || echo "Overriding Automatic Filename"
[[ -z "$EVAP_OVERRIDE_BACKUP_FILENAME" ]] || FILENAME="${BACKUP_TITLE}"

echo "Backup will be stored in $FILENAME"
echo "Starting update..."

set -x # print executed commands. enable this here to not print the if above.

# Note that apache should not be running during most of the upgrade,
# since then e.g. the backup might be incomplete or the code does not
# match the database layout, or https://github.com/e-valuation/EvaP/issues/1237.
[[ -z "$EVAP_SKIP_APACHE_STEPS" ]] && sudo $ROOT/maintenance_mode.sh enable

python -m evap dumpdata --natural-foreign --natural-primary --all -e contenttypes -e auth.Permission --indent 2 --output "$FILENAME"

[[ ! -z "$EVAP_SKIP_UPDATE" ]] && echo "Skipping Update"
[[ ! -z "$EVAP_SKIP_UPDATE" ]] || pip install $EVAP_PACKAGES

python -m evap collectstatic --noinput

python -m evap migrate

python -m evap clear_cache --all -v=1
python -m evap refresh_results_cache

[[ -z "$EVAP_SKIP_APACHE_STEPS" ]] && sudo $ROOT/maintenance_mode.sh disable

{ set +x; } 2>/dev/null # don't print the echo command, and don't print the 'set +x' itself

echo "Update completed."
