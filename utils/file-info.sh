#!/bin/sh
#
# Copyright (c) 2023 Darren Spruell <dspruell@sancho2k.net>
#
# Output file information. Print a quick ID run on a file to include the file
# base name, size in bytes, CRC-32 and several checksum values, and file type,
# MIME type, and the first 16 byte values for the file header.
#
# This needs to be more portable; it is written and tested on macOS.

set -e -u

PATH="/usr/local/bin:/usr/bin:/bin"


# Calculate file hashes using OpenSSL
get_digest()
{
	_d="$1"  # digest type
	_f="$2"  # input file
	openssl dgst -"${_d}" -hex "$_f" | awk '{print $NF}'
}


# Output file info as a text blob
get_file_info()
{
	_f="$1"
	eval "$(stat -s "$_f")"

	cat <<-EOF
File Name: $(basename "$_f")
File Size: ${st_size}
   CRC-32: $(crc32 "$_f")
      MD5: $(get_digest md5 "$_f")
     SHA1: $(get_digest sha1 "$_f")
   SHA256: $(get_digest sha256 "$_f")
MIME Type: $(file -b --mime-type "$_f")
File Type: $(file -b "$_f")
Raw Bytes: $(head -c16 "$_f" | xxd | cut -c11-)
EOF
}


c="$#"  # Number of input files

for f in "$@"
do
	get_file_info "$f"
	c=$((c-1))
	[ "$c" -gt 0 ] && echo
done
exit 0
