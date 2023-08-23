#!/bin/sh
#
# 2023-08-22: Script to execute from cron to periodically ping out to the
# internet and log results for monitoring of WAN packet loss and latency (RTT).
# 
# Results are parsed into a single line format and logged to the system logger
# for downstream analytics.

set -e -u

PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# XXX In the future these should be supported as arguments
TGT_HOST="8.8.8.8"
CNT_REQUESTS=100
LOG_PROG="ping-check"
LOG_PRIO="notice"

PING_RES="$(ping -q -n -c "$CNT_REQUESTS" "$TGT_HOST")"
L_PKTS="$(echo "$PING_RES" | grep 'packet loss')"
L_RTT="$(echo "$PING_RES" | grep 'round-trip')"

echo "${L_PKTS}, ${L_RTT}" | logger -p "$LOG_PRIO" -t "$LOG_PROG"
