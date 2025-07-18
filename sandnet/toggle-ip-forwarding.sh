#!/bin/sh
#
# Toggle IP forwarding kernel knobs to forward or limit forwarding of
# traffic across network interfaces. Support is implemented for Linux and BSD
# system variables.
#
# Copyright (c) 2022-2024 Darren Spruell <phatbuckett@gmail.com>
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

KNOB_IPV4_LINUX="net.ipv4.ip_forward"
KNOB_IPV4_BSD="net.inet.ip.forwarding"
KNOB_IPV6_LINUX="net.ipv6.conf.all.forwarding"
KNOB_IPV6_BSD="net.inet6.ip6.forwarding"
VAL_OFF=0
VAL_ON=1


log_verbose()
{
	[ -n "$ENABLE_VERBOSE" ] && echo "$1"
}


# Check and return a status indicating if IP forwarding is enabled.
#
# Arguments:
# * Positional arguments for one or more kernel variables (1 or 2, indicating
#   variables for checking IPv4 and IPv6 forwarding).
check_forwarding_enabled()
{
	for V in $@
	do
		VAL="$(/sbin/sysctl -n "$V")"
		log_verbose "$V = $VAL"
		case "$VAL" in
		  0)
			  # Forwarding not enabled, so fail out
			  return 1
			  ;;
		  1)
			  _stat=0
			  ;;
		  *)  echo "Unrecognized sysctl value: $VAL" >&2; exit 1 ;;
		esac
	done

	return "$_stat"
}


toggle_forwarding()
{
	if check_forwarding_enabled $KNOBS; then
		for V in $@
		do
			/sbin/sysctl "${KNOB}"="$VAL_OFF"
		done
	else
		for V in $@
		do
			/sbin/sysctl "${KNOB}"="$VAL_ON"
		done
	fi
}


show_usage()
{
	cat <<-EOF
	USAGE: $(basename "$0") [options]

	Toggle or display state of kernel IP forwarding on the host.

	Options:
	  -c:  Check and report status of IP forwarding.  By default,
	       only IPv4 is considered.  If the -b (both protocols) option is
	       also specified, the status reflects whether both IPv4 and IPv6
	       forwarding is enabled.
	  -b:  Toggle support for both IPv4 and IPv6.  By default, only IPv4 forwarding
	       is considered.  Note that if this option is used without the
	       check option, only the value of the IPv4 forwarding variable
	       will be used to set the state of variables for both protocols.
	  -v:  Enable verbose output.
	  -h:  Display this help output.

	Without the -c option, the state of IPv4 forwarding (or IPv4 and IPv6) is toggled.
EOF
}


# Parse program arguments
while getopts "cbvh" OPTCHAR; do
    case "$OPTCHAR" in
        c)  ENABLE_CHECK=1       ;;
        b)  ENABLE_BOTH_PROTO=1  ;;
        v)  ENABLE_VERBOSE=1     ;;
        h)  show_usage; exit 0   ;;
    esac
done
shift $((OPTIND - 1))

SYS_KERNEL="$(uname -s)"
case "$SYS_KERNEL" in
	  Linux)
		KNOBS="$KNOB_IPV4_LINUX"
		[ -n "$ENABLE_BOTH_PROTO" ] && KNOBS="$KNOBS $KNOB_IPV6_LINUX"
		;;
	  *BSD)
		KNOBS="$KNOB_IPV4_BSD"
		[ -n "$ENABLE_BOTH_PROTO" ] && KNOBS="$KNOBS $KNOB_IPV6_BSD"
		;;
	  *)
		echo "Unrecognized system type: $SYS_KERNEL" >&2
		exit 1
		;;
esac

if [ -n "$ENABLE_CHECK" ]
then
	if check_forwarding_enabled $KNOBS; then
		echo "enabled"
	else
		echo "disabled"
	fi
else
	toggle_forwarding $KNOBS
fi
