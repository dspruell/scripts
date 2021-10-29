#!/usr/bin/env python3
#
# Copyright (c) 2014-2021 Darren Spruell <dspruell@sancho2k.net>
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

# Turn newline separated list of items into SQL IN clause for given fieldname.

import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("field", help="name of field for IN clause to match")
    parser.add_argument(
        "-f",
        "--data-file",
        type=argparse.FileType("r"),
        default="-",
        help="data source for list (default: stdin)",
    )
    parser.add_argument(
        "-s",
        "--single-quote",
        action="store_true",
        help="surround strings with single quotes instead of double quotes",
    )
    args = parser.parse_args()

    qfmt = "'" if args.single_quote else '"'

    data_items = ",".join(
        [f"{qfmt}{i.strip()}{qfmt}" for i in args.data_file.readlines()]
    )
    args.data_file.close()

    print(f"{args.field} IN ({data_items})")


if __name__ == "__main__":
    main()
