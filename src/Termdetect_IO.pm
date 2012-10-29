# This module handles the lower-level I/O with the terminal -- sending ANSI sequences, and reading
# responses.


package Termdetect_IO;

    use strict;
    use warnings;

    use Time::HiRes qw[alarm];
    #use Term::ReadKey;

    use Data::Dumper;

    use Exporter 'import';

    our @EXPORT = qw(   run_test  read_phase  read_ansi_reply  output  cooked_mode
                        do_queued_async_reads  );


    # constants
    our $DEBUG = 0;     # turns on lots of debugging

    our $ASYNC = 1;     # Should reads be done asynchronously?
                        # If things are confusing AT ALL, just set this to 0 and debug from there.
                        # In theory, both modes should act exactly the same (except synchronous
                        # takes longer).  However, async won't work correctly if the reads get
                        # misaligned.

    our $CHECK_ALIGNMENT = 0;
                        # Do some extra work to check that reads/writes are aligned properly.
                        # This makes the tests go *much* slower, but it's worth it to 
                        # find out where misalignment is happening.
                        #
                        # While testing, do NOT press any keys on the keyboard.

    if ($DEBUG) {
        # turn on maximum debugging
        $CHECK_ALIGNMENT = 1;
        $ASYNC = 0;
    }

    # prototypes
    sub read_phase(&);

    # globals
    our @read_queue;



