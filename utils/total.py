#!/usr/bin/env python3

# Copyright (c) 2019-2026 Darren Spruell <phatbuckett@gmail.com>
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

# Take an input file of numbers (newline separated whole or decimal)
# and output total, formatted in dollars. If more than one input file
# is given the total sum of all files is given at the end.

import argparse
import locale
import logging
import os


logging.basicConfig(format="[%(levelname)s] %(message)s")

locale.setlocale(locale.LC_ALL, "")

loglevels = ["error", "warning", "info", "debug"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "files",
        type=argparse.FileType("r"),
        nargs="+",
        metavar="FILE",
        help="input file",
    )
    parser.add_argument(
        "-l",
        "--loglevel",
        choices=loglevels,
        default="warning",
        help="log level (default: %(default)s)",
    )
    parser.add_argument(
        "-n",
        "--no-total",
        action="store_true",
        help="don't print total of multiple inputs",
    )
    args = parser.parse_args()

    logging.getLogger().setLevel(args.loglevel.upper())

    # Calculate length of input file with longest name
    max_file_len = max([len(f.name) for f in args.files])
    # Length used for printing number/cost values
    num_size = 11
    output_fmt_str = "%%-%ds  %%%ds" % (max_file_len, num_size)
    grand_total = 0

    for f in args.files:
        line_num = 0
        ftotal = 0
        logging.debug("file: %s", f.name)
        # Lines in the file are stripped of leading/trailing junk and handled
        # as follows:
        # 1. Ignore empty lines, lines incorrectly containing only whitespace,
        #    and any lines starting with a comment.
        # 2. Calculate remaining lines by adding the first field prior to any
        #    whitespace, allowing comments or notes to be appended to the line
        #    for context (after a whitespace character).
        for line in f:
            line_num += 1
            line = line.strip().strip("$").replace(",", "")
            logging.debug("line %d: >>>%s<<<", line_num, line)
            if line.startswith("#") or line in ("", os.linesep):
                continue
            try:
                ftotal += float(line.split()[0])
            except ValueError as e:
                logging.exception(
                    "error in %s on line %s: %s", f.name, line, e
                )

        total = locale.currency(ftotal, grouping=True)
        print(output_fmt_str % (f.name, total))
        grand_total += ftotal

    if len(args.files) > 1 and not args.no_total:
        print("-" * (max_file_len + 2 + num_size))
        print(
            output_fmt_str
            % ("Total:", locale.currency(grand_total, grouping=True))
        )


if __name__ == "__main__":
    main()
