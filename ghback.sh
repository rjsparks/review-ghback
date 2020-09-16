#!/bin/sh

# expects the extras script path to come from the environment
if [ -z "${ARCHIVE_EXTRAS_SCRIPT}" ]; then
    echo "ARCHIVE_EXTRAS_SCRIPT not found in environment"
    exit -1
fi

# expects the api key to come in from the environment
if [ -z "${GITHUB_BACKUP_API_KEY}" ]; then
    echo "GITHUB_BACKUP_API_KEY not found in environment"
    exit -1
fi

# expects the backup location to come in from the environment
if [ -z "${BACKUP_DIR}" ]; then
    echo "BACKUP_DIR not found in environment"
    exit -1
fi

if [ ! -d "${BACKUP_DIR}" ]; then
    echo "BACKUP_DIR ${BACKUP_DIR} does not exist"
    exit -1
fi

# given a repository name

if [ -z "$1" ]; then
    echo "Usage: $0 repo_name"
    exit -1
fi
REPO=$1
GH_REPO_URL="https://github.com/${REPO}"
LOCAL_REPO_NAME="`echo ${REPO} | sed -e 's,/,__,'g`"

RAW_GIT_CLONE="${BACKUP_DIR}/${LOCAL_REPO_NAME}.git"

if [ ! -e "${RAW_GIT_CLONE}" ] ; then
    # Nothing at all exists at the clone target, make an initial clone
    if ! git clone --mirror ${GH_REPO_URL} ${RAW_GIT_CLONE} ; then
        echo "ERROR: clone failed : ${GH_REPO_URL}"
        exit -1
    fi
elif [ -d "${RAW_GIT_CLONE}" ]; then
    # Existing directory at the clone target, fetch any changes
    git --git-dir=${RAW_GIT_CLONE} fetch
else
    echo "ERROR: Unknown non-directory at RAW_GIT_CLONE [${RAW_GIT_CLONE}]"
    exit -1
fi

# Look in the clone to see if it has the archive built in
if ! git --git-dir=${RAW_GIT_CLONE} describe gh-pages:archive.json; then
    # If the archive is not in the clone run the script
    TODAY=`date +%Y%m%d`
#    YESTERDAY=`date -v -1d +%Y%m%d`
#    STALE_DATE=`date -v -${KEEP_ARCHIVE_DAYS:-7}d +%Y%m%d`
# ietfa has a very sad implementation of date
    YESTERDAY=`python -c "import datetime; print((datetime.datetime.today()-datetime.timedelta(days=1)).strftime('%Y%m%d'))"`
    STALE_DATE=`python -c "import datetime; print((datetime.datetime.today()-datetime.timedelta(days=${KEEP_ARCHIVE_DAYS:-7})).strftime('%Y%m%d'))"`
    ${ARCHIVE_EXTRAS_SCRIPT} ${REPO} ${GITHUB_BACKUP_API_KEY} ${BACKUP_DIR}/${LOCAL_REPO_NAME}-${TODAY}.json --reference ${BACKUP_DIR}/${LOCAL_REPO_NAME}-${YESTERDAY}.json --quiet
    if [ -f "${BACKUP_DIR}/${LOCAL_REPO_NAME}-${STALE_DATE}.json" ]; then
        rm "${BACKUP_DIR}/${LOCAL_REPO_NAME}-${STALE_DATE}.json"
    fi
fi


