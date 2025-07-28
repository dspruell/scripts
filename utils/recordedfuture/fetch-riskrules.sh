#!/bin/sh

# Copyright (c) 2025 Darren Spruell <phatbuckett@gmail.com>
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Download Recorded Future Risk Rules lists. Currently uses an API TOKEN
# given in the environment variable RF_API_TOKEN.

set -e -u

RISK_LISTS="ip domain hash url vulnerability"
RF_TOKEN="$RF_API_TOKEN"
CUR_DATE="$(date +%Y%m%d)"
EXTRACT=""

progname="$(basename "$0")"

usage()
{
    cat <<-EOF
	USAGE: $progname [options]
	  -e: extract Risk Rules data in human readable format
	  -h: display this help output
EOF
}

# Parse script arguments
while getopts "eh" optchar; do
    case $optchar in
        e)  EXTRACT=1      ;;
        h)  usage; exit 0  ;;
        *)  usage; exit 1  ;;
    esac
done
shift $((OPTIND - 1))

for rl in $RISK_LISTS
do
	OUTFILE="riskrules-${rl}-${CUR_DATE}.json"
	echo "Fetching Risk Rules for ${rl}..."
	curl \
		--no-progress-meter \
		-G \
		-H "x-rftoken: ${RF_TOKEN}" \
		-o "$OUTFILE" \
		"https://api.recordedfuture.com/v2/${rl}/riskrules"
done

if [ -n "$EXTRACT" ]
then
	for rl in $RISK_LISTS
	do
		OUTFILE="riskrules-${rl}-${CUR_DATE}-extracted.txt"
		echo "Extracting ${rl} Risk Rules..."
		./process-riskrules.sh \
			"riskrules-${rl}-${CUR_DATE}.json" \
			> "$OUTFILE"
	done
fi