# From the outside, this routine merely sends an ANSI query, and reads the reply.
# Internally though, we do it a somewhat fairly sophisticated way.  We surround the request with a
# CPR queries both before and after, which means that 1) we know if the query caused the cursor
# to move, and 2) if the terminal doesn't send any reply at all, we know that too, without having
# to do any waiting.
sub run_test {
    my ($sequence, $cps, $timeout, $no_cr) = @_;
    $cps ||= sub{};     # CPS = continuation-passing style
    $timeout = 2.0  unless defined($timeout);       # in floating-point seconds
                        # $no_cr -- usually we do a \r right before running the test;  setting this
                        #           to true disables that behavior

    my $test_result = {
        sent => $sequence,
    };

    if ($sequence =~ /^(?:\e\[|\x9B)\??6n$/) {
        # run_test() isn't designed to work with a Cursor Position Report command.  This is because
        # it uses a CPR-reply as a way to know when to stop reading.
        #
        # When we're asked to do a CPR sequence, we'll revert to much dumbed-down behavior instead.
        
        output("\r")        unless $no_cr;
        output($sequence,
              "\e[5n");      # add a DSR (device status report) to the end, so we can at least
                            # quickly determine a non-response
                            
        read_phase {
            my $reply = read_ansi_reply($timeout, 'n');
            $reply =~ s/\e\[\d+n$//s;

            $test_result->{received} = $reply;
            @_ = $test_result;  goto &$cps;       # continuation-passing style
        };
        return;
    }

    output("\r")    unless $no_cr;
    output("\e[6n", $sequence, "\e[6n");      # send a CPR (cursor position report) before and after
    #debug_show_remaining_input();

    read_phase {
        my $replies = '';
        my $start = time();
        while (1) {
            my $reply = read_ansi_reply($timeout, 'R');
            if (!defined($reply)) {
                $test_result->{timeout} = 1;
                last;
            }
            $replies .=  $reply;

            if ($replies =~ /.*\e\[(\d+);(\d+)R(.*)\e\[(\d+);(\d+)R/s) {
                $test_result->{x_delta}  = $5 - $2;
                $test_result->{y_delta}  = $4 - $1;
                $test_result->{received} = $3;

                if ($test_result->{y_delta} > 0) {
                    # if this test caused us to move down some lines, then
                    # move back up, to ensure that all "gibberish" is confined to a single line
                    output(("\r"        # move to the beginning of the line
                          . "\e[K"      # erase to end of line
                          . "\e[A")     # move up one line
                                x $test_result->{y_delta});
                }

                @_ = $test_result;  goto &$cps;    # continuation-passing style
            }

            if (time() - $start > $timeout) {
                $test_result->{timeout} = 1;
                last;
            }
        }
        $replies =~ s/^.*?\e\[\d+;\d+R//s;
        $test_result->{received} = $replies;
        @_ = $test_result;  goto &$cps;    # continuation-passing style
    };
}


# There are two phases to every ANSI test:  1) write phase, 2) read phase.
#
# If we do all of the read phases AFTER doing all of the write phases (ie. do the reads
# asynchronously), then the whole process goes much faster.  We minimize latency by doing this.
sub read_phase(&) {
    my ($callback) = @_;
    if ($ASYNC && ! $CHECK_ALIGNMENT) {
        # run the callback asynchronously
        push(@read_queue, $callback);
    } else {
        # run the callback immediately, in-line
        $callback->();

        if ($CHECK_ALIGNMENT) {
            local $DEBUG = 0;       # don't show debugging output...  we INTEND to always timeout inside read_ansi_reply()
            my $any_more_reads = read_ansi_reply(0.1);      # the fractional number here can range from 0.1 to 2.0, depending on how slow the link between them is
            if (length($any_more_reads)) {
                eval 'use Carp';                        # We don't want to rely on any non-core libraries unless really needed.  This will only be needed in development.
                Carp::confess("out of alignment\n");
            }
        }
    }
    return undef;
}


sub do_queued_async_reads {
    while (@read_queue) {
        shift(@read_queue)->();
    }
}






# put the terminal in cooked mode   (and make sure it gets changed back before the program exits)
use POSIX qw(:termios_h);
sub cooked_mode {
    $|++;

    ## cooked mode, echo off
    #Term::ReadKey::ReadMode(2);

    #system 'stty', '-icanon', '-echo', 'eol', "\001";

    # from PerlFAQ8
    my $term = POSIX::Termios->new();
    $term->getattr(0);
    our $orig_lflag = $term->getlflag();
    $term->setlflag($orig_lflag & ~(ECHO | ECHOK | ICANON));
    $term->setcc(VTIME, 1);
    $term->setattr(0, TCSANOW);


    eval q{
        END {
            ## reset tty mode before exiting
            #Term::ReadKey::ReadMode(0);         

            #system 'stty', 'icanon', 'echo', 'eol', chr(0);

            # from PerlFAQ8
            my $term = POSIX::Termios->new();
            $term->getattr(0);
            $term->setlflag($orig_lflag);
            $term->setcc(VTIME, 0);
            $term->setattr(0, TCSANOW);
        }
    };
    die $@ if $@;
}


sub output {
    my $all = join "", @_;
    if ($DEBUG && $all ne "\r" && $all ne "\n" && $all ne "\r\e[K") {
        print "    sending: ", ansi_escape($all), "\n";
    }
    print STDERR $all;
}


# Gets an ANSI response, reading only as many characters as necessary, and waiting only as long
# as necessary.
#
# $timeout
#       Seconds to wait for a reply.  Use 0 for no timeout.
#
# $response_end_character
#       If we see this character, we know the response is finished.
#
#       Special values:
#           - empty string -- means "read one buffer's worth of data".
#           - undef -- means "there is no specific end-character...  read until timeout
#           - regexp reference -- match several characters, not just one
#                   (use the "qr" quote-like operator)
sub read_ansi_reply {
    my ($timeout,
        $response_end_character) = @_;

    $timeout = 1.0 unless defined($timeout);

    my $reply = '';
    $@ = "";
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm($timeout)     if ($timeout != 0);

        if (defined($response_end_character) && $response_end_character eq '') {
            # an empty-string means "read everything that's in the buffer"...  this assumes that
            # the response will be sent all-at-once, and that there will be a slight timegap in between
            # the response and anything else the terminal sends to us
            my $numchars = sysread(STDIN, $reply, 1024);
            $reply = substr($reply, 0, $numchars);
        } else {
            while (1) {
                if (defined(my $c = getc())) {
                    #print ".";
                    $reply .= $c;
                    if (defined($response_end_character)) {
                        if (ref($response_end_character) eq 'Regexp') {
                            last if ($reply =~ $response_end_character);
                        } else {
                            last if ($c eq $response_end_character);
                        }
                    }
                }
            }
        }
    };
    die $@ if ($@ && $@ ne "alarm\n");
    alarm 0;
    if ($DEBUG) {
        if ($@ eq "alarm\n" && (!defined($reply) || length($reply) == 0)) {
            print "    timeout\n";
        } else {
            print "    read response:  ", ansi_escape($reply), "\n";
        }
    }
    return $reply;
}


sub ansi_escape { map {(my $a = $_);
        $a =~ s/\\/\\\\/g;
        $a =~ s/\e/\\E/g;
        $a =~ s/\x5/\\5/g;
        $a =~ s/\x9B/\\x9B/g;
        $a =~ s/([\x00-\x1f\x7f-\xff])/"\\x" . sprintf "%02X", ord($1)/ge;
        $a} @_ }



1;


# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
