#!/bin/sh

# Decrypt encrypted pfSense configuration backup.
#
# Encryption passphrase is prompted on stdin, but is passed as an argument to
# the openssl(1) command and may be captured in the process tree or command
# execution logging.
#
# Reference:
# <https://forum.netgate.com/topic/139561/pfsense-xml-config-file-can-we-decrypt-it-manually>
#
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

set -e

# Ensure echo is restored on exit/interruption
cleanup() {
	stty echo
	echo ""
}

# Trap normal exits, interruptions (Ctrl+c), and terminations
trap cleanup EXIT INT TERM

IN_FILE="$1"
OUT_FILE="${IN_FILE%.xml}-decr.xml"

printf "Enter passphrase to decrypt: "

stty -echo
IFS= read -r DECRYPT_PASS

openssl enc -d -in "$IN_FILE" -out "$OUT_FILE" -a -aes-256-cbc \
	-pass pass:"$DECRYPT_PASS" -salt -md sha256 -pbkdf2 -iter 500000
