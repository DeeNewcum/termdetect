# A Perl implemntation of a terminfo source parser.
#
# See the unit tests in parser/parser_unit_test -- we tested this somewhat well against the
# original tic(1) parser.


package Terminfo_Parser;

    use strict;
    use warnings;

    use Exporter 'import';

    our @EXPORT = qw( parse_terminfo ti_dump_terminal );


# terminfo(5) says of terminfo's syntax:
#
#      Entries  in  terminfo  consist  of  a  sequence of "," separated fields
#      (embedded commas may be escaped with a backslash or notated  as  \054).
#      White  space  after  the "," separator is ignored.  The first entry for
#      each terminal gives the names which are known for the  terminal,  sepa-
#      rated  by  "|"  characters.   The  first  name given is the most common
#      abbreviation for the terminal, the last name given  should  be  a  long
#      name  fully  identifying the terminal, and all others are understood as
#      synonyms for the terminal name.  All names but the last  should  be  in
#      lower  case and contain no blanks; the last name may well contain upper
#      case and blanks for readability.
#
#      A  number  of  escape  sequences   are  provided  in  the  string valued
#      capabilities for easy encoding of characters there.  Both \E and \e map
#      to  an  ESCAPE character, ^x maps to a control-x for any appropriate x,
#      and the sequences \n \l \r \t \b  \f  \s  give  a  newline,  line-feed,
#      return, tab, backspace, form-feed, and space.  Other escapes include \^
#      for ^, \\ for \, \, for comma, \: for :, and \0  for  null.   (\0  will
#      produce  \200,  which does not terminate a string but behaves as a null
#      character on most terminals, providing CS7 is specified.  See stty(1).)
#      Finally, characters may be given as three octal digits after a \.

#      ...
#
#      Sometimes  individual  capabilities must be commented out.  To do this,
#      put a period before the capability name.  For example, see  the  second
#      ind in the example above.

#      ...
#
#      Numeric  capabilities are followed by the character "#" and then a
#      positive value.

#      ...
#
#      String valued capabilities, such as el (clear to end of line sequence)
#      are given by the two-character code, an "=", and then a string ending
#      at the next following ",".
#       
#      ...
#
#      The % encodings have the following meanings:
#               (read terminfo(5) for full info about % encodings)
#
# The Single UNIX Specification further says:
#
#      Each description consists of a header (beginning in column 1) and one
#      or more lines that list the features for that particular device. Every
#      line in a terminfo source file must end in a comma. Every line in a
#      terminfo source file except the header must be indented with one or
#      more white spaces (either spaces or tabs).
#
#      Entries in terminfo source files consist of a number of
#      comma-separated fields. White space after each comma is ignored. 
#

sub parse_terminfo  {
    my ($lines) = @_;
    return flatten_terminfo(_parse_terminfo($lines));
}


