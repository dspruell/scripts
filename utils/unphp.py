#!/usr/bin/env python3
#
# Submit sample to UnPHP (http://www.unphp.net/) API and write decoded result
# to disk.
#
# Copyright (c) 2015  Darren Spruell <phatbuckett@gmail.com>
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
import os
import requests


UNPHP_API_URL = "http://www.unphp.net/api/v2/post"
UNPHP_API_KEY = os.environ["UNPHP_API_KEY"]


def main():
    descr = "Attempt to decode obfuscated PHP using UnPHP API."
    parser = ArgumentParser(description=descr)
    parser.add_argument("infile", type=FileType("rb"), help="input file")
    parser.add_argument("outfile", type=FileType("wb"), help="output file")
    args = parser.parse_args()

    data = {
        "api_key": UNPHP_API_KEY,
    }

    files = {"file": args.infile}
    r = requests.post(
        "http://www.unphp.net/api/v2/post", files=files, data=data
    )
    args.infile.close()

    data = r.json()
    if data["result"] == "success":
        decoded_url = data["output"]
        r = requests.get(decoded_url)
        payload = r.text
        if payload:
            args.outfile.write(payload)
            args.outfile.close()
            print("[*] Success: output in {}".format(args.outfile.name))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
