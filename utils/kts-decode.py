#!/usr/bin/env python3
#
# Convert encoded data returned by KTS rotator into URL using following
# algorithm:
# - Strip non-hex characters from data
# - Convert resulting hex encoded string to ASCII letters
#
# Example:
#
# https://sf.riskiq.net/bl/81378624/1913e97fd9d36d19?_sg=oD8aapOu2u8caOGRhDuiAw%3D%3D
#
# Copyright (c) 2016 Darren Spruell <phatbuckett@gmail.com>
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

import argparse
import binascii
import re
import string


def decode_data(data):
    """Decode KTS rotator data string"""

    tmphex = ""
    if data.startswith("var "):
        data = re.search(r"var \w+='(?P<blob>[^\x27]+)';", data).group("blob")
    for c in data:
        if c in string.hexdigits:
            tmphex += c
    return binascii.unhexlify(tmphex)


def main():
    descr = "Decode encoded URL data blob from KTS rotator."
    parser = argparse.ArgumentParser(descr)
    parser.add_argument(
        "--file",
        "-f",
        type=argparse.FileType(),
        help="specified argument is a file to read data from",
    )
    parser.add_argument(
        "data",
        nargs="?",
        help="encoded data blob, optionally including full JS var statement",
    )
    args = parser.parse_args()

    print(decode_data(args.data or args.file.read()))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
