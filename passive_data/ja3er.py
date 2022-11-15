#!/usr/bin/env python3
#
# Query ja3er.com for data related to input JA3 hash.
#
# https://ja3er.com/

from argparse import ArgumentParser
import requests

API_URL = "https://ja3er.com/search"


def main():
    "Query for input JA3 hash and output list of returned User-Agent values"

    parser = ArgumentParser()
    parser.add_argument("hash", help="JA3/JA3S hash")
    args = parser.parse_args()

    url = f"{API_URL}/{args.hash}"
    r = requests.get(url)
    j = r.json()

    for d in j:
        if "User-Agent" in d:
            print(d["User-Agent"])


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
