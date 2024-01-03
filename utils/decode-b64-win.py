#!/usr/bin/env python3

# Decode Base64 encoded data from an input file or stream. This is optimized
# for PowerShell encoded script content, which is typically encoded as
# UTF-16LE Base64 data.

import chardet
import logging
from argparse import ArgumentParser, FileType
from base64 import b64decode

DEFAULT_ENCODING = "utf-16le"

logging.basicConfig(
    level=logging.WARNING, format="%(asctime)s [%(levelname)s] %(message)s"
)


def main():
    """Run main program."""

    parser = ArgumentParser()
    parser.add_argument(
        "infile", type=FileType("r"), help="input file (default: stdin)"
    )
    parser.add_argument(
        "-D",
        "--decode-charset",
        action="store_true",
        help="attempt to detect and decode character sets",
    )
    parser.add_argument(
        "-d",
        "--debug",
        action="store_true",
        help="enable debug logging",
    )
    args = parser.parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    data = args.infile.read().strip()
    args.infile.close()

    dec = b64decode(data)
    enc = DEFAULT_ENCODING
    if args.decode_charset:
        guess = chardet.detect(dec)
        enc = guess["encoding"]
        logging.debug("detected character set: %s", enc)
    logging.debug("decoding using character set: %s", enc)
    print(dec.decode(enc))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
