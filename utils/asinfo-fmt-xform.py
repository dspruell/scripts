#!/usr/bin/env python3
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

# Convert a commonly used AS information format to the format utilized in
# the aslookup tool.
#
# Sample input format:
#   AS30823         AUROLOGIC - aurologic GmbH, DE
# Sample output format:
#   AS30823 | DE | AUROLOGIC - aurologic GmbH
#
# The script also supports a "short" format that outputs only the ASName
# in the final field, ommitting the AS owner info if appended with
# a hyphen.

import re

from argparse import ArgumentParser, FileType


IN_FMT_RE = re.compile(
    r"^\s*(?P<ashandle>AS\d+)\s+(?P<asnamedesc>.+),\s+(?P<cc>[A-Z]+)$"
)


def main():
    parser = ArgumentParser()
    parser.add_argument(
        "infile",
        nargs="?",
        type=FileType(),
        help="input file or stream (default: stdin)",
    )
    parser.add_argument(
        "-n",
        "--name-only",
        action="store_true",
        help="show only the ASName (and not the AS description or owner)",
    )

    args = parser.parse_args()

    # Process stuff
    for line in args.infile:
        m = re.match(IN_FMT_RE, line)
        if m:
            ashandle = m["ashandle"]
            cc = m["cc"]
            asnamedesc = m["asnamedesc"]
            if args.name_only:
                asname = re.split(r" - ", asnamedesc, maxsplit=1)[0]
            else:
                asname = asnamedesc
            print(f"{ashandle} | {cc} | {asname}")

    args.infile.close()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
