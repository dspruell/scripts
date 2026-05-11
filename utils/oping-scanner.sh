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

# Scan one or more input CIDR block lists using oping(1).
#
# oping does not support CIDR blocks, so preprocess the input files to a new
# input list of IP addresses using prips first.
#
# Supports basic rate limiting for processing delays between input files and
# clear progress and timing reporting.
#
# Requirements:
# - noping (oping)
# - prips

usage() {
	cat <<-EOF
	Usage: $(basename "$0") [-h] [-p SECONDS] [FILE [FILE ...]]

	Scan one or more CIDR input files using oping(1). Reads from stdin if no
	FILE arguments are given, or when FILE is '-'.

	Options:
	  -h           Print this help message and exit.
	  -p SECONDS   Pause SECONDS seconds between input files (positive integer).
	EOF
}

set -e

DS="$(date +%Y%m%d)"

# Returns current time as "seconds.milliseconds" using GNU date's %3N format
# specifier. Falls back to integer seconds on BSD/macOS where %3N produces
# non-numeric output.
_now() {
	t=$(date '+%s.%3N' 2>/dev/null)
	case "$t" in
		*[!0-9.]*) date +%s ;;
		*.???)     echo "$t" ;;
		*)         date +%s ;;
	esac
}

# Formats elapsed time between two _now timestamps as "Xm YY.ZZs" or
# "X.ZZs". Uses awk for portable floating-point arithmetic.
_fmt_elapsed() {
	awk -v s="$1" -v e="$2" 'BEGIN {
		cs = int((e - s) * 100 + 0.5)
		secs = int(cs / 100)
		frac = cs % 100
		if (secs >= 60) {
			printf "%dm%02d.%02ds\n", int(secs / 60), secs % 60, frac
		} else {
			printf "%d.%02ds\n", secs, frac
		}
	}'
}

_log()
{
	TS="$(date +"%Y-%m-%dT%H:%M:%S.%N")"
	MSG="$1"
	echo "[*] $TS [INFO] $MSG" >&2
}

PAUSE=""

while getopts ':hp:' OPT
do
	case "$OPT" in
		h)
			usage
			exit 0
			;;
		p)
			PAUSE="$OPTARG"
			case "$PAUSE" in
				''|*[!0-9]*|0)
					echo "error: -p requires a positive integer argument" >&2
					usage >&2
					exit 1
					;;
			esac
			;;
		:)
			echo "error: option -${OPTARG} requires an argument" >&2
			usage >&2
			exit 1
			;;
		?)
			echo "error: unrecognized option: -${OPTARG}" >&2
			usage >&2
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

[ "$#" -eq 0 ] && set -- "-"

PROG_START="$(_now)"

_FILE_NUM=0

for IN_FILE in "$@"
do
	_FILE_NUM=$((_FILE_NUM + 1))
	if [ -n "$PAUSE" ] && [ "$_FILE_NUM" -gt 1 ]
	then
		_log "pausing ${PAUSE}s before next file..."
		sleep "$PAUSE"
	fi

	FILE_START="$(_now)"

	if [ "$IN_FILE" = "-" ]
	then
		IN_FILE_BASE="stdin"
		IN_STREAM="/dev/stdin"
	else
		IN_FILE_BASE="$IN_FILE"
		IN_STREAM="$IN_FILE"
	fi

	IPS_FILE="${IN_FILE_BASE}-ips"
	OUT_FILE="${IN_FILE_BASE}-out-${DS}"

	_log "processing ${IN_FILE_BASE} to ${IPS_FILE}..."
	cp /dev/null "$IPS_FILE"
	while read -r CIDR
	do
		_log "extracting IP addresses for ${CIDR}..."
		prips "$CIDR" >> "$IPS_FILE"
		_log "finished extracting IP addresses for ${CIDR}..."
	done < "$IN_STREAM"

	CNT_IN_IPS="$(wc -l < "$IPS_FILE")"
	_log "starting scan for ${CNT_IN_IPS} IP addresses in ${IPS_FILE}..."
	oping -c 1 -i 0.5 -O "${OUT_FILE}" -f - < "$IPS_FILE" >/dev/null
	_log "completed scan for ${IPS_FILE}"

	RESP_FILE="${OUT_FILE}-responders"

	# Filter scan results to contain only responding hosts
	grep -E -v -e '^#' -e ',-1.00$' "$OUT_FILE" > "$RESP_FILE"

	# Extract unique IP addresses from scan results
	RESP_IP_FILE="${RESP_FILE}-ips"
	cut -d, -f 2 "$RESP_FILE" | tr -d '"' | sort -uV > "$RESP_IP_FILE"
	CNT_RESP_IPS="$(wc -l < "$RESP_IP_FILE")"
	PCT_RESP_IPS="$(awk -v i="$CNT_RESP_IPS" -v t="$CNT_IN_IPS" 'BEGIN {printf "%.2f", (i/t)*100}')"
	FILE_ELAPSED="$(_fmt_elapsed "$FILE_START" "$(_now)")"
	_log "finished: identified ${CNT_RESP_IPS} (${PCT_RESP_IPS}%) responding hosts from ${IN_FILE_BASE} (output: ${RESP_IP_FILE}) [${FILE_ELAPSED}]"
done

PROG_ELAPSED="$(_fmt_elapsed "$PROG_START" "$(_now)")"
_log "all files processed; total elapsed time: ${PROG_ELAPSED}"
