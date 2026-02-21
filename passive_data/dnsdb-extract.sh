#!/bin/sh

# Copyright (c) 2026 Darren Spruell <phatbuckett@gmail.com>
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

# Post-process PDNS data dump file to extract FQDN or IP lists.

usage()
{
    cat <<-EOF
	USAGE: $(basename "$0") -a FILE
	       $(basename "$0") FILE <fqdn|ip>

	 -a: extract unique FQDN and IP values from pDNS data in FILE
	 -h: display this help output

	In the first syntax, script extracts unique FQDN and IP values from the
	input file and writes them to output files, by default the name of FILE
	appended with -fqdns.txt and -ips.txt respectively.

	In the second syntax, each instance in the file of FQDN or IP value as
	specified is printed to standard output.
EOF
}

auto_extract()
{
    IP_OUT="${FNAME}-ips.txt"
    FQDN_OUT="${FNAME}-fqdns.txt"
    $0 "${FNAME}" ip | sort -n -t. -k1,1 -k2,2 -k3,3 -k4,4 -u > "$IP_OUT"
    $0 "${FNAME}" fqdn | sort -u > "$FQDN_OUT"
    printf "[*] %4d %s\n" "$(wc -l < "$IP_OUT")" "$IP_OUT"
    printf "[*] %4d %s\n" "$(wc -l < "$FQDN_OUT")" "$FQDN_OUT"
}

# Parse script arguments
while getopts "ah" optchar; do
    case $optchar in
        a)  AUTO=1 ;;
        h)  usage; exit 0         ;;
        *)  usage; exit 1         ;;
    esac
done
shift $((OPTIND - 1))

[ -e "$1" ] || exit 1

FNAME="$1"

if [ -n "$AUTO" ]; then
    auto_extract "$FNAME"
    exit
fi

# shellcheck disable=SC2034
grep 'IN A' "$FNAME" | while read -r FQDN F2 F3 IP; do
    case "$2" in
      fqdn) echo "${FQDN%*.}" ;;
        ip) echo "$IP"        ;;
         *) usage && exit 1 ;;
    esac
done
