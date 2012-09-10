#!/usr/bin/perl

# This is a potential optimization of the mainline 'termdetect' code, to make it so that the 
# "send" and "receive" portions of each bit of code are processed in different places....
# the receive portion is handled asynchronously.  It's possible that this will speed up
# the whole process, since it effectively increases the "TCP window" -- we try to minimize the
# impact of latency as much as possible.

# Conclusion: YES, this improves performance significantly.

    use strict;
    use warnings;

    use Data::Dumper;
    #use Devel::Comments;           # uncomment this during development to enable the ### debugging statements

    use constant PREPEND_CPR => 0;      # we definitely need to append a CPR (cursor position report),
                                        # but should we prepend one too?





## cooked mode, echo off
#Term::ReadKey::ReadMode(2);
system 'stty', '-icanon', '-echo', 'eol', "\001";
$|++;

END {
    ## reset tty mode before exiting
    #Term::ReadKey::ReadMode(0);         
    system 'stty', 'icanon', 'echo', 'eol', chr(0);
}



# This is a quick version, just to prove it works.  If this works, we'll build a version that
# places the reply-callback in an automatically-maintained queue.
my @seqs = (
        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

        ["\e[5n",  "DSR -- device status report"],
        ["\e[c",   "DA - device attributes"],
        ["\e[21t", "[dterm] window title"],

    );


foreach (@seqs) {
    output(@$_);
}
foreach (@seqs) {
    receive(@$_);
}



sub output {
    my ($sequence, $description) = @_;

    # we don't handle CPR sequences in here
    die if ($sequence =~ /^(?:\e\[|\x9B)\??6n$/);

    print "\e[6n" if PREPEND_CPR;
    print $sequence, "\e[6n";      # send a CPR (cursor position report) afterwards
}


sub receive {
    my ($sequence, $description) = @_;

    my $response = read_ansi_reply(0, 'R');
    $response .= read_ansi_reply(0, 'R')        if PREPEND_CPR;

    (my $just_response = $response) =~ s/\e\[\d+;\d+R$//s;
    $just_response =~ s/^\e\[\d+;\d+R//s        if PREPEND_CPR;

    printf  "%-10s   %-25s   %s\n",
            ansi_escape($sequence),
            ansi_escape($just_response),
            $description;
}




# Gets an ANSI response, reading only as many characters as necessary, and waiting only as long
# as necessary.
#
# $timeout                  Seconds to wait for a reply.  Use 0 for no timeout.
#
# $response_end_character   If we see this character, we know the response is finished.
#                           Use the empty string to mean "read one buffer's worth of data".
#                           Use undef to mean "there is no specific end-character...  don't stop
#                                   reading until the timeout hits".
sub read_ansi_reply {
    my ($timeout,
        $response_end_character) = @_;

    $timeout = 1.0 unless defined($timeout);

    my $reply = '';
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm($timeout)     if ($timeout != 0);

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
                    if (defined($response_end_character)) {
                        if (ref($response_end_character) eq 'Regexp') {
                            last if ($c =~ $response_end_character);
                        } else {
                            last if ($c eq $response_end_character);
                        }
                    }
                }
            }
        }
    };
    if ($@) {
        return undef if ($@ eq "alarm\n");
        die $@;
    }
    return $reply;
}


sub ansi_escape { map {(my $a = $_);
        $a =~ s/\\/\\\\/g;
        $a =~ s/\e/\\e/g;
        $a =~ s/\x5/\\5/g;
        $a =~ s/\x9B/\\x9B/g;
        $a} @_ }



