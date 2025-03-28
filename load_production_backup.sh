#!/usr/bin/env bash

# Counter part for update_production script.
# This script will import the backup made by update_production.

set -e # abort on error
ROOT="$(dirname "$0")"

CONDITIONAL_NOINPUT=""
[[ ! -z "$GITHUB_WORKFLOW" ]] && echo "Detected GitHub" && CONDITIONAL_NOINPUT="--noinput"

EVAP_VERSION=$(pip show evap | sed -nE 's/(Version: )(.*)/\2/p')

# argument 1 is the filename for the backupfile.
if [ ! $# -eq 1 ] # if there is exactly one argument
    then
        echo "Please specify a backup file to import as command line argument."
        exit
fi

# Check if commit hash is in file name. Ask for confirmation if its not there.
if [[ $1 != *"${EVAP_VERSION}"* ]]
then
    echo "Looks like the backup was made on another version. Currently, you are on ${EVAP_VERSION}."
    read -p "Do you want to continue [y]? " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
fi

echo "WARNING! This will cause IRREPARABLE DATA LOSS."
read -p "Are you sure you want to continue [y]? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

[[ -z "$EVAP_SKIP_APACHE_STEPS" ]] && sudo service apache2 stop

python -m evap collectstatic --noinput

# Note: No quotes around $CONDITIONAL_NOINPUT, because we don't want to pass "" in case it is not set
python -m evap reset_db $CONDITIONAL_NOINPUT
python -m evap migrate
python -m evap flush $CONDITIONAL_NOINPUT
python -m evap loaddata_unlogged --verbosity=2 "$1"

python -m evap clear_cache --all -v=1
python -m evap refresh_results_cache

[[ -z "$EVAP_SKIP_APACHE_STEPS" ]] && sudo service apache2 start

{ set +x; } 2>/dev/null # don't print the echo command, and don't print the 'set +x' itself

echo "Backup restored."
