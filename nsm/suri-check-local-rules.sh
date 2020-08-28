#!/bin/sh
#
# Author: Darren Spruell <phatbuckett@gmail.com>
#
# Run command to verify the syntax of the local rules file and display the log
# for verification. Should be executed with superuser privs.
#
# The default is to validate local.rules in the Suricata rules directory.
# An alternate rules file may be provided as a parameter to the script.

set -e

PATH=/usr/local/bin:/usr/bin:/bin

RULES_FILE=${SURICATA_LOCAL_RULES:-/etc/suricata/rules/local.rules}
LOG_FILE=${SURICATA_LOG_MAIN:-/var/log/suricata/suricata.log}

if [ $(id -u) -ne 0 ]; then
    echo '[!] Script must be executed as the superuser.' >&2
    exit 1
fi

if [ -n "$1" ]; then
    if [ -r "$1" ]; then
        RULES_FILE="$1"
    else
        echo '[!] Unable to read specified file ('"$1"')' >&2
        exit 1
    fi
fi

sh -c 'suricata -T -c /etc/suricata/suricata.yaml \
    -S '"$RULES_FILE"' & tail -n1 -f '"${LOG_FILE}"

