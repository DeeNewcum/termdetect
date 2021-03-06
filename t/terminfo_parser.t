#!/usr/bin/perl

# unit tests for Terminfo_Parser.pm

    use strict;
    use warnings;

    use Cwd 'abs_path';
    use File::Basename;
    use lib ($FindBin::Bin = dirname( abs_path $0 )) . "/../src";

    use Terminfo_Parser;

    use Test::More;
    use Data::Dumper;

    use constant VERBOSE => 0;          # show verbose debugging info


my $debug = \*STDOUT;
open $debug, '>', '/dev/null'       unless VERBOSE;

chdir($FindBin::Bin);


my @terminfo_files = (
        "terminfo.ncurses",         # http://invisible-island.net/ncurses/ncurses.faq.html#which_terminfo
        "terminfo.ESR",             # http://www.catb.org/~esr/terminfo/
        );

Test::More::plan(tests => scalar(@terminfo_files));
foreach my $terminfo_filename (@terminfo_files) {
    our %num_dependencies;

    my $terminfo_contents = slurp($terminfo_filename);
    my $parsed = Terminfo_Parser::_parse_terminfo($terminfo_contents);
    #print dump_terminal(@$parsed); exit;
    $parsed = Terminfo_Parser::flatten_terminfo($parsed);
    #print Dumper $parsed; exit;
    #print dump_terminal(values %$parsed); exit;
    unittest__prepare_TERMINFO($terminfo_filename);
    ok(!unittest_terminfo($parsed), $terminfo_filename);
}


# point $ENV{TERMINFO} to the right place
#       (and compile the terminfo file if necessary)
sub unittest__prepare_TERMINFO {
    my ($terminfo_filename) = @_;

    my $terminfo_dir = "$ENV{HOME}/.terminfo.$terminfo_filename/";
    if (!-d $terminfo_dir) {
        system "tic", "-o$terminfo_dir", $terminfo_filename;
        $? == -1    and die "unable to run 'tic'\n";
    }

    $ENV{TERMINFO} = $terminfo_dir;
}


# a unit test to confirm our parser matches tic(1)'s parser
sub unittest_terminfo {
    my ($parsed) = @_;

    if (ref($parsed) eq 'HASH') {
        $parsed = [ values %$parsed ];
    }

    my $num_errors = 0;

    eval 'use Term::Terminfo';
    $@ and die "\nERROR: the unit test requires Term::Terminfo to be installed\n" .
                "(before doing that, you'll want to   apt-get install libncurses-dev)\n\t";

    foreach my $entry (sort {$a->{termnames}[0] cmp $b->{termnames}[0]} @$parsed) {
        next if ($entry->{alias});
        next if ($entry->{fields}{hc});     # Term::Terminfo doesn't like hardcopy entries
        next if ($entry->{fields}{gn});     # Term::Terminfo doesn't like generic entries


        print $debug "================[ ", join(" -- ", @{$entry->{termnames}}, $entry->{term_descr} || ''),
                    " ]================\n";
    
        #print "dependencies:  $num_dependencies{$entry->{termnames}[0]}\n";
        #next if ($num_dependencies{$entry->{termnames}[0]} > 3);

        my $terminfo = Term::Terminfo->new($entry->{termnames}[0]);

        my %supported_caps = map {$_ => 1}
                $terminfo->flag_capnames(),
                $terminfo->num_capnames(),
                $terminfo->str_capnames();

        my $fields = [ sort { dump_sort_fields() } values %{$entry->{fields}} ];
        foreach my $field (@$fields) {
            my $cap = $field->{capability};

            do {        # modified version of dump_field($field)
                printf $debug "%20s", $field->{capability};
                if ($field->{assign}) {
                    print $debug " = ", qquote($field->{assign});
                } elsif ($field->{num}) {
                    print $debug " # ", qquote($field->{num});
                }
            };

            if (!exists $supported_caps{$cap}) {
                print $debug " "x40, "unsupported\n";
                next;
            } elsif ($field->{assign}) {
                my $actual = $terminfo->getstr($cap) || '';
                if ($actual ne $field->{assign}) {
                    print $debug "\t\tERROR\n";
                    print $debug "%-20s   %s\n", "", qquote($actual);
                    $num_errors++;
                }
            } elsif ($field->{num}) {
                if ($cap eq 'lines' || $cap eq 'cols') {
                    print $debug "\n";
                    next;
                }
                my $actual = $terminfo->getnum($cap) || '';
                if ($actual <=> $field->{num}) {
                    print $debug "\t\tERROR\n";
                    printf $debug "%-20s   %s\n", "", qquote($actual);
                    $num_errors++;
                }
            }
            print $debug "\n";
        }

        foreach my $nothere ($terminfo->flag_capnames()) {
            next if ($entry->{fields}{$nothere});
            if ($terminfo->getflag($nothere)) {
                printf $debug "%20s   false       ERROR -- tic(1) reports true\n", $nothere;
                $num_errors++;
            }
        }
        foreach my $nothere ($terminfo->num_capnames()) {
            next if ($entry->{fields}{$nothere});
            next if ($nothere eq 'cols' || $nothere eq 'lines');
            if (defined(my $actual = $terminfo->getnum($nothere))) {
                printf $debug "%20s # undef       ERROR -- tic(1) reports $actual\n", $nothere;
                $num_errors++;
            }
        }
        foreach my $nothere ($terminfo->str_capnames()) {
            next if ($entry->{fields}{$nothere});
            if (defined(my $actual = $terminfo->getstr($nothere))) {
                printf $debug "%20s = undef       ERROR -- tic(1) reports %s\n",
                        $nothere,
                        qquote($actual);
                $num_errors++;
            }
        }

        print $debug "\n";
    }

    # report the final status of the testing
    if ($num_errors) {
        print $debug "Total number of errors: $num_errors\n";
    } else {
        print $debug "No errors!  All tests passed.\n"
    }

    return $num_errors;
}


