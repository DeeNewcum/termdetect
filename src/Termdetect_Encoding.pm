# This tests the character-encoding of the terminal.

package Termdetect_Encoding;

    use strict;
    use warnings;

    use Termdetect_Tests  qw( read_phase  /./  );

    use Data::Dumper;

    use Exporter 'import';
    our @EXPORT = qw( do_encoding_tests );

    # prototypes
    sub read_phase(&) {Termdetect_Tests::read_phase(@_)}



our %encoding_tests = (
);

sub do_encoding_tests {
    our $all_results = shift;

    read_phase {
        $all_results->{s_encoding}{received} = "yourmom";
    };
}



1;


# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
