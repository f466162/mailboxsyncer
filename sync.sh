#!/bin/bash

set -e

# Some defaults to be overridden by environment variables
export TMP_ROOT=${TMP_ROOT:=$HOME/tmp}
export LOG_KEEP_DAYS=${LOG_KEEP_DAYS:=3}

# Strict umask
umask 177

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
export JOB_ID="`echo -n "${from_server}:${from_user}:${to_server}:${to_user}" | sha512sum`"

# Derive folders from job id
export TMP_DIR="${TMP_ROOT}/${JOB_ID}/sync"
export LOG_DIR="${TMP_ROOT}/${JOB_ID}/logs"

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

# Create log dir, if missing
if ! [ -d "${LOG_DIR}" ]
then
    mkdir -p "${LOG_DIR}"
fi

# Delete old logs
find "${LOG_DIR}" -mtime +"${LOG_KEEP_DAYS}" -print0 | xargs -0r rm -rf 

# Run imapsync
exec imapsync --tmpdir "${TMP_DIR}"  --logdir "${LOG_DIR}" \
       --host1 "${from_server}" --user1 "${from_user}" --passfile1 "${from_secret_file}" ${from_opts} \
       --host2 "${to_server}"   --user2 "${to_user}"   --passfile2 "${to_secret_file}"   ${to_opts}
