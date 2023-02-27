#!/usr/bin/env python2
#
# $Id: file-info.py 655 2014-05-29 05:56:07Z dspruell $
#
# Copyright (c) 2010-2014 Darren Spruell <phatbuckett@gmail.com>
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

# Display useful information for analyzing files.
#
# Requires (for full functionality): 
#    atklite  - basic file analysis, hashes, etc.
#    pefile   - analysis of PE file structure and packer detection
#    PyDNS    - DNS resolution for MHR lookup

import os
import sys
import time
from os.path import basename
from optparse import OptionParser
try:
    from cStringIO import StringIO
except:
    from StringIO import StringIO

import atklite

# Initialize errors list and do remaining imports
errs = []
try:
    import pefile
    import peutils
    PE_MODULE = True
except ImportError:
    errs.append("WARNING: Unable to load pefile module(s). PE analysis functionality disabled.")
    PE_MODULE = False
try:
    import DNS
    DNS_MODULE = True
except ImportError:
    errs.append("WARNING: Cannot load python DNS module (required for MHR lookup).")
    DNS_MODULE = False


class FileInfo(object):
    """
    Provides container for storing and returning information pertaining to given
    file. Available information stored as attibutes on the object.

    Basic information provided by aktlite library.

    If pefile is available, also attempt to parse file as PE and extract
    useful related information:

     - Flag the file as PE
     - Include image build-time time/date stamp
     - Include matching PE signatures if PEiD packer database set in caller's
       environment

    """
    def __init__(self, filepath):
        is_pe                 = False
        pe_sigs               = []
        pe_compiletime        = None
        pe_is_probably_packed = None

        fileanalysis = atklite.FileAnalysis(filename=filepath).return_analysis()
        cymru_mhr =  MHRChecker(hash)

        if PE_MODULE:
            try:
                self._pe = pefile.PE(filepath)
                is_pe = True
                pe_compiletime = "%s UTC" % time.asctime(time.gmtime(self._pe.FILE_HEADER.TimeDateStamp))
                pe_is_probably_packed = peutils.is_probably_packed(self._pe)
    
                # Read path to PE signature database from user's environment.
                try:
                    pedb = os.environ['PEDBPATH']
                except KeyError:
                    errs.append("WARNING: Unable to find PEDBPATH variable in environment.")
                    errs.append("         Point this variable to a valid PE signature database.")
                    pe_sigs.append("[unavailable]")
                else:
                    try:
                        signatures = peutils.SignatureDatabase(pedb)
                        matches = signatures.match(self._pe, ep_only = True)
                        if matches:
                            for id in matches:
                                pe_sigs.append(id)
                        else:
                            pe_sigs.append("No matches")
                    except IOError:
                        errs.append("ERROR: PE analysis requires valid path to a PE sig database in PEDBPATH.")
                        pe_sigs.append("[unavailable]")
            except pefile.PEFormatError as e:
                is_pe = False

        self.filename              = basename(filepath)
        self.analyzetime           = fileanalysis['analyzetime']
        self.filesize              = fileanalysis['size']
        self.filetype              = fileanalysis['ftype']
        self.crc32                 = fileanalysis['crc32']
        self.md5                   = fileanalysis['md5']
        self.sha1                  = fileanalysis['sha1']
        self.sha256                = fileanalysis['sha256']
        self.ssdeep                = fileanalysis['ssdeep']
        self.mhr                   = cymru_mhr.get_mhr_listing()
        self.is_pe                 = is_pe
        self.pe_compiletime        = pe_compiletime
        self.pe_is_probably_packed = pe_is_probably_packed
        self.pe_sigs               = pe_sigs

    def parse_verbose_info(self):
        # XXX process self._pe for fileinfo.PE object

        # Sections
        pe_num_sections = self._pe.FILE_HEADER.NumberOfSections
        pe_sections = []
        if pe_num_sections > 0:
            for section in self._pe.sections:
                section_info = "%s @%s (%s, %s)" % (section.Name.strip('\x00'), hex(section.VirtualAddress),
                       hex(section.Misc_VirtualSize), section.SizeOfRawData )
                pe_sections.append(section_info)

        # Imports table
        pe_import_data = StringIO()
        print >> pe_import_data, ":: Imports:\n"
        try:
            for entry in self._pe.DIRECTORY_ENTRY_IMPORT:
                print >> pe_import_data, entry.dll
                for imp in entry.imports:
                    print >> pe_import_data, "\t%s %s" % ( hex(imp.address), imp.name )
        except:
            print >> pe_import_data, "No imports."

        # exports table
        pe_export_data = StringIO()
        print >> pe_export_data, ":: Exports:\n"
        try:
            for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
                print >> pe_export_data, "%s %s %s" % (hex(pe.OPTIONAL_HEADER.ImageBase + exp.address), exp.name, exp.ordinal)
        except:
            print >> pe_export_data, "No exports."

        self.pe_num_sections = pe_num_sections
        self.pe_sections     = pe_sections
        self.pe_import_data  = pe_import_data
        self.pe_export_data  = pe_export_data


