# This module includes all routines that are either related to performing I/O, or are responsible
# for directly performing tests on the terminal.
#
# Routines that deal only with the test RESULTS are located elsewhere.

package Termdetect_Tests;

    use strict;
    use warnings;

    use Time::HiRes qw[alarm];
    #use Term::ReadKey;

    use Data::Dumper;

    use Exporter 'import';

    our @EXPORT = qw( perform_all_tests ansi_escape_no_nl ansi_escape summarize_result );


    # constants
    our $ASYNC = 1;     # Should reads be done asynchronously?
                        # If things are confusing AT ALL, just set this to 0 and debug from there.
                        # In theory, both modes should act exactly the same (except synchronous
                        # takes longer).  However, async won't work correctly if the reads get
                        # misaligned.
    our $DEBUG = 0;

    # prototypes
    sub read_phase(&);

    # globals
    our @read_queue;



# returns a data structure with the results of running the tests
sub perform_all_tests {
    cooked_mode();

    ensure_cursor_position_supported();
    
    local our %all_results;     # this needs to be visible inside run_and_store_tests()

    run_and_store_test(r_device_status      => "\e[5n");
    run_and_store_test(r_printer_status     => "\e[?15n");
    run_and_store_test(r_term_id            => "\eZ");
    run_and_store_test(r_device_attr        => "\e[c");
    run_and_store_test(r_device_attr2       => "\e[>c");
    run_and_store_test(r_device_attr3       => "\e[=c");
    run_and_store_test(r_term_param         => "\e[x");
    run_and_store_test(r_enquiry            => "\5");

    run_and_store_test(r_ext_cursor_pos     => "\e[?6n");
    run_and_store_test(r_window_title       => "\e[21t");
    run_and_store_test(r_window_icon_label  => "\e[20t");
    run_and_store_test(r_window_size_px     => "\e[14t");
    run_and_store_test(r_window_size_char   => "\e[18t");
    run_and_store_test(r_window_state       => "\e[11t");
    run_and_store_test(r_window_pos         => "\e[13t");
    run_and_store_test(r_screen_size        => "\e[19t");

    run_and_store_test(m_c1                 => "\x9B0K");
    run_and_store_test(m_pad_null           => "\x00");
    run_and_store_test(m_null_inside        => "\e\x00K");
    run_and_store_test(m_cancel             => "\e[?\x18");
    run_and_store_test(m_sub                => "\e[?\x1A");
    run_and_store_test(m_esc                => "\e[?\eK");


    if (0) {
        ################# things that haven't been given a test_id yet ###############
        read_phase {
            print "="x30, "[ r_* tests ]", "="x30, "\n";        };

        #run_and_display_test("\x9B5n",              "C1 version of DSR");
        run_and_display_test("\e[?50n",             "DSR - keyboard status");
        run_and_display_test("\e[?20n",             "DSR - user-defined key status");

        read_phase {
            print "="x30, "[ m_* tests ]", "="x30, "\n";        };

        run_and_display_test("\e[=",                "application keypad mode");
        run_and_display_test("\e[>",                "numeric keypad mode");
        run_and_display_test("\e|",                 "visual bell");
        run_and_display_test("\e[7",                "save cursor and attributes");
        run_and_display_test("\eg",                 "visual bell");
        run_and_display_test("\eP\e\\",             "DCS - device control string (blank)");
        run_and_display_test("\eP\e[0m\e\\",        "DCS - device control string (SGR reset); must be non-zero to pass");
        run_and_display_test("\e\%G",               "[ISO2022] select UTF8 character set");
        run_and_display_test("\e*C",                "[ISO2022] designate G2 character set");
        run_and_display_test("\e+C",                "[ISO2022] designate G3 character set");
        run_and_display_test("\e\\",                qq{"do nothing" sequence});


        read_phase {
            print "="x30, "[ s_* tests ]", "="x30, "\n";        };

        run_and_display_test("\ek-\e\\",            "set title");
        run_and_display_test("\ek-\e\\\e[21t",      "set + get title");

        read_phase {        print "\n\n"      };
    }

    do_queued_async_reads();
    output("\r\e[K");     # erase the line that we just sprayed gibberish over

    calculate_derived_values(\%all_results);

    return \%all_results;
}


