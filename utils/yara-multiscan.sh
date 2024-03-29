#!/bin/sh

# Copyright (c) 2023-2024 Darren Spruell <phatbuckett@gmail.com>
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


# Call any installed YARA versions rooted under a given directory in
# sequence, enabling to test operations with multiple versions. The prefix
# may be passed in using the YARA_ENGINES_ROOT environment variable, and
# defaults to /opt/yara.

set -u

YARA_ENGINES_ROOT=${YARA_ENGINES_ROOT:-/opt/yara/}

for ye in "${YARA_ENGINES_ROOT}"/*; do
	[ -d "$ye" ] || continue
	[ X"$ye" = X"$YARA_ENGINES_ROOT/cache" ] && continue
	if [ ! -x "${ye}/bin/yara" ]; then
		echo "[ERROR] ${ye} does not appear to be the prefix for a YARA installation (no bin/yara found)." >&2
		continue
	fi
	VER="${ye##*/yara-}"
	printf "***** %-30s *****\n" "YARA v${VER} begin..."
	"${ye}/bin/yara" "$@"
	printf "***** %-30s *****\n" "YARA v${VER} exit status: $?"
	echo
done
