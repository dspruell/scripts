#!/bin/sh
#
# Dump sqlite database to disk
#
# Copyright (c) 2016 Darren Spruell <phatbuckett@gmail.com>
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

set -e

PATH=:/bin:/usr/bin:/usr/local/bin

if [ -z "$1" ]; then
    echo "USAGE: $(basename "$0") <database file>" >&2
    exit 1
fi

DB="$1"
TSTAMP=$(date "+%Y-%m-%d")
OUTFILE="sqlite.${TSTAMP}.sql"

sqlite3 "$DB" <<EOF > "$OUTFILE"
.dump
.exit
EOF

printf "Dump file: %s (%s bytes)\n" "$OUTFILE" "$(stat -f '%z' "$OUTFILE")"
