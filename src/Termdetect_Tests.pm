# This module directly performs terminal-type tests on the terminal.
# Routines that deal only with the test RESULTS are located elsewhere.
# (also, tests that are encoding-specific are located in Termdetect_Encoding.pm)


package Termdetect_Tests;

    use strict;
    use warnings;

    use Termdetect_Encoding;
    use Termdetect_IO;

    use Data::Dumper;

    use Exporter 'import';

    our @EXPORT = qw( perform_all_tests ansi_escape_no_nl ansi_escape summarize_result );

    
    # synthetic capabilities that are rarely tested against
    our %rarely_tested_synthetics = map {$_ => 1} qw(
            s_font_size
            s_screen_size
            s_window_icon_label
            s_window_size
            s_window_pos
            s_window_title
            s_encoding
        );




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
    run_test("\e[=1c");         # some terminals interpret DA3 as a request to turn off the cursor, so we need to turn it back on
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

    synthetic__ff_clears();

    Termdetect_Encoding::do_encoding_tests(\%all_results);


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


##########################################################################################
##################################[ synthetic tests ]#####################################
##########################################################################################


# s_ff_clears -- does the form-feed character (^L) clear the screen?
#
# NOTE however, that some terminals will respond to FF by clearing the screen, but NOT moving the
#       cursor back to (1,1).  What we're REALLY detecting here is moving the cursor back to
#       (1,1), *not* whether the screen is cleared.
#
#       See:  http://www.aivosto.com/vbtips/control-characters.html#FF
sub synthetic__ff_clears {
    return if ($::ARGV{'nose'});        # side effect: clears the screen

    DEBUG_test_name();

    output("\r\e[K");           # clear any gibberish that might be on this line, since we're dropping down a line
    output("\n");               # move a line first, to make sure we're not on the top line
    run_test("\x0c",
        sub {
            my ($test_result) = @_;
            our %all_results;           # pull this in from the 'local'ized copy in perform_all_tests()

            # did we move up one or more lines?
            $all_results{s_ff_clears}{received} =
                    (($test_result->{y_delta} || 0) < 0) ? 'true' : 'false';

            if ($all_results{s_ff_clears}{received} eq 'false') {
                # if the screen wasn't cleared, move back up one line
                output("\r\e[K"         # clear current line
                     . "\e[A");         # move up one line
            }
        });
}


##########################################################################################
##################################[ standard tests ]######################################
##########################################################################################

# We use the cursor-position report a lot...   if that doesn't work, then things will get hung up
# and take way too long.
# Figure this out before we waste a lot of time.
sub ensure_cursor_position_supported {

    DEBUG_test_name();

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

    DEBUG_test_name($test_id);

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


##########################################################################################
##################################[ derived values ]######################################
##########################################################################################

# some values are purely derived from others...  these don't require any I/O, and can be done after
# the last call to do_queued_async_reads()
sub calculate_derived_values {
    my ($all_results) = @_;

    if ($all_results->{r_window_size_char}{received}) {
        my (undef, $ch_y, $ch_x) = ansi_params($all_results->{r_window_size_char}{received});
        $all_results->{s_window_size}{received} = "$ch_x x $ch_y";
    }
    my ($fontsize_x, $fontsize_y);
    if ($all_results->{r_window_size_px}{received} && $all_results->{r_window_size_char}{received}) {
        my (undef, $px_y, $px_x) = ansi_params($all_results->{r_window_size_px}{received});
        my (undef, $ch_y, $ch_x) = ansi_params($all_results->{r_window_size_char}{received});
        #print Dumper [$ch_x, $ch_y];
        $fontsize_x = int($px_x / $ch_x);
        $fontsize_y = int($px_y / $ch_y);
        $all_results->{s_font_size}{received} = "$fontsize_x x $fontsize_y";
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
        $all_results->{s_screen_size}{received} = "$s_x x $s_y";
    }
    if ($all_results->{r_window_pos}{received}) {
        my (undef, $p_x, $p_y) = ansi_params($all_results->{r_window_pos}{received});
                    # ^^^^^^ is this backwards?  This is what libVTE uses, but it seems backwards.
        $all_results->{s_window_pos}{received} = "$p_x x $p_y";
    }
    if (($all_results->{r_window_title}{received} || '') =~ /^\e\]l(.*)\e\\$/) {
        $all_results->{s_window_title}{received} = $1;
    }
    if (($all_results->{r_window_icon_label}{received} || '') =~ /^\e\]L(.*)\e\\$/) {
        $all_results->{s_window_icon_label}{received} = $1;
    }
}

sub calculate_derived_values_after_match {
    my ($all_results, $termmatch_db, $matched_term) = @_;

    calculate_version($all_results, $matched_term);
}


sub calculate_version {
    my ($all_results, $matched_term) = @_;

    return unless (exists $all_results->{r_device_attr2});
    my (undef, $da2) = split /;/, $all_results->{r_device_attr2}{received};

    # The exact interpretation of the second argument of DA2 varies based on terminal.
    # This is the only place in the code that we have terminal-specific code.  This really
    # out to be moved to termmatch.src in some way.
    if ($matched_term eq 'vte') {
        $da2 =~ s/(\d\d)$//;
        my $last2digits = $1;
        $all_results->{s_term_version}{received} = sprintf "libvte v%0.2f.%d", $da2 / 100, $last2digits;
    } elsif ($matched_term =~ /^screen(?:_.*)?$/) {
        $da2 =~ s/(\d\d)$//;
        my $last2digits = $1;
        $all_results->{s_term_version}{received} = sprintf "v%0.2f.%02d", $da2 / 100, $last2digits;
    } elsif ($matched_term eq 'mrxvt') {
        # mrxvt's version number already has dots in it, which is a total violation of the spec
        $all_results->{s_term_version}{received} = "v$da2";     
    } elsif ($matched_term eq 'xterm') {
        $all_results->{s_term_version}{received} = "#$da2";
    } else {
        # otherwise, the version usually just means "we are feature-compatible with version XX of xterm"
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

# when $Termdetect_IO::DEBUG is turned on, print out the provided test summary, before running
# the test
sub DEBUG_test_name {
    if ($Termdetect_IO::DEBUG) {
        if (!@_) {
            # if no name is given, use the caller's subroutine name
            my $caller_sub = (caller(1))[3];
            $caller_sub =~ s/^.*:://;
            @_ = ($caller_sub);
        }
        debug_log("test ", @_, "\n");
    }
}


sub summarize_result {
    my ($test_result) = @_;
    #print ansi_escape_no_nl(Dumper $test_result); exit;
    if (exists $test_result->{x_delta}) {
        return "%x+$test_result->{x_delta}";
    } else {
        return (ansi_escape($test_result->{received}))[0];
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
        $a =~ s/\e/\\E/g;
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





1;


# Copyright (C) 2012  Dee Newcum
# https://github.com/DeeNewcum/
#
# You may redistribute this program and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
