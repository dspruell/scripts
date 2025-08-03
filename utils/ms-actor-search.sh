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

# Search Microsoft MSTIC data for matching group name mappings.
#
# Requirements:
#
# - The Miller tool (https://github.com/johnkerl/miller) must be installed and
#   be available in PATH.
# - The path to the MSTIC threat group mapping JSON file is set in the
#   MSTIC_JSON_FILE environment variable.
#
# MSTIC repository: https://github.com/microsoft/mstic

set -e -u

DATA_FILE="$MSTIC_JSON_FILE"

TERM="$1"

mlr --ijson --otsv cat "$DATA_FILE" \
	| grep -E -i "$TERM" \
	| column -s "$(printf '\t')" -t
