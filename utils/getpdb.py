#!/usr/bin/env python3
#
# Extract PDB paths from input PE file.
#
# Copyright (c) 2017 Darren Spruell <phatbuckett@gmail.com>
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

import pefile


def main():
    descr = "Extract PDB paths from input PE file."
    parser = ArgumentParser(description=descr)
    parser.add_argument("infile", type=FileType("rb"), help="input PE file")
    args = parser.parse_args()

    pe = pefile.PE(args.infile.name)
    if hasattr(pe, "DIRECTORY_ENTRY_DEBUG"):
        for i in pe.DIRECTORY_ENTRY_DEBUG:
            if hasattr(i.entry, "PdbFileName"):
                print(i.entry.PdbFileName.decode("utf-8"))
    args.infile.close()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
