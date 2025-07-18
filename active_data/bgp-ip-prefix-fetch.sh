#!/bin/sh

# Use the bgpq4 tool to retrieve prefix data for a given ASN.

set -e

progname="$(basename "$0")"
OPTS=""

usage()
{
    cat <<-EOF
	USAGE: $progname [options]
	  -a: trust all sources output by the queried data source
	  -h: display this help output
EOF
}

# Parse script arguments
while getopts "ah" optchar
do
    case $optchar in
        a)  TRUST_ALL=1    ;;
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

if [ -z "$TRUST_ALL" ]
then
	OPTS="$OPTS -S RPKI,AFRINIC,APNIC,ARIN,LACNIC,RIPE"
fi

bgpq4 -F "%n/%l\n" "$AS"
