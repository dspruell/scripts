#!/usr/bin/env python2
#
# $Id: get-redirs.py 659 2014-06-13 23:10:06Z dspruell $
#
# Extract lines that match typical HTTP/HTML/JS redirs from page content. Also considers
# tags that don't redirect or include remote content per se, but may direct to external
# content if clicked (anchors) or submit data to external (form actions).

import re
import sys
from bs4 import BeautifulSoup

# This should get turned into selectors for BeautifulSoup, probably
PATTERNS = {
    'js_window_href': r'window\.location\.href[^=]*=',
}

# List of dictionaries, each containing the following:
# - description:  description of HTML tag
# - attrs:        dictionary of attribute names and values that must match
# - content:      tuple of attribute names that should be displayed for matching tags
TAGS = {
    'meta': {
        'description': 'meta refresh redirects',
        'attrs': {'http-equiv': re.compile("^refresh$", re.I)},
        'content': ('content',),
    },
    'iframe': {
        'description': 'inline frames',
        'attrs': None,
        'content': ('src',),
    },
    'script': {
        'description': 'external script includes',
        'attrs': None,
        'content': ('src',),
    },
    'a': {
        'description': 'anchors',
        'attrs': None,
        'content': ('href',),
    },
    'form': {
        'description': 'form actions',
        'attrs': None,
        'content': ('action',),
    },
}

if len(sys.argv) > 1:
    # Input file specified, scan a file
    with open(sys.argv[1], 'rb') as f:
        soup = BeautifulSoup(f)
else:
    soup = BeautifulSoup(sys.stdin)

## Process page accordingly:

for tag in TAGS:
    attrs = {} if TAGS[tag]['attrs'] is None else TAGS[tag]['attrs']

    tag_list = soup.find_all(tag, attrs=attrs)
    if tag_list:
        print ":: %s ('%s' tags)" % (TAGS[tag]['description'],tag)
        for t in tag_list:
            if TAGS[tag]['content'] is not None:
                for cont in TAGS[tag]['content']:
                    if t.get(cont):
                        print "[%s] %s" % (tag, t[cont])
            else:
                print t

