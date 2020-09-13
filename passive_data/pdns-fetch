#!/bin/sh
#
# PassiveTotal PDNS API wrapper client. Queries dns endpoint, improves ISO 8601
# timestamps, and forks output to stdout and a file on disk.

set -e

DATESTR="$(date +%Y-%m-%d)"
OPTS=""


show_usage()
{
	cat <<-EOF
	Fetch PDNS records and cache to disk.

	USAGE: $(basename "$0") [options] term [...]
	  -j: request JSON data
	  -h: show help
EOF
}


items2str()
{
	# Use a tag for the filename that removes spaces and limits longer
	# argument lists to maximum number of characters.
	printf "%s" "$*" | tr ' ' '-' | cut -c1-40
}


# Parse script arguments
while getopts "jh" optchar; do
	case $optchar in
	  j)  OPTS="${OPTS} -j"
	      FEXT="json"
	      ;;
	  h)  show_usage; exit 0  ;;
	  *)  show_usage; exit 1  ;;
	esac
done
shift $((OPTIND - 1))

ITEMS="$@"

passivetotal dns $OPTS $ITEMS \
	| sed -Ee 's!([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2})!\1T\2!g' \
	| tee "pdns.$(items2str ${ITEMS}).${DATESTR}.${FEXT:-txt}"
