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
        $termmatch_db,              # the contents of "termmatch.src"
        $die_on_multiple,           # should error out when there are multiple matches?
                                    #           (optional param, defaults to yes)
            ) = @_;

    $die_on_multiple = 1        if (!defined($die_on_multiple));

    my $match_stats = calculate_match_statistics($test_results, $termmatch_db);
        #print Dumper $match_stats;


    my @no_mismatches;      # list of all terminals that had zero mismatches, and at least one match
    my $highest_match;
    my $highest_match_numyes = 0;
    while (my ($term, $stats) = each %$match_stats) {
        if (!exists $stats->{n} && defined($stats->{y})) {
            push @no_mismatches, $term;
            if ($stats->{y} > $highest_match_numyes) {
                $highest_match_numyes = $stats->{y};
                $highest_match = $term;
            }
        }
    }

    if (@no_mismatches > 1) {
        if ($die_on_multiple) {
            print STDERR "Error: Multiple terminals matched: ",
                        join(", ", @no_mismatches), "\n";
            print STDERR "\n\nPlease file a bug for this at https://github.com/DeeNewcum/termdetect/issues\n";
            print STDERR "and include the output of   termdetect --dump\n";
            exit 1;
        } else {
            print STDERR "Error: Multiple terminals matched: ",
                        join(", ", @no_mismatches), "\n\n";
        }
    } elsif (@no_mismatches == 1) {
        Termdetect_Tests::calculate_derived_values_after_match($test_results, $termmatch_db, $highest_match);
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

        next if (exists $termmatch_entry->{alias});     # skip aliases, we'll only process canonical names

        my $check_this = (exists $::ARGV{check} &&
                ($::ARGV{check} eq '1' || $::ARGV{check} eq $termname));

        print "========[ $termname ]========\n"         if $check_this;
        #while (my ($cap, $test_result) = each %$test_results) {
        foreach my $cap (sort keys %$test_results) {
            my $test_result = $test_results->{$cap};

            next if ($cap =~ /^c_/);
            next if ($Termdetect_Tests::rarely_tested_synthetics{$cap} &&
                        !exists $termmatch_entry->{fields}{$cap});
            
            printf "\t%-20s  ", $cap            if $check_this;
            $pass_fail_count{$termname}{total}++;
            if (exists $termmatch_entry->{fields}{$cap}) {
                my $yn = match_one_field($test_result, $termmatch_entry->{fields}{$cap});
                if ($yn) {
                    print "match\n"         if $check_this;
                } else {
                    printf "MISMATCH -- got: %-25s  wanted: %s\n",
                            quote(summarize_result($test_result)), 
                            quote(ansi_escape($termmatch_entry->{fields}{$cap}{assign}))
                                if $check_this;
                }
                $pass_fail_count{$termname}{$yn ? 'y' : 'n'} ++;
            } else {
                print "NOT PRESENT -- got: ", quote(summarize_result($test_result)), "\n"
                        if $check_this;
                $pass_fail_count{$termname}{u} ++;      # "U" = unspecified
            }
        }
        print "\n"          if $check_this;
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
        } else {
            my @f = split /(\%[xy][-+]\d|\%[^xy])/, $entry_cap->{assign};
            my $pat = '';
            my ($pat_x_delta, $pat_y_delta);
            foreach my $f (@f) {
                if ($f eq '%*') {
                    $pat .= ".*";
                } elsif ($f eq '%+') {
                    $pat .= ".+";
                } elsif ($f eq '%%') {
                    $pat .= '%';                # just the character '%'
                } elsif ($f =~ /^\%([xy])([-+]\d)$/) {
                    if ($1 eq 'x') {
                        $pat_x_delta = int($2);
                    } elsif ($1 eq 'y') {
                        $pat_y_delta = int($2);
                    }
                } elsif ($f =~ /^\%(.)$/) {
                    $pat .= quotemeta($1);      # an unsupported percent-char
                } else {
                    $pat .= quotemeta($f);
                }
            }
            # both the delta-x and delta-y MUST be acknowledged, or it isn't a match
            return 0     unless (($pat_x_delta || 0) == ($test_result->{x_delta} || 0)
                             &&  ($pat_y_delta || 0) == ($test_result->{y_delta} || 0));
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
