#!/usr/bin/env python2
#
# Copyright (c) 2011 Darren Spruell <phatbuckett@gmail.com>
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

# Extraction utility for McAfee BUP format quarantine files.
#
# BUP files are created as follows:
#  - Files encoded using XOR with single-byte key (specified below)
#  - File and detection metadata recorded in plain text
#  - Quarantined files and metadata archived and compressed


import sys
import os.path
import subprocess
from optparse import OptionParser
import ConfigParser


# McAfee's BUP files are xor'd with 0x6a
KEY = ord('\x6a')

# BUPs store metadata in Details file by default
META_NAME = "Details"


def single_byte_xor(buf, KEY):
    "Simple single byte XOR transform"

    out = ''
    for i in buf:
        out += chr(ord(i) ^ KEY)
    return out


def explode_quarantine(quar_path, meta=False):
    """
    Decode packed BUP element file.
      quar_path: relative path to BUP quarantine file element (e.g. foo/Details)

    Return values:
      out_name: output file name for exploded quarantine file element

    """
    # prepare output filename for decoded quarantine file
    if meta:
        out_name = quar_path + ".txt"
    else:
        out_name = quar_path + ".bin"

    f = open(quar_path, 'rb')

    # read the encoded BUP file into memory
    quar_data = f.read()
    f.close()

    outfile = open(out_name, 'wb')
    explode_data = single_byte_xor(quar_data, KEY)

    outfile.write(explode_data)
    outfile.close()

    return out_name

def main():
    # parse options
    usage = "usage: %prog [options] file"
    parser = OptionParser(usage)
    parser.add_option("-d", "--dir", dest="dir",
                      help="directory to explode BUP archive into")
    (options, args) = parser.parse_args()

    if len(args) == 0:
        sys.stderr.write("ERROR: You must provide a BUP archive to work with.\n")
        sys.exit(1)

    if os.path.exists(args[0]):
        bup = args[0]
        bupname = os.path.basename(bup)
    else:
        sys.stderr.write("ERROR: Specified BUP does not exist.\n")
        sys.exit(1)
    pass

    # if output directory not specified, build one based on the name of the BUP file
    if options.dir:
        output_dir = options.dir
    else:
        output_dir = bupname.rstrip('.bup') + ".d"

    # structure the command format for 7z and uncompress the BUP
    try:
        o_opt = "-o%s" % output_dir  # because the option and directory have to be jammed together
        dnull = open('/dev/null')
        subprocess.check_call(["7z", "x", o_opt, "-bd", "-y", bup], stdout=dnull)
        dnull.close()
    except subprocess.CalledProcessError:
        sys.stderr.write("ERROR: cannot unpack specified file. Not a BUP archive?\n")
        sys.exit(1)
    except OSError as detail:
        sys.stderr.write("ERROR: problem calling 7-Zip: %s\n" % detail)
        sys.exit(1)

    # create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)

    print "[+] BUP file '%s' is %s bytes" % (bupname, os.path.getsize(bup))

    # Explode the metadata file
    meta_decode = explode_quarantine(os.path.join(output_dir, META_NAME), meta=True)
    meta_size = os.path.getsize(meta_decode)

    print "[+] Exploded packing list to %s (%s bytes)" % (meta_decode, meta_size)

    # Some BUPs appear to be corrupt; some can be rather large but when extracted
    # produce only a 0 byte Details file and no other output.
    if meta_size == 0:
        print "    [!] ERROR: received 0 byte quarantine metadata index (%s). Corrupt BUP?" % META_NAME
        sys.exit(1)

    # Handle other conditions where we unpack a less-than-useful metadata index.
    # If it can misparse this should catch it.
    try:
        config = ConfigParser.RawConfigParser()
        config.read(meta_decode)
        det    = config.get("Details", "DetectionName")
        c_yr   = config.get("Details", "CreationYear")
        c_mo   = config.get("Details", "CreationMonth")
        c_day  = config.get("Details", "CreationDay")
        c_hr   = config.get("Details", "CreationHour")
        c_min  = config.get("Details", "CreationMinute")
        c_sec  = config.get("Details", "CreationSecond")
        c_tz   = config.get("Details", "TimeZoneName")
        num_f  = config.getint("Details", "NumberOfFiles")
        det_ts = '%s-%s-%s %s:%s:%s %s' % (c_yr,c_mo,c_day,c_hr,c_min,c_sec,c_tz)

        print "    %s - %s file(s) [%s]" % (det,num_f,det_ts)

        for cnt in range(num_f):
            f_id = "File_%s" % cnt
            f_name = config.get(f_id, "OriginalName")
            print "      %s: %s" % (f_id,f_name)
            quar_decode = explode_quarantine(os.path.join(output_dir, f_id))
            print "        [+] Exploded quarantine file '%s' to %s (%s bytes)" % (f_id, quar_decode, os.path.getsize(quar_decode))
    except ConfigParser.NoSectionError:
        print "    [!] ERROR: unable to parse quarantine metadata index (%s).  Corrupt BUP?" % META_NAME
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)

