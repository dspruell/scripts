#!/usr/bin/env python3
#
# Decode jjencoded file using jjdecode module.
#
# <https://github.com/crackinglandia/python-jjdecoder>
#
# Copyright (c) 2019  Darren Spruell <phatbuckett@gmail.com>
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

from jjdecode import JJDecoder


def main():
    descr = "Decode jjencoded file using jjdecode module."
    parser = ArgumentParser(descr)
    parser.add_argument(
        "infile", type=FileType("rb"), help="input file to decode"
    )
    args = parser.parse_args()

    jj = JJDecoder(args.infile.read())
    args.infile.close()

    print(jj.decode())


if "__name__" == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
