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

# Add file to a new encrypted ZIP archive named based on the file's SHA256
# hash. Use the de facto standard key for suspicious files.

set -e -u

INFILE="$1"
ENC_KEY="infected"

get_hash_prefix()
{
	_file="$1"
	openssl sha256 "${_file}" | awk '{print $NF}' | cut -c 1-9
}

zip -P${ENC_KEY} "$(get_hash_prefix "${INFILE}").zip" "${INFILE}"
