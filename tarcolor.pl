#!/usr/bin/perl -w

# tarcolor
#
# by Marc Abramowitz <marc at marc-abramowitz dot com>
#
# https://github.com/msabramo/tarcolor
#
# Colors output of `tar tvf` or `ls -l` similarly to the way GNU ls (in GNU
# coreutils) would color a directory listing.
#
# Colors can be customized using an environment variable:
#
# TAR_COLORS='di=01;34:ln=01;36:ex=01;32:so=01;40:pi=01;40:bd=40;33:cd=40;33:su=0;41:sg=0;46'
#
# The format for TAR_COLORS is similar to the format used by LS_COLORS
# Check out the online LSCOLORS generator at http://geoff.greer.fm/lscolors/

use warnings;
use strict;

my $RESET = "\033[0m";


sub get_file_type {
    if (substr($_, 0, 1) eq 'l') {
        return 'ln';
    } elsif (substr($_, 0, 1) eq 'd') {
        return 'di';
    } elsif (substr($_, 0, 1) eq 's') {
        return 'so';
    } elsif (substr($_, 3, 1) eq 'S') {
        return 'su';
    } elsif (substr($_, 6, 1) eq 'S') {
        return 'sg';
    } elsif (substr($_, 0, 1) eq 'p') {
        return 'pi';
    } elsif (substr($_, 0, 1) eq 'c') {
        return 'cd';
    } elsif (substr($_, 0, 1) eq 'b') {
        return 'bd';
    } elsif (substr($_, 0, 1) eq 'D') {
        return 'do';
    } elsif (substr($_, 3, 1) eq 'x') {
        return 'ex';
    }
}

sub color_filename {
    my ($color) = @_;

    s
    {
        (\d+)                        # size
        ([-\s]+)
        (\w+)                        #
        ([-\s]+)
        (\d{1,2})                    # day (dd) in date
        (\s+)
        (
            (?:\d{2}:\d{2}) |        # time
            (?:\d{4})                # year
        )                            # $1 = time | year
        (\s+)                        # $2 = space
        (.+?)                        # $3 = filename
        (\s->|$)                     # $4 = " ->" or end of string
    }
    {$1$2$3$4$5$6$7$8${color}$9${RESET}$10}x;
}


my %FILE_TYPE_TO_COLOR = (
    "di" => "\033[01;34m",
    "ln" => "\033[01;36m",
    "ex" => "\033[01;32m",
    "so" => "\033[01;35m",
    "pi" => "\033[40;33m",
    "bd" => "\033[40;33;01m",
    "cd" => "\033[40;33;01m",
    "su" => "\033[37;41m",
    "sg" => "\033[30;43m",
);

foreach (split(':', $ENV{'TAR_COLORS'} || '')) {
    my ($type, $codes) = split('=');
    $FILE_TYPE_TO_COLOR{$type} = "\033[" . $codes . "m";
}

while (<>) {
    my $type = get_file_type();

    if ($type) {
        color_filename($FILE_TYPE_TO_COLOR{$type});
    }

    print;
}
