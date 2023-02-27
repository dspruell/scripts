#!/usr/bin/env python3
#
# Reverses and Base64 decodes a given input string parameter. Useful for
# e.g. decoding the landing page URI argument for Ramayana/Dotkachef EK.
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


from argparse import ArgumentParser
import base64


def reverse_b64decode(s):
    return base64.decodestring(s[::-1])


def main():
    descr = "Reverses and base64 decodes a given input string parameter."
    parser = ArgumentParser(description=descr)
    parser.add_argument("enc", help="encoded string to decode")
    args = parser.parse_args()

    print(reverse_b64decode(args.enc))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
