#!/bin/sh
#
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
 
# Import IPVanish VPN OpenVPN configurations into NetworkManager. Optionally
# make useful transformations to the configuration, such as adding a username
# or removing deprecated options.

set -e

PROGNAME="$(basename "$0")"
DEPRECATED_OPTS_RE='^keysize'
NEW_CNT=0
DEL_CNT=0

usage()
{
    cat <<-EOF
	USAGE: $PROGNAME [options] [config]...
	  -u: add IPVanish account username to configs (usually required)
	  -r: reset/refesh profiles by deleting all IPVanish VPN configs and
	      importing new ones
	  -d: delete all IPVanish VPN configs and don't import new ones
	  -s: strip deprecated IPVanish options from configurations
	  -h: display this help output

	This script will import IPVanish .ovpn config files into NetworkManager.
	Imported configs are either those specified as parameters by the
	user, or all such files in the current working directory.

	When importing, you should really use the -u option to specify the
	IPVanish account username. You will be prompted for the account's
	password when connecting to a server.

	To refresh the imported configs, use -r; to delete all imported configs
	from NetworkManager, use -d.
EOF
}

# Reset connection profiles by deleting VPN profiles and preparing to import
# a new (presumably fresher) set.
# At this time only IPVanish VPN profiles (identified by connection name
# pattern) are deleted.
reset_vpn()
{
    connlist="$(nmcli -t -f NAME,UUID,TYPE connection show \
        | awk -F ':' '($3 == "vpn") && ($1 ~ /^ipvanish-[A-Z][A-Z]-/) {print $2}')"
    for conn_id in $connlist; do
        nmcli connection delete "$conn_id"
        DEL_CNT=$((DEL_CNT+1))
    done
}

# Output activity summary.
print_status()
{
    printf "[DONE] removed %s, added %s configuration(s)\n" "$DEL_CNT" "$NEW_CNT"
}

# Parse script arguments.
while getopts "u:rdsh" optchar; do
    case $optchar in
        u)  NMCLI_MOD_USER="$OPTARG"    ;;
        r)  NMCLI_RESET=1               ;;
        d)  NMCLI_REMOVE=1              ;;
        s)  STRIP_DEPRECATED=1          ;;
        h)  usage; exit 0               ;;
        *)  usage; exit 1               ;;
    esac
done
shift $((OPTIND - 1))


# Prepare to import either only the configurations supplied by user or
# all configurations in current directory.
OVPN_CONFS="ipvanish-*.ovpn"
CONFS="${*:-$OVPN_CONFS}"

# If asked to delete VPN profiles, remove and exit before proceeding to add
# new ones.
if [ -n "$NMCLI_RESET" ] || [ -n "$NMCLI_REMOVE" ]; then
    reset_vpn
    if [ -n "$NMCLI_REMOVE" ]; then
        print_status
        exit
    fi
fi

for conf in $CONFS; do
    if [ -n "$STRIP_DEPRECATED" ]
    then
        sed -e "/${DEPRECATED_OPTS_RE}/d" "$conf" > "${conf}.tmp"
        mv -- "${conf}.tmp" "$conf"
    fi
    conf_id="${conf%.ovpn}"
    nmcli connection import type openvpn file "$conf"
    nmcli connection modify "$conf_id" connection.autoconnect FALSE
    if [ -n "$NMCLI_MOD_USER" ]; then
        nmcli connection modify "$conf_id" +vpn.data username="$NMCLI_MOD_USER"
    fi
    NEW_CNT=$((NEW_CNT+1))
done

print_status
