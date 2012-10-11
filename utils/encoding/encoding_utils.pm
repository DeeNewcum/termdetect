
# A bag of unrelated routines that are used in different util scripts here.
#
# The reason that some routines are put here is 1) Don't Repeat Yourself, and 2) some really need to
# be unit-tested.

package encoding_utils;

    use strict;
    use warnings;

    use Exporter 'import';
    our @EXPORT = qw( utf8_generator );



# generates all possible Unicode characters
# see "Higher-Order Perl" chapter 4 for more info about generators
use Unicode::UCD;
sub utf8_generator {
    my $cur_char = -1;
    my @blocks = sort {$a->[0] <=> $b->[0]} map { @$_ } values %{ Unicode::UCD::charblocks() };
    my $cur_range_end = -2;
    return sub {
        do {
            $cur_char++;
            if ($cur_char > $cur_range_end) {
                return undef unless @blocks;        # we're all done!
                ($cur_char, $cur_range_end) = @{ shift @blocks };
            }
        } while (chr($cur_char) !~ /\p{Assigned}/);      # make sure we return assigned characters
        return chr($cur_char);
    }
}


1;
