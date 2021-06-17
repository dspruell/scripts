#!/usr/bin/env python3
#
# Author: Darren Spruell (phatbuckett@gmail.com)
#
# Script to extract and format capture thread packet receipt and drop rate
# as timestamped drop percentage.
# Usage: specify stats log file(s) as argument(s), filter output through
# sort(1) to restore chronlogical order.

import re
import sys
import fileinput


STATS_LOG = '/var/log/suricata/stats.log'
TS_REGEX = re.compile(r'Date:\s+(?P<month>\d+)/(?P<day>\d+)/(?P<year>\d+) -- (?P<time>\S+)')
TS_FMT = '{year}-{month}-{day}T{time}'

data = {}

# If no input files specified, default to current stats log file
if len(sys.argv) < 2:
    sys.argv.append(STATS_LOG)

# Use compressed file openhook to transparently handle archived log files
for line in fileinput.input(openhook=fileinput.hook_compressed):
    if line.startswith('Date:'):
        # Date: 1/27/2016 -- 13:20:06 (uptime: 0d, 22h 30m 15s)
        m = TS_REGEX.match(line)
        datekey = TS_FMT.format(**m.groupdict())
        data[datekey] = {
            'kernel_drops': [],
            'kernel_packets': [],
        }
        continue
    if line.startswith('capture.kernel_drops'):
        data[datekey]['kernel_drops'].append(int(line.split()[-1]))
    if line.startswith('capture.kernel_packets'):
        data[datekey]['kernel_packets'].append(int(line.split()[-1]))

for tstamp in data.keys():
    pairs = zip(data[tstamp]['kernel_drops'],
                data[tstamp]['kernel_packets'])
    for i in pairs:
        print('{tstamp}\t{percent:.0f}%'.format(
              tstamp=tstamp,
              percent=(float(i[0]) / float(i[1]) * 100)))

