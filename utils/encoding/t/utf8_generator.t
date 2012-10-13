#!/usr/bin/perl

# note: currently, this runs great on Perl v5.16, but it barfs a lot on Perl v5.10, complaining
#       about surrogate characters.

    use strict;
    use warnings;

    use lib '..';
    use encoding_utils;

    use Test::Simple        tests => 1;


# scan through ALL characters, one-by-one, and compare to the output of the generator:
#       - if the generator doesn't include it, then confirm that character isn't a valid unicode char
#       - if the generator does include it, then confirm it IS a valid unicode char

my $gen = utf8_generator();
my $cur_char = -1;

#for (my $ctr=0; $ctr<0x10000; $ctr++) {
for (my $ctr=0; $ctr<0x10FFFF; $ctr++) {
    if ($cur_char < $ctr) {
        my $c = $gen->();
        last if (!defined($c));
        $cur_char = ord($c);
    }

    my $gen_thinks_is_valid = ($cur_char == $ctr);
    my $is_actually_valid   = (chr($ctr) =~ /\p{Assigned}/);

    if (!!$gen_thinks_is_valid != !!$is_actually_valid) {
        printf STDERR "FAILED on U+%04X -- character %s a real character\n",
                      $ctr,
                      $is_actually_valid ? "is" : "is not";
        ok(0, 'utf8_generator()');
        exit;
    }

    #last if ($ctr > 1000);
}

# all characters were verified correctly!
ok(1, 'utf8_generator()');
