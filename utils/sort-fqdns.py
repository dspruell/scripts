#!/usr/bin/env python
#
# Darren Spruell <dspruell@sancho2k.net>
#
# Transform list of FQDNs on standard input by sorting them according to
# reverse host notation (a.example.com sorted/grouped first by 'com', then by
# 'example', then by 'a').

import sys

reversed_fqdns = sorted([fqdn.strip().split('.')[::-1] for fqdn in sys.stdin])
print '\n'.join(['.'.join(fqdn[::-1]) for fqdn in reversed_fqdns])
