#!/bin/bash

set -e

LOCK="sync.lock"

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

# Run imapsync
exec flock -w 600 -x ${LOCK} imapsync ${imapsync_opts} \
       --host1 "${from_server}" --user1 "${from_username}" --passfile1 "${from_secret_file}" ${from_opts} \
       --host2 "${to_server}"   --user2 "${to_username}"   --passfile2 "${to_secret_file}"   ${to_opts}