sub _parse_terminfo  {
    my ($lines) = @_;

    my @parsed;

    my @lines = split /\n/, $lines;
    our @process_fields;
    for (our $lineno=0; $lineno<@lines; $lineno++) {
        our %field = (lineno => $lineno);
        our @fields = ();
        our $is_continuation;
        $lines[$lineno] =~ m{
              ^ \# .*           # ignore comment lines
            | ^ \s* $           # ignore blank lines
            | ^( \s* )
                                    (?{ $is_continuation = length $^N    })
                (?:
                    (?! \s )
                    ((?:  \\\d\d\d  |  [\\^][^\n]  |  [^,\\^\n=\#]  )+)
                       #  ^^^^^^^^     ^^^^^^^^     ^^^^^^^^^^^    various escape codes
                                    (?{ local $field{capability} = $^N   })
                    (?:     = ((?:  \\\d\d\d  |  [\\^][^\n]  |  [^,\\^\n]  )*)
                              ## same as above, but with [=\#] removed, and + changed to *
                                    (?{ local $field{assign} = $^N    })
                         | \# (\d+)
                                    (?{ local $field{num} = $^N    })
                         )?
                    , \s*  
                                    (?{ push(@fields, {%field})   })
                )+ $
        }x
            or die "syntax error on line " . ($lineno+1) . "\n\t$lines[$lineno]\n";

        if (defined($is_continuation)) {
            if ($is_continuation) {
                push(@process_fields, @fields);
            } else {
                push(@parsed, process_fields(@process_fields)) if (@process_fields);
                @process_fields = (@fields);
            }
        }
    }
    push(@parsed, process_fields(@process_fields)) if (@process_fields);

    return \@parsed;
}


sub process_fields {
    my @fields = @_;

    my $termfield = shift @fields;

    my @termnames = split /\|/, $termfield->{capability};
    my $descr = pop @termnames      if (@termnames >= 2);
    my %parsed = (
        termnames      => \@termnames,
        term_descr     => $descr,
        lineno_range   => [         # range of line numbers that this entry occupies
                $termfield->{lineno},       # first line
                $fields[-1]{lineno},        # last line
            ],
        );

    $parsed{fields} = [
            map {
                $_->{assign} = terminfo_unescape($_->{assign})      if $_->{assign};
                $_
            } @fields
        ];

    return \%parsed;
}


BEGIN {
    our %escapes = (

        "\\a"  => "\x07",   # bell
        "\\b"  => "\x08",   # backspace
        "\\f"  => "\x0c",   # form feed
        "\\e"  => "\e",     # escape
        "\\l"  => "\x0a",   # line feed
        "\\n"  => "\x0a",   # newline
        "\\r"  => "\x0d",   # return
        "\\s"  => " ",      # space
        "\\t"  => "\t",     # horizontal tab
        "\\0"  => "\200",   # null   (see detailed info about this in terminfo(5)...   it's not clear to me why we use \200 instead of \x00)

        "^\\"  => "\x1c",
        "^]"   => "\x1d",
        "^^"   => "\x1e",
        "^_"   => "\x1f",

        # plain escapes
        "\\,"  => ",",
        "\\:"  => ":",
        "\\\\" => "\\",
        "\\^"  => "^",
    );
    for ('a'..'z') {
        $escapes{"^$_"} = chr(ord($_) - 96);
    }
    #print Dumper \%escapes; exit;


# The output of this should EXACTLY match tigetstr(3).
# That is -- the percent parameters haven't been expanded (it doesn't do what tparm() does), but
# all other escape-codes should be expanded.
sub terminfo_unescape {
    local $_ = shift;

    s/
        \\(\d\d\d)    |
        (\%)(?=\\)    |         # i have no clue what the fuck this is...  but this is required to match the official parser's behavior
        ([\\^].)      |
        \%{(\d\d+)}   |
        \%'([^']+)'   |
        (%'[^']+'|%.)
    /
            defined($1) ? chr(oct($1))
          : defined($2) ? $2
          : defined($3) ? ($escapes{lc $3} || substr($3, -1))
          : defined($4) ? unescape_percent_char($4)
          : defined($5) ? ("%'" . terminfo_unescape($5) . "'")
          : defined($6) ? $6 : "YOUBROKEIT"
        /gex;
    return $_;
}
}

    sub unescape_percent_char {
        my $charnum = shift;
        if ($charnum >= 32 && $charnum <= 126 && $charnum != 92) {
            return "\%'" . chr($charnum) . "'";
        } else {
            return "\%{$charnum}";
        }
    }


# The terminfo specification allows for use= clauses (and @ items to cancel things inside uses).
# This takes the parsed fields that contain use= clauses, and flattens everything out so you don't
# have to do a lot of work to find out what the final values for a given $TERM are.
sub flatten_terminfo {
    my ($parsed) = @_;

    ## gather up all aliases
    my %canonical_name;     # mapping from   canonical_name => entry_structure
    my %all_term_names;     # mapping from   alias => canonical_name
    foreach my $entry (@$parsed) {
        my $canonical = $entry->{termnames}[0];

        $canonical_name{$canonical} = $entry;
        foreach my $termname (@{$entry->{termnames}}) {
            $all_term_names{$termname} = $canonical;
        }
    }

    ## gather up all "use" entries
    my %first_level_uses;
    foreach my $entry (@$parsed) {
        my $canonical = $entry->{termnames}[0];
        foreach my $field (@{$entry->{fields}}) {
            if ($field->{capability} eq 'use') {
                push @{$first_level_uses{$canonical}}, $field->{assign};
            }
        }
    }

    ## now, merge all the capabilities in the proper precedence order
    my %flattened;
    foreach my $canonical (keys %canonical_name) {
        # recursively explore the tree
        my $merged = merge_tree($canonical,
                                {},
                                \%canonical_name,
                                \%all_term_names,
                                \%first_level_uses,
                                $canonical);

        # actually delete all entries that are explicitely marked "deleted"
        while (my ($cap, $field) = each %$merged) {
            delete $merged->{$cap} if (!defined($field));
        }

        $flattened{$canonical} = {
            %{$canonical_name{$canonical}},
            fields => $merged,
        };
    }
    #return \%flattened;
                
    ## add aliases
    while (my ($alias, $canonical) = each %all_term_names) {
        if (!exists $flattened{$alias}) {
            $flattened{$alias} = {
                alias => $canonical,
                termnames => [$alias],      # $flattened{$canonical}{termnames},
            };
        }
    }

    return \%flattened;
}



# recursively explore the tree, merging the fields for a specific entry
#       %$terms_seen gets built from top-down
#       %$merged gets built from bottom-up
sub merge_tree {
    my ($term,                  # the specific terminal to return the list of merged fields for
        $terms_seen,            # all terminals seen so far, when exploring the tree
                                #           (note: this lists ONLY the parent nodes, in direct
                                #           lineage...  it does NOT list siblings of parents)
        @passthru) = @_;

    my ($canonical_name,        # mapping from   canonical_name => entry_structure
        $all_term_names,        # mapping from   alias => canonical_name
        $first_level_uses,      # mapping from   canonical_name => ordered list of "use" entries for this level ONLY
        $orig_term,             # the $term from the first-level call to this
        ) = @passthru;

    #$num_dependencies{$orig_term}++;

    # according to terminfo(5):
    #           "The capabilities given before use override those in the base type named by use.
    #           If there are multiple use capabilities, they are merged in reverse order.
    #           That is, the rightmost use reference is processed first, then the one to its
    #           left, and so forth.  Capabilities given explicitly in the entry override
    #           those brought in by use references."
    my $merged = {};
    my %terms_seen = (%$terms_seen, $term => 1);
    foreach my $use (reverse @{$first_level_uses->{$term} || []}) {
        $use = $all_term_names->{$use};         # canonicalize
        next if ($terms_seen{$use});            # avoid infinite loops
        my $subtree = merge_tree($use, \%terms_seen, @passthru);          # recursion step -- call ourselves
        $merged = merge_fields($merged, $subtree);
    }
    $merged = merge_fields($merged, 
                     field__list_to_hash(  $canonical_name->{$term}{fields}  ));

    return $merged;
}


# merge two sets of fields, with the "$a" one taking precedent over "$b"
sub merge_fields {
    my $a = field__list_to_hash(shift);
    my $b = field__list_to_hash(shift);

    my %merged = %$a;

    while (my ($cap, $field) = each %$b) {
        if ($cap eq 'use') {
            next;       # we're handling the hierarchy elsewhere
        } elsif ($cap =~ s/\@$//) {
            delete $merged{$cap};
        } else {
            $merged{$cap} = $field;
        }
    }
    return \%merged;
}

        # convert a list-ref of fields into a hash-ref of fields
        #       (or, if already a hash-ref...  just return it untouched)
        sub field__list_to_hash {
            my ($field_list) = @_;
            return $field_list  if ref($field_list) eq 'HASH';
            return {
                    map {$_->{capability} => $_}
                        @$field_list
                   };
        }




#############################################################################
##############[ debugging only ]#############################################
#############################################################################



sub ti_dump_terminal {
    my @terms = sort {$a->{termnames}[0] cmp $b->{termnames}[0]} @_;
    my $return = '';
    foreach my $terminal (@terms) {
        $return .= "================[ " . join(" -- ", @{$terminal->{termnames}}, $terminal->{term_descr} || '') .
                    " ]================\n";
        if (exists $terminal->{alias}) {
            $return .= sprintf "%20s   %s\n\n", "alias of", $terminal->{alias};
            next;
        }

        my $fields = $terminal->{fields};
        if (ref($fields) eq 'HASH') {
            $fields = [ sort { ti_dump_sort_fields() } values %$fields ];
        }
        $return .= ti_dump_field(@$fields);
        $return .= "\n";
    }
    return $return;
}


sub ti_dump_field {
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


sub ti_dump_sort_fields {
                        ti_field_type($a) cmp ti_field_type($b) ||
                        $a->{capability} cmp $b->{capability}
}


sub ti_field_type {
    my ($field) = @_;
    return "3assign" if ($field->{assign});
    return "2num" if ($field->{num});
    return "1bool";
}


sub qquote {my$q=Data::Dumper::qquote($_[0]);$q=~s/^"(.*)"$/$1/s;$q}

1;



# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