# We use the cursor-position report a lot...   if that doesn't work, then things will get hung up
# and take way too long.
# Figure this out before we waste a lot of time.
sub ensure_cursor_position_supported {

    output("\e[6n");

    read_phase {
        my $reply = read_ansi_reply(1.0, qr/\e[^a-zA-Z]*[a-zA-Z]/);
        if (!defined($reply) || $reply !~ /\e\[\d+;\d+R$/s) {
            close STDOUT; select undef,undef,undef,0.001;
            die "Terminal is unable to report the cursor position.  This is required for many tests.\n";
        }
    };
}


sub run_and_store_test {
    my ($test_id, $sequence) = @_;

    run_test($sequence, sub {
        my ($test_result) = @_;
        our %all_results;           # pull this in from the 'local'ized copy in perform_all_tests()
        $all_results{$test_id} = $test_result;
    });
}


sub run_and_display_test {
    my ($sequence) = shift;
    my $test_id = '';
    $test_id = shift    if (@_ >= 2);
    my $description = shift;


    run_test($sequence, sub {
        my ($test_result) = @_;
        print "\r";
        my $response = '';
        if ($test_result->{x_delta}) {
            $response = "[+$test_result->{x_delta}]";
        } else {
            $response = $test_result->{received};
        }
        printf  "%-20s  %-15s %-25s   %s\n",
                $test_id,
                ansi_escape($sequence),
                ansi_escape($response),
                $description;
    });
}


# From the outside, this routine merely sense an ANSI query, and reads the reply.
# Internally though, we do it a somewhat fairly sophisticated way.  We surround the request with a
# CPR queries both before and after, which means that 1) we know if the query caused the cursor
# to move, and 2) if the terminal doesn't send any reply at all, we know that too, without having
# to do any waiting.
sub run_test {
    my ($sequence, $cps, $timeout) = @_;
    $cps ||= sub{};     # CPS = continuation-passing style
    $timeout = 2.0  unless defined($timeout);       # in floating-point seconds

    my $test_result = {
        sent => $sequence,
    };

    if ($sequence =~ /^(?:\e\[|\x9B)\??6n$/) {
        # run_test() isn't designed to work with a Cursor Position Report command.  This is because
        # it uses a CPR-reply as a way to know when to stop reading.
        #
        # When we're asked to do a CPR sequence, we'll revert to much dumbed-down behavior instead.
        
        output("\r", $sequence,
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

    output("\r", "\e[6n", $sequence, "\e[6n");      # send a CPR (cursor position report) before and after
    #debug_show_remaining_input();

    read_phase {
        my $replies = '';
        my $start = time();
        while (1) {
            $replies .= read_ansi_reply($timeout, 'R') || last;

            if ($replies =~ /.*\e\[(\d+);(\d+)R(.*)\e\[(\d+);(\d+)R/s) {
                $test_result->{x_delta}  = $5 - $2     if ($5 - $2);
                $test_result->{y_delta}  = $4 - $1     if ($4 - $1);
                $test_result->{received} = $3;

                @_ = $test_result;  goto &$cps;    # continuation-passing style
            }

            last if (time() - $start > $timeout);
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
    if ($ASYNC) {
        # run the callback asynchronously
        push(@read_queue, $callback);
    } else {
        # run the callback immediately, in-line
        $callback->();
    }
    return undef;
}


sub do_queued_async_reads {
    while (@read_queue) {
        shift(@read_queue)->();
    }
}


##########################################################################################
##################################[ derived values ]######################################
##########################################################################################

# some values are purely derived from others...  these don't require any I/O, and can be done after
# the last call to do_queued_async_reads()
sub calculate_derived_values {
    my ($all_results) = @_;

    my ($fontsize_x, $fontsize_y);
    if ($all_results->{r_window_size_px}{received} && $all_results->{r_window_size_char}{received}) {
        my (undef, $px_y, $px_x) = ansi_params($all_results->{r_window_size_px}{received});
        my (undef, $ch_y, $ch_x) = ansi_params($all_results->{r_window_size_char}{received});
        #print Dumper [$ch_x, $ch_y];
        $fontsize_x = int($px_x / $ch_x);
        $fontsize_y = int($px_y / $ch_y);
        $all_results->{s_font_size}{received} = "${fontsize_x}x${fontsize_y}";
    }
    if ($all_results->{r_window_size_px}{received} && $all_results->{r_window_size_char}{received} &&
            $all_results->{r_screen_size}{received}) {
        my (undef, $s_y, $s_x) = ansi_params($all_results->{r_screen_size}{received});
        $s_x *= $fontsize_x;
        $s_y *= $fontsize_y;
        # We have a quandary here -- the screen-size we derived isn't EXACTLY right.
        # It could be off by as much as +/- $fontsize_x and $fontsize_y.
        #
        # One solution is just to round to the nearest N, where N is:
        #       8 for X         
        #       4 for Y
        # based on the greatest-common-factor for resolution widths and heights.
        $s_x = round_up($s_x, 8);
        $s_y = round_up($s_y, 4);
        $all_results->{s_screen_size}{received} = "${s_x}x${s_y}";
    }
    if ($all_results->{r_window_pos}{received}) {
        my (undef, $p_x, $p_y) = ansi_params($all_results->{r_window_pos}{received});
                    # ^^^^^^ is this backwards?  This is what libVTE uses, but it seems backwards.
        $all_results->{s_window_pos}{received} = "${p_x}x${p_y}";
    }
    if (($all_results->{r_window_title}{received} || '') =~ /^\e\]l(.*)\e\\$/) {
        $all_results->{s_window_title}{received} = $1;
    }
    if (($all_results->{r_window_icon_label}{received} || '') =~ /^\e\]L(.*)\e\\$/) {
        $all_results->{s_window_icon_label}{received} = $1;
    }
}

    sub round_up {
        my ($n, $modulo) = @_;
        if ($n % $modulo) {
            $n += ($modulo - $n % $modulo);
        }
        return $n;
    }


# given the {received} field, return the numeric parameters, as an array
sub ansi_params {
    my ($received) = @_;
    return () unless defined($received);
    my @params = ($received =~ /(\d+)/g);
    return @params;
}


##########################################################################################
############################[ debugging and human-readable ]##############################
##########################################################################################

sub summarize_result {
    my ($test_result) = @_;
    #print ansi_escape_no_nl(Dumper $test_result); exit;
    if (exists $test_result->{x_delta}) {
        return "%x+$test_result->{x_delta}";
    } else {
        return ansi_escape($test_result->{received});
    }
}



sub debug_show_remaining_input {
    print "---- debug_show_remaining_input ----\n";
    while (my $reply = read_ansi_reply(0, '')) {
        print ansi_escape($reply), "\n";
    }
    exit;
}


sub ansi_escape { map {(my $a = $_);
        $a =~ s/\\/\\\\/g;
        $a =~ s/\e/\\e/g;
        $a =~ s/\x5/\\5/g;
        $a =~ s/\x9B/\\x9B/g;
        $a =~ s/([\x00-\x1f])/"\\x" . sprintf "%02X", ord($1)/ge;
        $a} @_ }


# like ansi_escape, but don't escape newlines
sub ansi_escape_no_nl {
    my $text = join('', @_);
    my @lines = split /[\n\r]+/, $text;
    @lines = map {ansi_escape($_)} @lines;
    return join("\n", @lines), "\n";
}


##########################################################################################
##############################[ lower-level IO routines ]#################################
##########################################################################################


# put the terminal in cooked mode   (and make sure it gets changed back before the program exits)
sub cooked_mode {
    ## cooked mode, echo off
    #Term::ReadKey::ReadMode(2);
    system 'stty', '-icanon', '-echo', 'eol', "\001";
    $|++;

    eval q{
        END {
            ## reset tty mode before exiting
            #Term::ReadKey::ReadMode(0);         
            system 'stty', 'icanon', 'echo', 'eol', chr(0);
        }
    };
}


sub output {
    print "sending: ", ansi_escape(join "", @_), "\n"       if ($DEBUG);
    print STDERR @_;
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
    print "read response:  ", ansi_escape($reply), "\n"     if ($DEBUG);
    return $reply;
}





1;


# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