class MHRChecker(object):
    """
    Query Team Cymru MHR service for file listing.
    Sample listed hash for testing: 733a48a9cb49651d72fe824ca91e8d00

    """
    def __init__(self, hash):
        failstr = '[unavailable]'
        if DNS_MODULE:
            try:
                DNS.ParseResolvConf()
            except IOError:
                errs.append("WARNING: Cannot determine DNS resolvers (required for MHR lookup).")
                self.listing = failstr
            else:
                r = DNS.DnsRequest(qtype='TXT')
                # create query record based on hash
                q = "%s.malware.hash.cymru.com" % hash
                response = r.req(q)

                if len(response.answers) > 0:
                    ans = response.answers[0]['data'][0].split(" ")
                    self.listing = "%s%% (%s)" % (ans[1], time.ctime(int(ans[0])))
                else:
                    self.listing = None
        else:
            self.listing = failstr

    def get_mhr_listing(self):
        return self.listing


def main():
    # parse options
    usage = "usage: %prog [options] file"
    parser = OptionParser(usage)
    parser.add_option("-v", "--verbose", action="count", dest="verbose",
                      help="display warnings and errors; if used more than once, display more details for PE files")
    (options, args) = parser.parse_args()

    for file in args:
        if not os.path.exists(file):
            print >> sys.stderr, "ERROR: specified file does not exist."
            sys.exit(1)

        file_info = FileInfo(file)
        if options.verbose > 1:
            file_info.parse_verbose_info()

        # display output of any errors that have occurred in single block before output
        if len(errs) > 0:
            if options.verbose:
                for e in errs:
                    print >> sys.stderr, ">> %s" % e
                print >> sys.stderr, ""

        # display output
        print "Analysis time:  %s" % file_info.analyzetime
        print "File name:      %s" % file_info.filename
        print "File size:      %s" % file_info.filesize
        print "File type:      %s" % file_info.filetype
        print "CRC32:          %s" % file_info.crc32
        print "MD5 hash:       %s" % file_info.md5
        print "SHA1 hash:      %s" % file_info.sha1
        print "SHA256 hash:    %s" % file_info.sha256
        print "Fuzzy hash:     %s" % file_info.ssdeep
        if file_info.mhr:
            print "Cymru MHR:      %s" % file_info.mhr
        if file_info.is_pe:
            print "PE compiled:    %s" % file_info.pe_compiletime
            print "PE signatures:  %s" % "; ".join(file_info.pe_sigs)
        if file_info.pe_is_probably_packed:
            print "PE file is probably packed"

        # add blank line if processing multiple files
        if len(args) > 1:
            print ""

        # display optional pe data XXX will revisit this once I have a "moar PE details" capability
        #if options.verbose > 1 and PE_MODULE:
        #    show_pe_data(file)

if __name__ == "__main__":
    main()

