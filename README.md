There isn't a good way to automatically set the $TERM variable, particularly if you use more than one server OS or more than one terminal emulator.

The terminal-emulator doesn't know what terminfo entries are available on the remote machine, and the remote machine doesn't know exactly what your terminal is actually capable of, so both sides make blind guesses.

termdetect solves this problem by [running a series of ANSI queries](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md#capability-names-tests) on the terminal, and looking up the responses in a table of known terminals.  This allows the remote machine to know *exactly* what terminal it's talking to.

    $ termdetect
                terminal:   vte / gnome-terminal / xfce4-terminal
                 version:   libvte v0.32.1
                encoding:   utf8
           terminal size:   318 x 74
               font size:   6 x 13
         window position:   5 x 81
             screen size:   3200 x 1080

    $ export TERM=$(termdetect -t)
    $ echo $TERM
    vte-256color

    $ termping 
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)

    # ^^ from this, a script can guess that the user's terminal is located
    #    on the same machine or in close proximity

## Installation

Download the latest version [here](https://github.com/DeeNewcum/termdetect/downloads), unpack it, and read the [README.txt](https://github.com/DeeNewcum/termdetect/blob/master/release/README.txt) inside.

termdetect requires only a base install of Perl.  It has been tested on a [variety of Perl versions and operating systems](https://github.com/DeeNewcum/termdetect/blob/master/doc/tested_on.txt).

## Documentation

* run <tt>termdetect --help</tt>
* see [doc/termmatch.md](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md)

