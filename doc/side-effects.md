Using <tt>--nose</tt> (No Side Effects) with termdetect will reduce the number of side-effects that occur when running it.  However, there are still a few side-effects that remain:

* **Gibberish is displayed** on the screen, ocassionally.  This is necessary because it's important to find out which escape sequences the terminal hides versus the sequences that are so unknown that it displays them.  We make an effort to erase the gibberish when we're done, but sometimes we don't clean everything up.

* **Keyboard buffer is cleared**, always.  This is necessary because we read a lot of data from the terminal, in the form of ANSI responses.  Unfortunately, ANSI responses use the same communications channel that keyboard input does (there is no out-of-band channel), so we end up consuming all keyboard input that was buffered before termdetect starts.

Side-effects that may occur if <tt>--nose</tt> isn't used:

* **Screen is cleared**, rarely.  We test if the terminal responds to ^L by clearing the screen, and a small percentage do.
