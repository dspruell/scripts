#!/usr/bin/env python3
#
# PROTOTYPE: quick & dirty triage script to deserialize HAR files and run
# YARA rules against resulting text blob. YARA rules file may be specified as
# an option or (recommended) set as path in YARA_RULES env var - this allows
# you to set the path to the file in a version control checkout.
#
# Copyright (c) 2015 Darren Spruell <phatbuckett@gmail.com>
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

import argparse
import json
import os.path
import yara

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO


def comma_str(string):
    """
    Comma-separated list argument type for ArgumentParser.
    Formats a comma-separated list of strings into list and returns list.

    """
    return string.split(",")


parser = argparse.ArgumentParser(description="Scan HAR file with YARA")
parser.add_argument(
    "harfile", type=argparse.FileType("rb"), help="path to HAR file"
)
parser.add_argument(
    "--verbose",
    "-v",
    action="store_true",
    help="show (unique) matching strings",
)
parser.add_argument(
    "--yara-rules",
    "-y",
    dest="yararules",
    default=os.environ.get("YARA_RULES"),
    help="path to YARA rules file to use",
)
parser.add_argument(
    "--exclude-tags",
    "-x",
    type=comma_str,
    nargs="?",
    const="low_confidence",
    help="list of tag names on rules to exclude from matching"
    " (comma-separated; default: %(const)s)",
)
parser.add_argument(
    "--dump",
    "-d",
    action="store_true",
    help="dump HAR file intermediary text to file (output as <harfile>.dump)",
)
args = parser.parse_args()
if not args.yararules:
    parser.error(
        "must specify YARA rules file"
        " (use -y option or set YARA_RULES to rules file path)"
    )

try:
    rules = yara.compile(os.path.expanduser(args.yararules))
except yara.Error as e:
    parser.error("problem loading rules file %s: %s" % (args.yararules, e))

har = json.load(args.harfile)
# explicitly close open file, argparse leaves hanging open
args.harfile.close()

# Build a StringIO buffer to which to write decoded URLs, response headers, and
# response body payloads.
scratch = StringIO()
for entry in har["log"]["entries"]:
    if entry["request"]["url"].startswith("http://") or entry["request"][
        "url"
    ].startswith("https://"):
        scratch.write(entry["request"]["url"] + "\n")
        for header in entry["response"]["headers"]:
            scratch.write("%(name)s: %(value)s\n" % header)
        scratch.write(
            "%s\n"
            % entry["response"]["content"]
            .get("text", "")
            .encode("ascii", "ignore")
        )

# Tally YARA rule matches
data = scratch.getvalue()
scratch.close()
matches = rules.match(data=data)

# Dump stringio buffer to file
if args.dump:
    out_name = args.harfile.name + ".dump"
    with open(out_name, "wb") as f:
        f.write(data)
    print("[*] Plain text data dumped to %s" % out_name)

for match in matches:
    # XXX probably a better way of doing this
    tag_abort = False
    for tag in match.tags:
        if args.exclude_tags and tag in args.exclude_tags:
            tag_abort = True
    if tag_abort:
        continue
    print(
        "%s%s"
        % (match.rule, " (%s)" % ", ".join(match.tags) if match.tags else "")
    )
    if args.verbose:
        if match.strings:
            match_pile = []
            for m in match.strings:
                if m[2] not in match_pile:
                    match_pile.append(m[2])
            for match_str in match_pile:
                print("    %s" % match_str)
