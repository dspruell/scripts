#!/usr/bin/env python3

# Copyright (c) 2025 Darren Spruell <phatbuckett@gmail.com>
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

# Search StrangerealIntel/EternalLiberty data for matching group name mappings.
#
# Requirements:
#
# - Run in a Python environment (optionally, virtual) that includes the
#   tabulate module.
# - Path to the EternalLiberty JSON file is set in the ETERNALLIBERTY_JSON_FILE
#   environment variable.
#
# EternalLiberty: https://github.com/StrangerealIntel/EternalLiberty

import logging
import os
import re
from argparse import ArgumentParser
from datetime import datetime
from json import load as json_load
from pathlib import Path

from tabulate import tabulate


# Default data file path; can be overriden with -f argument
EL_JSON = os.environ["ETERNALLIBERTY_JSON_FILE"]

logging.basicConfig(
    level=logging.WARNING, format="[%(levelname)s] %(message)s"
)


def main():
    """Main function."""
    parser = ArgumentParser()
    parser.add_argument(
        "-f", "--file", default=EL_JSON, help="path to EternalLiberty.json"
    )
    parser.add_argument(
        "-S",
        "--case-sensitive",
        action="store_true",
        help="use case-sensitive pattern match",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="enable verbose output",
    )
    parser.add_argument(
        "term", help="search term or regular expression pattern"
    )
    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    logging.debug("specified EternalLiberty data file: %s", args.file)

    data_file = Path(args.file).expanduser().resolve()

    RE_TERM = re.compile(
        args.term, re.NOFLAG if args.case_sensitive else re.IGNORECASE
    )

    try:
        with data_file.open() as f:
            el_data = json_load(f)
    except Exception as e:
        parser.error(f"unable to read target file ({e})")

    logging.info(
        "EternalLiberty v%s at %s (last-modified %s)",
        el_data["version"],
        data_file.resolve(),
        datetime.fromtimestamp(data_file.stat().st_mtime),
    )

    results = set()

    for rec in el_data["data"]:
        recdata = [rec["official_name"], rec["country"], rec["type"]]
        recdata.append(
            tabulate(
                [[a["entity"], f': {a["name"]}'] for a in rec["alias"]],
                tablefmt="plain",
            )
        )
        recdata = tuple(recdata)
        m_name = RE_TERM.search(rec["official_name"])
        if m_name:
            results.add(recdata)
        else:
            for a in rec["alias"]:
                m_alias = RE_TERM.search(a["name"])
                if m_alias:
                    results.add(recdata)

    if results:
        print(tabulate(sorted(results), tablefmt="simple_grid"))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
