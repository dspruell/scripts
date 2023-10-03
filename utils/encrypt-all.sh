#!/bin/sh
#
# Encrypt all input files to the default key using GnuPG.
#
# Copyright (c) 2022-2023 Darren Spruell <phatbuckett@gmail.com>
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

set -e -u

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# Process each input parameter as a file by encrypting with GnuPG if it does
# not have a GPG file extension.
for f in "$@"
do
	if ! expr "${f}" : '.*\.\(asc\|gpg\)$' > /dev/null
	then
		OUTFILE="${f}.gpg"
		gpg -o "${OUTFILE}" -e "${f}"
	fi
done
