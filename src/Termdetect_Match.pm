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
        $die_if_not_one,            # should we error out when there are more than one matches, or
                                    #           zero matches?   (optional param, defaults to yes)
            ) = @_;

    $die_if_not_one = 1        if (!defined($die_if_not_one));

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

    #show_match_percentages($match_stats, 3);       exit;

    if (@no_mismatches > 1) {
        if ($die_if_not_one) {
            print STDERR "Error: Multiple terminals matched: ",
                        join(", ", @no_mismatches), "\n";
            print STDERR "\n\nIt would help out greatly if you could submit data about this.\n";
            print STDERR "See       termdetect --help-submit\n";
            exit 1;
        } else {
            print STDERR "Error: Multiple terminals matched: ",
                        join(", ", @no_mismatches), "\n\n";
        }
    } elsif (@no_mismatches == 0) {
        if ($die_if_not_one) {
            print STDERR "Error: No terminals matched exactly.  Terminals that were close:\n";
            my $closest_match = show_match_percentages($match_stats, 5);
            print STDERR "\nRun this for more info:\n    $0 --check=$closest_match\n";
            print STDERR "\n\nIt would help out greatly if you could submit data about this.\n";
            print STDERR "See       termdetect --help-submit\n";
            exit 1;
        }
    } elsif (@no_mismatches == 1) {
        Termdetect_Tests::calculate_derived_values_after_match($test_results, $termmatch_db, $highest_match);
    }

    return $highest_match;
}


# show the list of terminals, ordered by match percentage
sub show_match_percentages {
    my ($match_stats, $limit_to) = @_;
            # $limit_to -- the number of items to display;   undef for unlimited

    my @match_percentage;       # list all terminals, sorted in order of match percentage
    foreach my $stats (values %$match_stats) {
        next unless ($stats->{total});          # we need a non-zero denominator
        $stats->{percentage} = int(100 * ($stats->{y} || 0) / $stats->{total});
    }
    @match_percentage = sort { $match_stats->{$b}{percentage} <=> $match_stats->{$a}{percentage} }
                             keys %$match_stats;
        #print Dumper \@match_percentage;    exit;

    my $ctr = 0;
    foreach my $term (@match_percentage) {
        printf STDERR "    %-15s  %3d%% match\n",
                      $term,
                      $match_stats->{$term}{percentage};
        $ctr++;
        last if (defined($limit_to) && $ctr >= $limit_to);
    }

    # return the terminal with the closest match
    return $match_percentage[0];
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

    if (exists $entry_cap->{assign} && exists $test_result->{received}) {
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
