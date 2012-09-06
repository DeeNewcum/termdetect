#!/usr/bin/perl

# There are several ANSI escape codes that can be used between the server and client for
# query/reply.  This utility shows how your current terminal responds to a particular query.

    use strict;
    use warnings;

    use Time::HiRes qw[alarm];
    #use Term::ReadKey;

    use Data::Dumper;

    use constant TIMEOUT => 1.0;        # total seconds to wait for a reply


@ARGV or die "$0 [-r] <query> [<response_end_character>]\n";

my $cmdline_raw = 0;      # print the reply, and nothing else   (useful within a shell script)
$cmdline_raw = shift @ARGV    if ($ARGV[0] eq '-r');

my ($query, $response_end_character) = @ARGV;

$query = perl_string_decode($query);


## cooked mode, echo off
#Term::ReadKey::ReadMode(2);
system "stty", '-icanon', '-echo', 'eol', "\001";


# print to STDERR instead of STDOUT, so this can work with
# Bash's $(ansi_reply.pl ...) mechanism
print STDERR $query;
$|++;


my $reply = '';
eval {
    local $SIG{ALRM} = sub { die "alarm\n" };
    alarm(TIMEOUT);

    if (defined($response_end_character) && $response_end_character eq '') {
        # an empty-string means "read everything that's in the buffer"...  this assumes that
        # the response will be sent all-at-once, and that there will be a slight timegap in between
        # the response and anything the human types
        my $numchars = sysread(STDIN, $reply, 1024);
        $reply = substr($reply, 0, $numchars);
    } else {
        while (1) {
            if (defined(my $c = getc())) {
                #print ".";
                $reply .= $c;
                last if (defined($response_end_character)
                      && $c eq $response_end_character);
            }
        }
    }
};
die $@      if ($@ && $@ ne "alarm\n");


if (!$cmdline_raw) {
    print "  query:  ", perl_string_encode($query), "\n";
    print "  reply:  ", perl_string_encode($reply), "\n";
} else {
    #print perl_string_encode($reply), "\n";

    # Split into words, to make it easier to injest by Bash's array-splitting behavior, or by cut(1).
    # For example:
    #       arr=($(./ansi_reply.pl -r '\e[6n' R))
    #       echo current row: ${arr[1]} column: ${arr[3]}
    #       
    # Or:
    #       row=$(./ansi_reply.pl -r '\e[6n' R | cut -f 2)
    #       col=$(./ansi_reply.pl -r '\e[6n' R | cut -f 4)
    my @a = split /(?<=\d)(?=\D)|(?<=\D)(?=\d)|(?<=[a-z])(?=[^a-z])|(?<=[^a-z])(?=[a-z])/i, $reply;
    print join("\t", map {perl_string_encode($_)} @a), "\n";
}


## reset tty mode before exiting
#Term::ReadKey::ReadMode(0);         
system 'stty', 'icanon', 'echo', 'eol', chr(0);





# turn things like "\e" and "\033" into their single-character equivalents, using standard perl string-literal rules
sub perl_string_decode {
    my $encoded = shift;
    my $decoded = eval "qq\000$encoded\000";
}


# turn things like chr(27) into '\e' -- into a visible presentation
sub perl_string_encode {
    my $decoded = shift;
    my $encoded = Data::Dumper::qquote($decoded);
    $encoded =~ s/^"(.*)"$/$1/s;
    return $encoded;
}


# display a string to the user, via `xxd`
sub xxd {open my$xxd,"|xxd"or die$!;print$xxd $_[0];close$xxd}
