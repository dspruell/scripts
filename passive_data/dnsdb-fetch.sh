#!/bin/sh
#
# Copyright (c) 2014 Darren Spruell <phatbuckett@gmail.com>
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
#
# Wrapper script for Farsight's dnsdb_query.py client. Fetches results and
# forks them into an output file in current working dir + standard output.
# You can then postprocess results using pdns-extract to get FQDNs and IPs
# from the output file.

DEFAULT_RRTYPE="A"

# Default sort to first seen date for record
#BASEOPTS="-s time_first"

# Parse argument to check if it is an IPv4 address or CIDR network
is_ipv4()
{
    IPV4='^([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}(/[0-9]{1,2})?$'
    echo "${1}" | grep -E -q "${IPV4}" || return 1

    IFS=.
    # shellcheck disable=SC2086
    set -- $1
    for octet in "$@"; do
        [ "${octet%/*}" -le 255 ] || return 1
    done
}

usage()
{
    cat <<-EOF
	USAGE: $(basename "$0") [-c COUNT] [-a DATESPEC] <ip|name>
	       $(basename "$0") [-c COUNT] [-a DATESPEC] -n name

	 -c: return COUNT results instead of default (usually 10,000)
	 -a: return results for resolutions logged after DATESPEC, in YYYY-MM-DD
	     format
	 -n: return results where 'name' matches NS records
	 -h: display this help output

	In the first syntax, call DNSDB API to return records where the RDATA
	matches the given IP input (<IPADDRESS|IPRANGE|IPNETWORK>).

	In the second syntax, call API to return records for all domains
	for which the NS records match the given name input.

EOF
}

OPTS="$BASEOPTS"

# Parse script arguments
while getopts "c:a:nh" optchar; do
    case $optchar in
        c)  OPTS="$OPTS --limit=${OPTARG}" ;;
        a)  OPTS="$OPTS --after=${OPTARG}" ;;
        n)  RRTYPE="NS"                    ;;
        h)  usage; exit 0                  ;;
        *)  usage; exit 1                  ;;
    esac
done
shift $((OPTIND - 1))

QDATA="$1"
RRTYPE="${RRTYPE:-$DEFAULT_RRTYPE}"

if is_ipv4 "$QDATA"; then
    OPTS="${OPTS} --rdataip=${QDATA}"
else
    if [ "$RRTYPE" = "NS" ]; then
        OPTS="${OPTS} --rdataname=${QDATA}/${RRTYPE}"
    else
        OPTS="${OPTS} --rrset=${QDATA}/${RRTYPE}"
    fi
fi

OUTNAME="pdns.$(printf "%s" "${QDATA}/${RRTYPE}" | sed -e 's!/!-!g' -e 's!\*!WILDCARD!').$(date '+%Y%m%d').txt"

dnsdb_query.py ${OPTS} | tee "$OUTNAME"

