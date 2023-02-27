#!/bin/sh
#
# Copyright (c) 2006-2021 Darren Spruell <dspruell@sancho2k.net>
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

# !!! WARNING !!!
# This script does not work in the recommended configuration for unprivileged
# user account usage in ports. Users are encouraged to consult the following:
# - https://www.openbsd.org/faq/faq5.html#wsrc
# - https://www.openbsd.org/faq/ports/ports.html#PortsConfig

# This script automates the update of the local source tree (/usr/src/) and
# the ports tree (/usr/ports/) using AnonCVS. AnonCVS is documented at
# http://www.openbsd.org/anoncvs.html.
# This script is written with only the capability to track -stable; use
# the manual methods to track -current or -release+patches.

# Set your CVSROOT from http://www.openbsd.org/anoncvs.html#CVSROOT.
CVSROOT=anoncvs@anoncvs1.usa.openbsd.org:/cvs


if [ $(id -u) -ne 0 ]; then
    echo "ERROR: This script should be run with superuser privileges." >&2
    exit 1
fi

# Don't mess with this: "OPENBSD_X_Y" to follow -stable
TAG=$(uname -sr | tr '[:lower:]' '[:upper:]' | tr '[ .]' '_')
SRCPATH=/usr/src
PORTSPATH=/usr/ports

up_src()
{
    if [ ! -d $SRCPATH -o -z "$(ls $SRCPATH 2>/dev/null)" ]; then
        echo ERROR: You must have a source tree present in $SRCPATH
        echo before tying to update.
        exit 1
    fi
        
    cd $SRCPATH
    cvs -d${CVSROOT} -q up -r${TAG} -Pd
    if [ $? -eq 0 ]; then
        echo
        echo "AnonCVS update of source tree (base path: $SRCPATH) completed successfully."
        echo
    fi
}

up_ports()
{
    if [ ! -d $PORTSPATH -o -z "$(ls $PORTSPATH 2>/dev/null)" ]; then
       	echo ERROR: You must have a ports tree present in $PORTSPATH
       	echo before trying to update.
        exit 1
    fi
    cd $PORTSPATH
    cvs -d${CVSROOT} -q up -r${TAG} -Pd
    if [ $? -eq 0 ]; then
        echo
        echo "AnonCVS update of ports tree (base path: $PORTSPATH) completed successfully."
        echo "Run '$(basename $0) pindex' to update the ports tree index."
        echo
    fi
}

index_ports()
{
    cd $PORTSPATH
    make index
    if [ $? -eq 0 ]; then
        echo
        echo "Update of ports tree index (base path: $PORTSPATH) completed successfully."
        echo
    fi
}

check_ports()
{
    read ANS?"Have you recently run '$(basename $0) pindex'? [y/n]: "
    if [ "$ANS" != "y" ]; then
        echo "ERROR: Running out-of-date without an updated port index can give you"
        echo "invalid discrepancies with your installed packages. Make sure you have"
        echo "run '$(basename $0) pindex' before trying this."
        exit 1
    fi
    # Program has migrated around 5.x
    if [ -x $PORTSPATH/infrastructure/bin/out-of-date ]; then
        $PORTSPATH/infrastructure/bin/out-of-date
    fi
}

show_config()
{
    cat <<- EOF
	
	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	Configuration for $(basename $0)
	
	+ Source tree base path:
	$SRCPATH
	+ Ports tree base path:
	$PORTSPATH
	+ AnonCVS source:
	$CVSROOT
	+ CVS tag:
	$TAG (stable)
	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	
EOF
}

do_help()
{
    echo "USAGE: $(basename $0) <src|ports|pindex|pcheck|-c>"
    cat <<- END
	    src -- Update the source tree.
	  ports -- Update the ports tree.
	 pindex -- Rebuild ports tree index after update.
	 pcheck -- Check installed packages against updated ports tree.
	     -c -- Display script configuration.
END
}

# Process arguments
if [ $# -ne 1 ]; then
    do_help
    exit 1
fi

case $1 in
    ports)
       	up_ports
       	;;
    src)
       	up_src
       	;;
    pindex)
       	index_ports
       	;;
    pcheck)
       	check_ports
       	;;
    -c)
       	show_config
       	;;
    *)
       	do_help
       	exit 1
       	;;
esac
