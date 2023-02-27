#!/usr/bin/env python3
#
# Calculate file entropy using Shannon entropy.
#
# Copyright (c) 2015 Darren Spruell <phatbuckett@gmail.com>
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
from collections import Counter
from math import log
from pathlib import Path

from tabulate import tabulate


HIGH_ENTROPY_LEVEL = 0.8


def shannon_p(p):
    return p * log(p, 2)


def shannon(data):
    freq = frequency(data)
    summed = sum([shannon_p(p) for p in freq.values()])
    return -1 * summed / 8.0


def frequency(data):
    ctr = Counter(data)
    size = len(data)
    freq = {}
    for char, ct in ctr.items():
        freq[char] = float(ct) / size
    return freq


def shannon_file(path):
    with open(path, "rb") as f:
        data = f.read()
    return shannon(data)


def check_files(paths, full_path=False):
    out = []
    for path in paths:
        p = path if full_path else Path(path).name
        entropy = shannon_file(path)
        extra = (
            "probably compressed or encrypted"
            if entropy > HIGH_ENTROPY_LEVEL
            else ""
        )
        out.append([p, entropy, extra])
    return out


def main():
    descr = "Output entropy for input file(s)."
    parser = argparse.ArgumentParser(description=descr)
    parser.add_argument("--full-path", "-f", action="store_true")
    parser.add_argument("path", nargs="+", help="path(s) to check entropy of")
    args = parser.parse_args()

    data = check_files(args.path, full_path=args.full_path)
    print(tabulate(data, headers=["path", "entropy", "extra"]))


if __name__ == "__main__":
    main()
