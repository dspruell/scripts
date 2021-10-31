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

# Perform a remote update of the Spamhaus drop list from a local source.
# 
# DROP list: http://www.spamhaus.org/drop/drop.lasso

set -eu

PATH="/usr/bin:/sbin"

DROPURL=http://www.example.com/drop/drop.list
OUTFILE=/var/tmp/drop.list

(ftp -o "${OUTFILE}" "${DROPURL} >/dev/null && \
    pfctl -q -t droplist -T replace -f "${OUTFILE}")

if [ $? -eq 0 ]; then
    echo "Updated DROP list successfully (source: ${DROPURL})"
else
    echo "ERROR: Failure updating DROP list (source: ${DROPURL})"
fi | logger -t pf -p local0.info
