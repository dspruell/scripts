#!/bin/sh
#
# Copyright (c) 2007-2021 Darren Spruell <dspruell@sancho2k.net>
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

# Parse the Spamhaus DROP list (http://www.spamhaus.org/drop/) out to a
# list of CIDR blocks for loading into PF.
# 
# DROP list: http://www.spamhaus.org/drop/drop.lasso

PATH=/usr/bin:/bin:/sbin

# Download URL of DROP list
DROPURL="http://www.spamhaus.org/drop/drop.lasso"
# PF table to load DROP list into
DROPTABLE="droplist"
SNAME="$(basename "$0")"
DROPTMP="$(mktemp -t "${SNAME}".XXXXXXXX)" || exit 1

# Sort IP addresses
sort_ip()
{
    sort -n -t. -k1,1n -k2,2n -k3,3n -k4,4n
}

# Display usage details
usage()
{
    echo "USAGE: ${SNAME} -o <file> [-h]"
    echo "       -o: DROP list output file"
    echo "       -h: display this help output"
}

if [ $# -ne 2 ]; then
    usage
    exit 1
fi

# Parse script arguments
while getopts "o:h" optchar; do
    case $optchar in
        o)  OUTFILE="${OPTARG}" ;;
        h)  usage && exit 0;;
        *)  usage && exit 1;;
    esac
done
shift $((OPTIND - 1))

# Fetch DROP

ftp -V -o "${DROPTMP}" "${DROPURL}"

if [ -s "${DROPTMP}" ]; then
    # Add timestamp to file
    echo "# Last update: $(date -u)" > "${OUTFILE}"
    # Extract CIDR blocks from file
    awk '/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/{print $1}' \
        < "${DROPTMP}" | sort_ip >> "${OUTFILE}"
fi

# Reload PF table
pfctl -q -t "${DROPTABLE}" -T replace -f "${OUTFILE}"

# clean up
rm -f "${DROPTMP}"
