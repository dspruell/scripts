#!/bin/sh
#
# Update the shebang in target Python tooling to a consistent
# `/usr/bin/env python3` interpreter. This targets files with any file
# extension (including none), and focuses on those using the unversioned
# `python` interpreter. Modified files are edited in place and a `.bak` backup
# file is created.
#
# Copyright (c) 2023 Darren Spruell <phatbuckett@gmail.com>
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

PATH="/usr/bin:/bin"

TARGETS="$(find . -type f)"

for f in $TARGETS
do
	echo "[-] Evaluating ${f}..."
	sed -E -i".bak" -e '1s@#!(/usr)?/bin/python\r?$@#!/usr/bin/env python3@' "$f"
	sed -E -i".bak" -e '1s@#!(/usr)?/bin/env python\r?$@#!/usr/bin/env python3@' "$f"
	chmod +x "$f"
done
