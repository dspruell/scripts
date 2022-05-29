#!/bin/sh
#
# Enumerate subdomains with RiskIQ Community (PassiveTotal) and fork to stdout
# and file on disk.
#
# This wrapper script uses the passivetotal2 client
# (https://pypi.org/project/passivetotal2/)

set -e

DOMAIN="$1"
FNAME="pdns-subs.${DOMAIN}.$(date +%Y%m%d).txt"

for s in $(passivetotal enrich -j -s "$DOMAIN" | jq -r '.subdomains[]'); do
        echo "${s}.${DOMAIN}"
done | tee "$FNAME"
