#!/usr/bin/env python3

"""
Extract all actor names from MicrosoftMapping.json:

https://github.com/microsoft/mstic/blob/master/PublicFeeds/ThreatActorNaming/MicrosoftMapping.json

"""

import logging
from argparse import ArgumentParser, FileType
from json import load as json_load

logging.basicConfig(level=logging.DEBUG, format="%(message)s")


def main():
    "Run main program."

    parser = ArgumentParser()
    parser.add_argument(
        "infile",
        type=FileType("r"),
        help="input file to extract (default: stdin)",
    )
    args = parser.parse_args()

    ta_data = json_load(args.infile)
    args.infile.close()

    from pprint import pprint

    all_names = set()

    for ta in ta_data:
        all_names.add(ta["Previous name"])
        all_names.add(ta["New name"])
        for n in ta["Other names"]:
            all_names.add(n)

    print("\n".join(list(all_names)))
    logging.debug("[*] Extracted %d threat actor names", len(all_names))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
