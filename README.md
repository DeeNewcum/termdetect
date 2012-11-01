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

## Installation

Download the latest version [here](https://github.com/DeeNewcum/termdetect/downloads), unpack it, and read the [README.txt](https://github.com/DeeNewcum/termdetect/blob/master/release/README.txt) inside.

termdetect [works on most Unixes](https://github.com/DeeNewcum/termdetect/blob/master/doc/tested_on.txt), and requires nothing more than a standard installation of Perl.

### .vimrc

    syntax on
    if &t_Co >= 256 || has('gui_running')
        " your prefered colorscheme when the terminal supports 256 colors
        let g:solarized_termcolors=&t_Co
        colorscheme solarized
    else
        " your prefered colorscheme when the terminal supports 16 colors
        colorscheme pablo
    endif

## Documentation

* run <tt>termdetect --help</tt>
* see [doc/termmatch.md](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md)

