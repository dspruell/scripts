#!/usr/bin/env python3
#
# Copyright (c) 2023 Darren Spruell <phatbuckett@gmail.com>
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

"""Make a regular expression alternation string out of a list of inputs."""

import re
from argparse import ArgumentParser, FileType

BOUND_META = r"\b"
YARA_TPL = "rule test {{strings: $s1 = /{expr}/ condition: all of them }}"


def get_escaped_terms(terms, add_boundaries=False):
    """Generate escaped variants of input terms."""
    for t in terms:
        t = t.strip()
        t = re.escape(t)
        if add_boundaries:
            t = f"{BOUND_META}{t}{BOUND_META}"
        yield t


def main():
    """Do the things."""
    description = "Create alternation regex from input string list."
    parser = ArgumentParser(description=description)
    parser.add_argument("infile", type=FileType("r"), help="input string file")
    parser.add_argument(
        "-b",
        "--add-boundaries",
        action="store_true",
        help=r"add \b word boundary assertions to pattern",
    )
    parser.add_argument(
        "-y",
        "--yara-re-str",
        action="store_true",
        help="output YARA rule stub containing regex string",
    )
    args = parser.parse_args()

    terms = args.infile.readlines()

    kwargs = {}
    kwargs["add_boundaries"] = args.add_boundaries

    output = "|".join(get_escaped_terms(terms, **kwargs))

    if args.yara_re_str:
        output = YARA_TPL.format(expr=output)

    print(output)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
