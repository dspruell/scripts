#!/bin/sh
#
# Wrapper around GNU strings(1) to dump all possible types of strings from
# a file. Allows adjustment of string length and inspects complete file
# contents.
#
# $Id: strings-multi.sh 681 2015-05-10 05:39:52Z dspruell $
#
# Copyright (c) 2013-2023 Darren Spruell <phatbuckett@gmail.com>
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

# Encoding designators supported by GNU strings(1)
ENCTYPES="s S b B l L"
# Override with -n option
DEFAULT_LENGTH=6


usage()
{
    cat <<-EOF
	USAGE: $(basename "$0") [options] FILE ...

	Output all identifiable strings in given file(s) to files on filesystem

	Options:
	  -n num:  Extract strings with minimum length of num (default: $DEFAULT_LENGTH)
	  -s:  Write extracted strings to standard output as well as files. This sorts
	       and dedupes strings and can be useful for an overview of all strings,
	       but has the side effect of destroying the natural order of strings as
	       they appear in the file.
	  -l:  List each string from identified encodings on standard output, ordered
	       by encoding type. Similar to -s but leaves string ordering intact.
	  -v:  Enable verbose output
	  -h:  Display this help output

EOF
}

# Handle verbose output
printv()
{
    if [ -n "$VERBOSE" ]; then
        echo "[*] $1" >&2
    fi
}

# Validate that system uses GNU strings; other implementations lack needed
# options.
check_strings_imp()
{
    for cmd in strings gstrings; do
        printv "Testing for suitable strings(1) implementation: $cmd"
        local cmdpath="$(which ${cmd} 2>/dev/null)" || continue
        printv "Testing $cmdpath..."
        if "$cmdpath" -e s "$0" >/dev/null 2>&1; then
            printv "Compatible! Using $cmdpath."
            strings="$cmdpath"
            return 0
        else
            printv "Found $cmdpath, but it's not GNU strings."
        fi
    done
    # If we reach here, couldn't find suitable strings command.
    echo "Aborting: script requires GNU or compatible strings program." >&2
    exit 1
}

# Return encoded character type name for given designator
get_encoding_name()
{
    case $1 in
        s)  local NAME="Single 7-bit chars" ;;
        S)  local NAME="Single 8-bit chars" ;;
        b)  local NAME="16-bit bigendian chars" ;;
        B)  local NAME="16-bit littleendian chars" ;;
        l)  local NAME="32-bit bigendian chars" ;;
        L)  local NAME="32-bit littleendian chars" ;;
    esac
    echo "$NAME"
}

# Parse script arguments
while getopts "n:slvh" optchar; do
    case $optchar in
        n)  LENGTH=$OPTARG   ;;
        s)  WRITE_STDOUT=1   ;;
        l)  LIST_SEPARATE=1  ;;
        v)  VERBOSE=1        ;;
        h)  usage; exit 0    ;;
        *)  usage; exit 1    ;;
    esac
done
shift $((OPTIND - 1))

check_strings_imp

# Process arguments
MIN_LENGTH=${LENGTH:-$DEFAULT_LENGTH}
printv "Setting string minimum length: $MIN_LENGTH"
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# Process all file paths given as arguments. For each supported encoding,
# output strings to unique filename and optionally print results to stdout.
for file in "$@"; do
    ENCODING_NONEMPTY=""
    for enc in $ENCTYPES; do
        OUTFILE="${file}_strings_enc-${enc}"
        "$strings" -a -e "$enc" -n "$MIN_LENGTH" "$file" > "$OUTFILE"
        OUTFILE_CNT=$(wc -l <"$OUTFILE")
        if [ -n "$WRITE_STDOUT" ] || [ -n "$LIST_SEPARATE" ]; then
            # File names output to stderr when strings requested on stdout
            printf "%5d lines:  %s\n" "$OUTFILE_CNT" "$OUTFILE" >&2
        else
            printf "%5d lines:  %s\n" "$OUTFILE_CNT" "$OUTFILE"
        fi
        if [ "$OUTFILE_CNT" -ne 0 ]; then
            ENCODING_NONEMPTY="$ENCODING_NONEMPTY $enc"
        fi
    done
    if [ -n "$WRITE_STDOUT" ] && [ -z "$LIST_SEPARATE" ]; then
        if [ $# -gt 1 ]; then
            echo "##"
            echo "## $file"
            echo "##"
        fi
        cat "${file}"_strings_enc-* | sort -u | sed '/^$/d'
    fi
    if [ -n "$LIST_SEPARATE" ]; then
        if [ $# -gt 1 ]; then
            echo "##"
            echo "## $file"
            echo "##"
        fi
        for enc in $ENCODING_NONEMPTY; do
            ENC_NAME="$(get_encoding_name "$enc")"
            echo ----------------------
            echo "$ENC_NAME"
            echo ----------------------
            cat "${file}_strings_enc-${enc}"
            echo
        done
    fi
done
