# This performs tests on the terminal, to try to determine what character-encoding the terminal
# is set to.


package Termdetect_Encoding;

    use strict;
    use warnings;

    use Termdetect_Tests  qw( read_phase  run_test  output );
    use bytes qw();

    use Data::Dumper;

    use Exporter 'import';
    our @EXPORT = qw( do_encoding_tests );

    # I shouldn't have to do this....  Exporter's job is to import these for me.
    # I'm doing something wrong somewhere...?
    sub read_phase(&) {Termdetect_Tests::read_phase(@_)}
    *run_test = \&Termdetect_Tests::run_test;
    *output   = \&Termdetect_Tests::output;



# TODO: We need to determine what the canonical names for these should be.
#       Our main intention is for filling out the $LANG locale variable, however, 
#       the "The Open Group Base Specifications Issue 6" says:
#               "settings of language, territory, and codeset are implementation-defined"
#
#       For now, we're using the encoding name found on linux  (run `locale -a` or `locale -m`)


# each test consists of:
#       - one or more octets that we will send to the terminal
#       - the expected X movement of the cursor in response to these octets
#       - the expected Y movement of the cursor in response to these octets
our %encoding_tests = (

    'utf8' => {
        # in case there are any font-support issues, (I think I've seen cases where missing glyphs
        # resulted in the character being rendered as [2, 0]) the codepoints that have named HTML
        # entities are somewhat more likely to be supported by most fonts?
        #       http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references#Character_entity_references_in_HTML

        'C2 A9'         => [1, 0],      # copyright symbol
        'C3 86'         => [1, 0],      # AE ligature
        'E2 80 94'      => [1, 0],      # em-dash
        'E2 99 A3'      => [1, 0],      # clubs symbol
    },

    'gb2312' => {
        'A1 A1'         => [2, 0],      # ideographic space
        'A1 DE'         => [1, 0],      # infinity symbol
        'A1 EA'         => [2, 0],      # fullwidth pound sign
        'A1 FE'         => [2, 0],      # geta mark
        'A1 EA'         => [2, 0],      # fullwidth pound sign
        'A2 C6'         => [1, 0],      # parenthesized digit two
        'A2 DA'         => [1, 0],      # circled digit two
        'A6 C8'         => [1, 0],      # theta
    },

    'shift_jis' => {
        '81 83'         => [2, 0],      # fullwidth less-than sign
        '81 E1'         => [1, 0],      # much less-than
        '81 CE'         => [1, 0],      # there exists
        '81 BE'         => [1, 0],      # union
        '81 BF'         => [1, 0],      # intersection
        '82 81'         => [2, 0],      # fullwidth latin small letter A
    }

);


sub do_encoding_tests {
    my $all_results = shift;

    my %encoding_results;

    # Do a union set-operation on all tests.  We will run all tests, regardless of which encoding
    # they're attached to.
    my @encoding_tests = uniq(map {keys %$_} values %encoding_tests);
        #print Dumper \@encoding_tests; exit;

    my %still_matching = map {$_ => 1}
                             keys %encoding_tests;
    foreach my $encoding_test (@encoding_tests) {
        my $bytes = join "",
                    map {bytes::chr(hex($_))}
                        split ' ', $encoding_test;
        output("\r");
        run_test($bytes,
                 sub {
                    my ($test_result) = @_;
                    process_encoding_results($encoding_test, $test_result, \%still_matching);
                 });
                
    }

    read_phase {
        # record the final conclusion of the encoding tests
        if (scalar(keys(%still_matching)) == 1) {
            ($all_results->{s_encoding}{received}) = keys %still_matching;
        }
    };
}


sub process_encoding_results {
    my ($encoding_test, $test_result, $still_matching) = @_;

    foreach my $encoding (keys %$still_matching) {
        next unless exists $encoding_tests{$encoding}{$encoding_test};
        my $expected = $encoding_tests{$encoding}{$encoding_test};

        # for newlines, we only care about delta-Y, we ignore delta-X
        if ($expected->[1] && $expected->[1] != ($test_result->{y_delta} || 0)
                || $expected->[0] != ($test_result->{x_delta} || 0))
        {
            delete $still_matching->{$encoding};

            if (0) {                # set this to '1' to do the equivalent of --check for encodings
                my $result = sprintf "(%d, %d)",
                                     $test_result->{x_delta} || 0,
                                     $test_result->{y_delta} || 0;
                print "FAILED MATCH on encoding=$encoding and test='$encoding_test'.  Result was: $result\n\n\n";
            }
        }
    }
}



# removes duplicate elements from a list
sub uniq {
    my %seen;
    grep { !$seen{$_}++ }
         @_
}


#use Encode;
#sub xxd {Encode::_utf8_off(my$str=shift);open my$xxd,'|-','xxd'or die$!;print$xxd $str;close$xxd}    


1;


# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