sub dump_terminal {
    my @terms = sort {$a->{termnames}[0] cmp $b->{termnames}[0]} @_;
    my $return = '';
    foreach my $terminal (@terms) {
        $return .= "================[ " . join(" -- ", @{$terminal->{termnames}}, $terminal->{term_descr} || '') .
                    " ]================\n";
        if ($terminal->{alias}) {
            #printf $debug "%20s   %s\n\n", "alias of", $terminal->{alias};
            next;
        }

        my $fields = $terminal->{fields};
        if (ref($fields) eq 'HASH') {
            $fields = [ sort { dump_sort_fields() } values %$fields ];
        }
        $return .= dump_field(@$fields);
        $return .= "\n";
    }
    return $return;
}


sub dump_field {
    my $return = '';
    foreach my $field (@_) {
        next if (!defined($field));
        $return .= sprintf "%20s", $field->{capability};
        if ($field->{assign}) {
            $return .= " = " . qquote($field->{assign}) . "\n";
        } elsif ($field->{num}) {
            $return .= " # " . qquote($field->{num}) . "\n";
        } elsif ($field->{deleted}) {
            $return .= " XXXXXXXXXXX deleted\n";
        } else {
            $return .= "\n";
        }
    }
    return $return;
}


sub dump_sort_fields {
                        field_type($a) cmp field_type($b) ||
                        $a->{capability} cmp $b->{capability}
}


sub field_type {
    my ($field) = @_;
    return "3assign" if ($field->{assign});
    return "2num" if ($field->{num});
    return "1bool";
}


sub qquote {my$q=Data::Dumper::qquote($_[0]);$q=~s/^"(.*)"$/$1/s;$q}
sub _quote {my$q=Data::Dumper::_quote($_[0]);$q=~s/^'(.*)'$/$1/s;$q}


# indent all lines with the same character sequence
#           (even when there are multiple lines in the same scalar)
sub indent {my$i=shift;map {(my$a=$_) =~ s/^/$i/m;$a} @_}

# quickly read a whole file
sub slurp {my$p=open(my$f,"$_[0]")or die$!;my@o=<$f>;close$f;waitpid($p,0);wantarray?@o:join("",@o)}


# run a scalar through an external filter, and capture the results
# first arg is a list-ref that specifies the filter-command
use autodie;
sub filter_thru {my$pid=open my$fout,'-|'or do{my$pid=open my$fin,'|-',@{shift()};print$fin @_;close$fin;waitpid$pid,0;exit;};
                 my@o=<$fout>;close$fout;waitpid$pid,0;wantarray?@o:join'',@o}

sub xxd {filter_thru(['xxd'],@_)}

# display a string to the user, via 'less'
sub less {my$pid=open my$less,"|less";print$less @_;close$less;waitpid$pid,0}



# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
