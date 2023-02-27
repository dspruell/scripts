#!/usr/bin/env python
#
# Author: Johan Nestaas (johan@riskiq.net)
#
# Deobfuscates and returns redirection elements from pseudo-Darkleech
# injections observed in early 2016.
#
# Copyright (c) 2016, RiskIQ, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import re
import sys
from collections import Counter
from bs4 import BeautifulSoup


RE_KEY = re.compile(r'.*-1;\w+="(\w+)"')


def deobfuscate(payload, key):
    browser_index = 2
    browser_index2 = browser_index - 1
    output = ""
    u = 0
    i0 = 0
    i1 = 0
    i2 = 0
    while True:
        if i0 >= len(payload):
            break
        c = payload[i0]
        o = ord(c)
        if o >= 97 and o <= 122:
            if i1 % browser_index:
                output += chr(((u + o - 97) ^ ord(key[i2 % len(key)])) % 255)
                i2 += 1
            else:
                u = (o - 97) * 26
            i1 += 1
        i0 += browser_index2
    return output


def load_html(path):
    with open(path) as f:
        html = f.read()
    return BeautifulSoup(html, "lxml")


def js_heur(de):
    c = Counter(de)
    chars = zip(*c.most_common())
    if not chars:
        return False
    chars = chars[0]
    if not chars:
        return False
    if len(chars) < 10:
        return False
    for c in chars:
        if ord(c) > 0x7F:
            return False
    return True


def get_key(text):
    s = text.split()
    for i in s:
        if not i.isdigit():
            return None
    dec = "".join(chr(int(c)) for c in s)
    m = RE_KEY.match(dec)
    if m is not None:
        return m.group(1)
    return None


def main():
    import argparse

    desc = (
        "Decode and return obfuscated redirection elements from "
        "pseudo-Darkleech injected webpages"
    )
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument("path", help="file containing injected page response")
    args = parser.parse_args()
    soup = load_html(args.path)
    divs = soup.find_all("div")
    for div in divs:
        key = get_key(div.text)
        if key is not None:
            break
    else:
        sys.exit("FAIL: key not found")
    for div in divs:
        text = div.text
        de = deobfuscate(text, key)
        if js_heur(de):
            print(de)


if __name__ == "__main__":
    main()
