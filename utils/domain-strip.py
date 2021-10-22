#!/usr/bin/env python3
#
# Copyright (c) 2016-2021 Darren Spruell <dspruell@sancho2k.net>
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
#
# Print out supradomains from list of given FQDNs.

import argparse
import re
import sys


DOM_PART_PATTERN = r"[^.]+"


def main():
    parser = argparse.ArgumentParser()
    parser.description = "Extract specified level of domains from input FQDNs."
    parser.add_argument(
        "--unique",
        "-u",
        action="store_true",
        help="Return only the unique extracted domains in sorted order",
    )
    parser.add_argument(
        "levels",
        type=int,
        help="Number of domain levels to return [1: TLD, 2: second-level, etc.]",
    )
    parser.add_argument(
        "infile",
        type=argparse.FileType(),
        nargs="?",
        default=sys.stdin,
        help="Input file of FQDNs to process (or stdin, if ommitted)",
    )
    args = parser.parse_args()

    dom_pattern = re.compile(
        ".".join([DOM_PART_PATTERN for x in range(args.levels)] + list("$"))
    )

    doms = []
    for fqdn in args.infile:
        fqdn = fqdn.strip()
        parts = fqdn.split(".")
        doms.append((".".join(parts[-args.levels :])))

    if args.unique:
        doms = list(set(doms))

    print("\n".join(sorted(doms)))


if __name__ == "__main__":
    main()
