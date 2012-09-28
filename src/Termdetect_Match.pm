package Termdetect_Match;

    use strict;
    use warnings;

    use Terminfo_Parser;
    use Termdetect_Tests;

    use Data::Dumper;

    use Exporter 'import';

    our @EXPORT = qw( match_results );

    use constant DEBUG_MATCHES => 1;


# returns the name of the $TERM that best matches
sub match_results {
    my ($test_results,              # the results from running all the tests on the current terminal
        $termmatch_db               # the contents of "termmatch.src"
            ) = @_;

    my $match_stats = calculate_match_statistics($test_results, $termmatch_db);
        #print Dumper $match_stats;

    my $highest_match;
    my $highest_match_numyes = 0;
    while (my ($term, $stats) = each %$match_stats) {
        if (!exists $stats->{n} && $stats->{y} > $highest_match_numyes) {
            $highest_match_numyes = $stats->{y};
            $highest_match = $term;
        }
    }

    return $highest_match;
}



sub calculate_match_statistics {
    my ($test_results,              # the results from running all the tests on the current terminal
        $termmatch_db               # the contents of "termmatch.src"
            ) = @_;

    #print ansi_escape_no_nl(Dumper $test_results);      exit;
    #print ansi_escape_no_nl(Dumper $termmatch_db);      exit;
    
    my %pass_fail_count;

    foreach my $termmatch_entry (values %$termmatch_db) {
        my $termname = $termmatch_entry->{termnames}[0];
        print "========[ $termname ]========\n"         if (DEBUG_MATCHES);
        #while (my ($cap, $test_result) = each %$test_results) {
        foreach my $cap (sort keys %$test_results) {
            my $test_result = $test_results->{$cap};

            printf "\t%-20s  ", $cap            if (DEBUG_MATCHES);
            $pass_fail_count{$termname}{total}++;
            if (exists $termmatch_entry->{fields}{$cap}) {
                my $yn = match_one_field($test_result, $termmatch_entry->{fields}{$cap});
                if ($yn) {
                    print "match\n"         if (DEBUG_MATCHES);
                } else {
                    printf "MISMATCH -- got: %-25s  wanted: %s\n",
                            quote(summarize_result($test_result)), 
                            quote(ansi_escape($termmatch_entry->{fields}{$cap}{assign}))
                                if (DEBUG_MATCHES);
                }
                $pass_fail_count{$termname}{$yn ? 'y' : 'n'} ++;
            } else {
                print "NOT PRESENT -- got: ", quote(summarize_result($test_result)), "\n"
                        if (DEBUG_MATCHES);
                $pass_fail_count{$termname}{u} ++;      # "U" = unspecified
            }
        }
        print "\n"          if (DEBUG_MATCHES);
    }
    return \%pass_fail_count;
}

        # returns the input, but surrounded in quotes
        sub quote {
            return '"' . join("", @_) . '"';
        }


# Match one test-result against a capability in one termmatch entry.
# Returns true/false, regarding whether it matched.
sub match_one_field {
    my ($test_result, $entry_cap) = @_;

    #print ansi_escape_no_nl(Dumper $entry_cap); exit;

    if (exists $entry_cap->{assign}) {
        if ($entry_cap->{assign} !~ /\%/) {
            return ($test_result->{received} eq $entry_cap->{assign});
        } elsif ($entry_cap->{assign} =~ /^\%x\+(\d)$/) {
            return (exists $test_result->{x_delta} && $test_result->{x_delta} == $1);
        } else {
            my @f = split /(\%[\*\+\%])/, $entry_cap->{assign};
            my $pat = '';
            foreach my $f (@f) {
                if ($f eq '%*') {
                    $pat .= ".*";
                } elsif ($f eq '%+') {
                    $pat .= ".+";
                } elsif ($f eq '%%') {
                    $pat .= '%';            # just the character '%'
                } else {
                    $pat .= quotemeta($f);
                }
            }
            if ($pat =~ /\%/) {
                print "oops\n";
                print ansi_escape_no_nl(Dumper $entry_cap);
                exit;
            }
            return ($test_result->{received} =~ /^$pat$/);
        }
    }
}







1;

# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
