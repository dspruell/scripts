#!/usr/bin/env python3

import argparse
import ipaddress
import logging
import sys


logging.basicConfig(
    level=logging.WARNING,
    format="[%(levelname)s] %(message)s",
)


def count_addresses(f):
    total = 0
    for lineno, line in enumerate(f, 1):
        cidr = line.strip()
        if not cidr or cidr.startswith('#'):
            continue
        try:
            total += ipaddress.ip_network(cidr, strict=False).num_addresses
        except ValueError as e:
            logging.warning('line %s: skipping invalid entry: %s', lineno, e)
    return total


def main():
    parser = argparse.ArgumentParser(
        description='Count total IP addresses across CIDR blocks.'
    )
    parser.add_argument(
        'input',
        nargs='?',
        type=argparse.FileType('r'),
        default=sys.stdin,
        metavar='FILE',
        help='file of CIDR blocks, one per line (default: stdin)',
    )
    args = parser.parse_args()
    print(count_addresses(args.input))


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
