#!/bin/sh
#
# Toggle IP forwarding Linux kernel knob to forward or limit forwarding
# of traffic across network interfaces.
#
# Copyright (c) 2022 Darren Spruell <phatbuckett@gmail.com>
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

KNOB="net.ipv4.ip_forward"
VAL_OFF=0
VAL_ON=1

check_forwarding_enabled()
{
	val="$(/sbin/sysctl --value ${KNOB})"
	case "$val" in
	  0)  _stat=1 ;;
	  1)  _stat=0 ;;
	  *)  echo "Unrecognized sysctl value: $val" >&2; exit 1 ;;
	esac

	return "$_stat"
}

toggle_forwarding()
{
	if check_forwarding_enabled; then
		/sbin/sysctl "${KNOB}"="$VAL_OFF"
	else
		/sbin/sysctl "${KNOB}"="$VAL_ON"
	fi
}

if [ $# -ge 1 ]; then
	case "$1" in
	  "-c")  
              if check_forwarding_enabled; then
		echo "enabled"
              else
		echo "disabled"
              fi
              ;;
	  *)  echo "USAGE: $(basename $0) [-c]" >&2; exit 1 ;;
	esac
else
	toggle_forwarding
fi
