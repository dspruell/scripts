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

# Enumerate subdomains with RiskIQ Community (PassiveTotal) and fork to stdout
# and file on disk.
#
# This wrapper script uses the passivetotal2 client
# (https://pypi.org/project/passivetotal2/)

set -e

DOMAIN="$1"
FNAME="pdns-subs.${DOMAIN}.$(date +%Y%m%d).txt"

for s in $(passivetotal enrich -j -s "$DOMAIN" | jq -r '.subdomains[]'); do
        echo "${s}.${DOMAIN}"
done | tee "$FNAME"
