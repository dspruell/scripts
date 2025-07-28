#!/bin/sh

# Copyright (c) 2025 Darren Spruell <phatbuckett@gmail.com>
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

# Download Recorded Future Risk List feeds. Currently uses an API TOKEN
# given in the environment variable RF_API_TOKEN.
#
# These are large data files and are only updated as often as hourly, every
# other hour, or daily; be careful about pulling them too often.

set -e -u

PATH="/usr/local/bin:/usr/bin:/bin"

RISK_LISTS="ip domain hash url vulnerability"
RF_TOKEN="$RF_API_TOKEN"

for rl in $RISK_LISTS
do
	OUTFILE="risklist-large-${rl}-$(date +%Y%m%d).csv"
	echo "Fetching Risk List Large - ${rl}..."
	curl \
		--no-progress-meter \
		-G \
		-H "x-rftoken: ${RF_TOKEN}" \
		-o "$OUTFILE" \
		"https://api.recordedfuture.com/v2/${rl}/risklist?format=csv%2Fsplunk&list=large"
done
