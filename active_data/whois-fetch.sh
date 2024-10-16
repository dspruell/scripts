#!/usr/bin/env bash
#
# Copyright (c) 2021-2024 Darren Spruell <dspruell@sancho2k.net>
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

# Wrapper around whois(1) to perform lookup and fork output to a
# named/timestamped file on disk as well as to stdout.

set -e

usage()
{
	cat <<-EOF
	USAGE: $(basename "$0") [options] OBJECT

	Options:
	  -s <SOURCE>:
	      Query the specified RIR WHOIS server (choices: afrinic, apnic, arin,
	      lacnic, ripe)
	  -h:
	      Display this help output

	Perform WHOIS lookup of an object (an IP address, IP CIDR, ASN, other RIR
	object) and print to stdout as well as store the result in a file in the
	current working directory.

	Some objects (for example organization names, contact handles, etc.)
	require specifying a target WHOIS server for the regional internet
	registry (RIR) that houses the object. In these cases, pass the RIR name in
	lower case an argument with the -s option to query the specified RIR
	WHOIS server.

EOF
}

get_whois_server()
{
	RIR="$1"
	case "$RIR" in
	  afrinic)  WHOIS_SERVER="whois.afrinic.net" ;;
	  apnic)    WHOIS_SERVER="whois.apnic.net"   ;;
	  arin)     WHOIS_SERVER="whois.arin.net"    ;;
	  lacnic)   WHOIS_SERVER="whois.lacnic.net"  ;;
	  ripe)     WHOIS_SERVER="whois.ripe.net"    ;;
	  *)        return 1                         ;;
	esac
	echo "$WHOIS_SERVER"
}

# Parse script arguments
while getopts "s:h" optchar; do
    case $optchar in
        s)  WHOIS_SOURCE="$OPTARG"   ;;
        h)  usage; exit 0    ;;
        *)  usage; exit 1    ;;
    esac
done
shift $((OPTIND - 1))

arg="$1"
argout="$(echo -n "$arg" | tr '/' '-')"

if [[ -n "$WHOIS_SOURCE" ]]; then
	WHOIS_CMD="whois -h $(get_whois_server "$WHOIS_SOURCE")"
else
	WHOIS_CMD="whois"
fi

OUTFILE="whois.${argout}.$(date "+%Y%m%d").txt"
$WHOIS_CMD "$arg" | tee "$OUTFILE"
