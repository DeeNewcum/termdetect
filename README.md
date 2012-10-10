People have different approaches to setting their $TERM:

* Accept whatever your terminal initially suggests, and hope for the best.
* Hard-code $TERM to your most-used terminal.  Put up with any problems that happen whenever you use a different terminal.
* Set it to "vt100", so that things will at least minimally work.
* Manually set it, based on what you can remember about what terminfo entries are available and which terminal you're currently using.

Ultimately, whenever $TERM is automatically set, you get the lowest common denominator.  The terminal doesn't want to suggest too aggressive of a $TERM, because it doesn't know what your remote machines' terminfos support.  And your remote computers don't want to change it to something too aggressive because they don't know whether your terminal can actually support all the fancy features.

What if there was a way for Vim to know *for sure* if it was talking to a 256 color terminal or not?

Fortunately, there is.

    $ termdetect
                terminal:   vte / gnome-terminal / xfce4-terminal
                 version:   libvte v0.32.1
           terminal size:   318 x 74
               font size:   6 x 13
         window position:   5 x 81
             screen size:   3200 x 1080

    $ export TERM=$(termdetect -t)
    $ echo $TERM
    vte

    ****TODO****: suggest some lines that users can put in their .vimrc to properly set things up as either 16 color or 256 color

    $ termping 
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)

    # ^^ from this, a script can guess that the user's terminal is located on the same machine or in close proximity

## How does it work?

There are [some request/reply ANSI sequences](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md#capability-names-tests) that give us bits of information about the terminal.  <tt>Termdetect</tt> looks up the responses in a database of known terminals.  Because it relies on ANSI escape sequences *only*, <tt>termdetect</tt> works across SSH and serial links.

## Current status

The software is alpha quality, and not ready for wide use.

The main features of the code are minimally working, but a few more features need to be complete before release, and the code needs to be packaged to make it easier to install.

See [here](https://github.com/DeeNewcum/termdetect/graphs/code-frequency) and [here](https://github.com/DeeNewcum/termdetect/branches) to see the recent activity level.

## Documentation

* see [doc/termmatch.md](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md)
* run <tt>termdetect --help</tt>

## Dependencies

termdetect requires only a base install of Perl; it requires no extra libraries.  It has been tested on Perl v5.8.8.
