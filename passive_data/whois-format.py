#!/usr/bin/env python3
#
# Copyright (c) 2014-2021 Darren Spruell <dspruell@sancho2k.net>
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

# Dirty little script to grab Whois data for a domain and output key fields in
# a condensed single-line format.

import sys
import datetime
from pythonwhois import get_whois


DEFAULT_STR = '-'


def get_ns_domains(nameservers):
    'Return parent domain(s) for list of DNS server FQDNs'
    x = set()
    for fqdn in nameservers:
        dom = '.'.join(fqdn.split('.')[1:]).lower()
        x.add(dom)
    return list(x)


def main():
    output_tpl = ('{domain}  {creation_date}  {registrar}  {nameservers} '
                  '{registrant_name}  {registrant_email}')
    domain = sys.argv[1].upper()
    data = get_whois(domain, normalized=[])
    fields = {}
    fields['domain'] = domain
    dt = list(set(data.get('creation_date', DEFAULT_STR)))[0]
    if isinstance(dt, datetime.datetime):
        fields['creation_date'] = dt.strftime('%Y-%m-%d')
    else:
        fields['creation_date'] = DEFAULT_STR
    fields['registrar'] = data.get('registrar', DEFAULT_STR)[0]
    ns_list = get_ns_domains(data.get('nameservers', []))
    fields['nameservers'] = ', '.join(ns_list or ['-'])
    registrant = data['contacts'].get('registrant')
    if registrant:
        fields['registrant_name'] = registrant.get('name', DEFAULT_STR)
        fields['registrant_email'] = registrant.get('email', DEFAULT_STR)
    else:
        fields['registrant_name'] = fields['registrant_email'] = DEFAULT_STR
    print(output_tpl.format(**fields))


if __name__ == '__main__':
    main()
