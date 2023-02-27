#!/bin/sh
#
# Launch mitmdump for web traffic capture. Script assumes that mitmdump is
# installed and callable from search path.
#
# Copyright (c) 2017 Darren Spruell <phatbuckett@gmail.com>
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

MITMDUMP_EXTRA_OPTS="-z"
PORT="8080"
FILTER=''

if [ -n "$1" ]; then
    OUTPUT_FILE="${1}.out"
    trap 'printf "\nDONE: Output file: %s\n\n" "$OUTPUT_FILE"' INT
else
    echo "Usage: $(basename "$0") <session_name>" >&2
    exit 1
fi

echo "[*] launching mitmdump... Go!"
mitmdump "$MITMDUMP_EXTRA_OPTS" -w "$OUTPUT_FILE" -p "$PORT" "$FILTER"
