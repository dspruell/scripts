#!/bin/sh

# Wrapper script to use the bgpq4 tool to retrieve prefix data for a given ASN.

set -e

progname="$(basename "$0")"
OPTS=""

usage()
{
    cat <<-EOF
	USAGE: $progname [options] <AS>
	  -6: retrieve IPv6 prefixes
	  -a: trust all sources output by the queried data source
	  -b: prefix output lines with hyphens (bulleted list)
	  -h: display this help output

	An AS parameter must be specified (e.g., AS15169)
EOF
}

# Parse script arguments
while getopts "6abh" optchar
do
    case $optchar in
        6)  FETCH_IPV6=1   ;;
        a)  TRUST_ALL=1    ;;
        b)  BULLETS=1      ;;
        h)  usage; exit 0  ;;
        *)  usage; exit 1  ;;
    esac
done
shift $((OPTIND - 1))

AS="$1"

if ! echo "$AS" | grep -qE '^AS[0-9]+$'
then
	echo '[!] Autonomous System (AS) must be provided in AS#### form' >&2
	echo
	usage; exit 1
fi

[ -n "$TRUST_ALL" ] || OPTS="$OPTS -S RPKI,AFRINIC,APNIC,ARIN,LACNIC,RIPE"
[ -n "$FETCH_IPV6" ] && OPTS="$OPTS -6"

# shellcheck disable=SC2086
bgpq4 -F "${BULLETS:+- }%n/%l\n" ${OPTS} "$AS"
