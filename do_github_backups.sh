#!/bin/sh

cd /path-to/scripts/

source /path-to-datatracker-install/env/bin/activate

/path-to-datatracker-install/ietf/manage.py find_github_backup_info > /path-to/scripts/get_these_things

TODAY=`date +%Y%m%d`

/path-to/scripts/setup_and_run_ghback.sh `cat get_these_things` > /path-to/logs/ghback-${TODAY}.log 2>&1
