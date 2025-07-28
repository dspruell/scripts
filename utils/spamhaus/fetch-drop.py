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

# Download Spamhaus DROP data.

import logging
from datetime import datetime
from urllib.request import urlopen


DROP_LISTS = {
    "DROP": "https://www.spamhaus.org/drop/drop_v4.json",
    "DROPv6": "https://www.spamhaus.org/drop/drop_v6.json",
    "ASN-DROP": "https://www.spamhaus.org/drop/asndrop.json",
}

logging.basicConfig(level=logging.INFO, format="[%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


def main():
    for name, url in DROP_LISTS.items():
        today = datetime.today().strftime("%Y%m%d")
        outfile_stem = f"spamhaus-{name.lower()}-{today}"
        outfile = f"{outfile_stem}.json"
        logger.info("Fetching data for %s...", name)
        with open(outfile, "wb") as f:
            with urlopen(url) as u:
                f.write(u.read())


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
