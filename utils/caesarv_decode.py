#!/usr/bin/env python2
#
# Description: Decodes the URL from a CaesarV landing page
# Author: Yonathan Klijnsma (yonathan@riskiq.net)
# Created: 29-8-2017
#
# Copyright (c) 2017 Yonathan Klijnsma <yonathan@riskiq.net>
# Copyright (c) 2017 Darren Spruell <phatbuckett@gmail.com>
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

import os
import re
import sys


def caesarv_decode(pagedata):
    """
        Takes the CaesarV landing page content as an argument
        and decodes the redirection URL out of it. If it fails
        it simply returns an empty string.

    """
    decoded_cv_url = ""

    # Find the offset character
    char_offset = 0
    char_offset_re = re.compile(r'[\n\r\s\t;}{^a-z^A-Z][a-zA-Z]+\=(?P<str_arg>\d+);')
    char_offset_finds = char_offset_re.findall(pagedata)
    [char_offset] = [int(offset) for offset in char_offset_finds if int(offset) != 0]

    if not char_offset:
        print 'Could not obtain character offset from landing page!'
        return ''

    # Find the character array
    char_array = []
    char_array_re = re.compile(r'[\n\r\s\t;}{^a-z^A-Z][a-zA-Z]+\=\[(?P<str_arg>[\d,]+)\];')
    char_array_finds = char_array_re.findall(pagedata)
    if len(char_array_finds) == 0:
        print 'Could not obtain character array from landing page!'
        return ''

    char_array = [int(char_item) for char_item in char_array_finds[0].split(',')] 

    # Decode URL
    for i in xrange(len(char_array)):
        decoded_cv_url += chr(char_array[i] - char_offset)

    # Remove window.top.location.href in case its there
    if decoded_cv_url.startswith('window.top.location.href='):
        decoded_cv_url = decoded_cv_url[26:-2]

    return decoded_cv_url


def main():
    if len(sys.argv) != 2:
        print 'Usagage: caesarv_decode.py <landing page html>'
        sys.exit(-1)

    if not os.path.isfile(sys.argv[1]):
        print 'The file specified \'%s\' is invalid!' % sys.argv[1]
        sys.exit(-1)

    try:
        print caesarv_decode(open(sys.argv[1], 'r').read())
    except:
        print 'The file specified \'%s\' could not be opened!' % sys.argv[1]
        sys.exit(-1)

    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
