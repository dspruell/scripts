#!/usr/bin/env python3
#
# URL encode or decode data.
#
# Copyright (c) 2016-2023 Darren Spruell <phatbuckett@gmail.com>
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

from argparse import ArgumentParser, FileType
from urllib.parse import quote, unquote


def main():
    descr = "URL encode or decode input data."
    parser = ArgumentParser(description=descr)
    parser.add_argument(
        "--encode",
        "-e",
        action="store_true",
        help="URL encode input (default: decode)",
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--input-file",
        "-f",
        type=FileType("r"),
        nargs="?",
        help="input file to encode/decode ('-' for stdin)",
    )
    group.add_argument("data", nargs="?", help="data to encode/decode")
    args = parser.parse_args()

    if args.input_file:
        indata = args.input_file.read().rstrip()
        args.input_file.close()
    if args.data:
        indata = args.data

    action = quote if args.encode else unquote
    print(action(indata))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
