#!/bin/sh
#
# Copyright (c) 2020-2021 Darren Spruell <dspruell@sancho2k.net>
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

# Report any outstanding binary patches as determined by syspatch(8).
# Output goes to to stdout; occurrences of outstanding patches also logged to
# syslog for log monitoring, etc.

set -e

export PATH=/bin:/usr/bin:/usr/sbin

CMD=$(basename $0)

set -A PATCHES $(syspatch -c)
num=${#PATCHES[*]}

if [ $num -gt 0 ]; then
	syschar="$(uname -rsm)"
	case $num in
		1)  suf="" ;;
		*)  suf="es" ;;
	esac
	msg="${syschar}: ${num} available patch${suf}: ${PATCHES[*]}"
	echo "${msg}"
	echo "${msg}" | logger -t "${CMD}"
else
	echo "None."
fi
