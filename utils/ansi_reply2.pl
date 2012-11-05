#!/usr/bin/perl

# Just like ansi_reply.pl, but this uses termdetect's own I/O routines, so this should be a little
# more featureful/robust.  We're leaving ansi_reply.pl as a standalone script, even though it's
# duplicate functionality to this, because it has much fewer dependencies.

    use strict;
    use warnings;

    # improved FindBin
    use Cwd 'abs_path';
    use File::Basename;
    BEGIN {$FindBin::Bin = dirname( abs_path $0 ) }
    use lib "$FindBin::Bin/../src/";

    use Termdetect_IO;
    use Terminfo_Parser qw( terminfo_unescape );
    use Termdetect_Tests qw( summarize_result );

    use Data::Dumper;
    #use Devel::Comments;           # uncomment this during development to enable the ### debugging statements


$Termdetect_IO::ASYNC = 0;

die "syntax:   ansi_reply2.pl  <query>\n\n\t(where <query> is the same format as terminfo fields)\n"
        unless @ARGV;

my ($query) = @ARGV;

$query = terminfo_unescape($query);
    #print $query; exit;

cooked_mode();
my $reply = run_test($query, \&test_reply, 0.5);


sub test_reply {
    my ($test_result) = @_;

    output("\r\e[K");
    
    foreach my $var (sort keys %$test_result) {
        my $val = $test_result->{$var};
        next if ($var =~ /^._delta$/ && $val == 0);
        printf "%10s = %s\n",
               $var,
               Termdetect_IO::ansi_escape($val);
    }
}
