#!/bin/sh

# This is designed to contain secrets and deployment specific setup.
# Similar to settings_local in django environments

source env/bin/activate

export GITHUB_BACKUP_API_KEY="<api key goes here>"
export BACKUP_DIR="/path-to/backups"
# Currently taken from https://raw.githubusercontent.com/martinthomson/i-d-template/main/archive_repo.py
export ARCHIVE_EXTRAS_SCRIPT="/path-to/archive_repo.py"

for REPO in $@; do
  /path-to/scripts/ghback.sh ${REPO} 
done
