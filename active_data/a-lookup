#!/bin/sh
#
# Copyright (c) 2007-2021 Darren Spruell <dspruell@sancho2k.net>
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

# Performs a lookup for a given FQDN to resolve its forward DNS IP address.
# Usage: send the script a list of FQDNs via stdin.

geta()
{
    local fqdn="$1"
    printf "%-35s" $1
    response=$(dig +short $fqdn | egrep \
        "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}")
    if [ X"$response" = X"" ]; then
        echo " No IP resolution"
    else
        for address in $response; do
            printf " %s" $address
        done
        printf "\n"
    fi
}

while read fqdn; do
    geta ${fqdn%.}  # Trim off trailing . from FQDNs
done
