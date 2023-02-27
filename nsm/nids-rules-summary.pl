#!/usr/bin/env perl
#
# Author: Darren Spruell <phatbuckett@gmail.com>

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $help;
my $scriptname = basename($0);

my $result = GetOptions( "h" => \$help );

show_help() if $help;

while (<>) {
    if (/msg:"(?<message>[^"]+)".*sid:(?<sid>\d+);/) {
        print "1:$+{sid} $+{message}\n";
    }
}

sub show_help {
    my $helptxt = <<"EOF";
Summarize input set of NIDS rules and output simplified listing of the rule
SID and message. Works from input as file parameter or stdin.

USAGE: $scriptname <file>
EOF
    print $helptxt;
    exit(0);
}

