This document details the side-effects that occur when running termdetect.

The <tt>--nose</tt> flag (No Side Effects) can reduce the number of side-effects that occur.

## Side-effects that always happen

There are a few side-effects that unfortunately can't be avoided, even when <tt>--nose</tt> is used.

* **Gibberish characters are displayed**, occasionally.  This is necessary because it's important to find out which escape sequences your terminal hides, versus the sequences that are so unknown that your terminal displays them.  An effort is made to erase the gibberish, but occasionally not everything gets cleaned up.

* **Keyboard buffer is cleared**, always.  To help deal with this, a line with a single dash gets displayed, as a signal of when it's safe to start typing things into the buffer.

    Why is it necessary to clear the keyboard buffer?  A lot of data gets sent from the terminal to termdetect, in the form of ANSI replies.  Unfortunately, ANSI replies use the same communication channel that keyboard input does (there is no out-of-band channel), so termdetect ends up consuming all keyboard input that was in the buffer before termdetect starts.

## Side-effects that get turned off when you use --nose

* **Screen is cleared**, rarely.  A test is run to see if your terminal responds to ^L by clearing the screen, and a small percentage of terminals do.

## Would it be a problem to use --nose all the time?

It should be fine to do this.  Using <tt>--nose</tt> turns off a very small percentage of tests.  Usually there is enough data from the remaining tests that each terminal can still be uniquely identified.

There is a very small possibility that a terminal can't be uniquely identified without running the full set of tests. So termdetect does the safest thing by default, and runs every test just in case.
