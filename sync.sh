#!/bin/bash

set -e

# Some defaults to be overridden by environment variables
export TMP_ROOT=${TMP_ROOT:=$HOME/tmp}
export LOG_KEEP_DAYS=${LOG_KEEP_DAYS:=3}

# Strict umask
umask 077

# Is config readable?
if ! [ -r "$1" ]
then
    echo "Cannot read configuration file: $1"
    exit 1
fi

# Load config
. "$1"

# Check config for source
if [ -z "${from_server}" -o -z "${from_username}" -o -z "${from_secret_file}" ]
then
    echo "Configuration is missing one or more values for from_server, from_username or from_secret_file"
    exit 1
fi

# Check secret file for source
if ! [ -r "${from_secret_file}" ]
then
    echo "Cannot read from_secret_file: ${from_secret_file}"
    exit 1
fi

# Check config for destination
if [ -z "${to_server}" -o -z "${to_username}" -o -z "${to_secret_file}" ]
then
    echo "Configuration is missing one or more values for from_server, from_username or from_secret_file"
    exit 1
fi

# Check secret file for destination
if ! [ -r "${to_secret_file}" ]
then
    echo "Cannot read from_secret_file: ${to_secret_file}"
    exit 1
fi

# Create unique job id
export JOB_ID="`echo -n "${from_server}:${from_username}:${to_server}:${to_username}" | sha512sum | cut -c1-16`"

# Derive folders from job id
export TMP_DIR="${TMP_ROOT}/${JOB_ID}/sync"
export PID_FILE="${TMP_ROOT}/${JOB_ID}/imapsync.pid"

# Create tmp root, if missing
if ! [ -d "${TMP_ROOT}" ]
then
    mkdir -p "${TMP_ROOT}"
fi

# Create tmp dir, if missing
if ! [ -d "${TMP_DIR}" ]
then
    mkdir -p "${TMP_DIR}"
fi

# Run imapsync
# --debugssl 0 --nolog --pidfile "${TMP_DIR}/imapsync.pid" --pidfilelocking --no-modulesversion
exec imapsync --tmpdir "${TMP_DIR}" ${imapsync_opts} \
       --host1 "${from_server}" --user1 "${from_username}" --passfile1 "${from_secret_file}" ${from_opts} \
       --host2 "${to_server}"   --user2 "${to_username}"   --passfile2 "${to_secret_file}"   ${to_opts}
