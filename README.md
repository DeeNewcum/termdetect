## termdetect

There hasn't been a good way to automatically set the $TERM variable.  Your terminal emulator doesn't know what terminfo entries are available on your remote machine, and your remote machine doesn't know exactly what your terminal is actually capable of, so both sides make blind guesses.

Termdetect solves this.  By sending various ANSI queries<sup>[(1)](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md#capability-names-tests)</sup> and looking up the replies in a table of known responses,<sup>[(2)](https://github.com/DeeNewcum/termdetect/blob/master/src/termmatch.src)</sup> scripts on the remote machine can know *exactly* which terminal they're talking to.

    $ termdetect
                terminal:   vte / gnome-terminal / xfce4-terminal
                 version:   libvte v0.32.1
                encoding:   utf8
           terminal size:   318 x 74
               font size:   6 x 13
         window position:   5 x 81
             screen size:   3200 x 1080

## Installation

Download the latest version [here](https://github.com/DeeNewcum/termdetect/downloads), unpack it, and read the [README.txt](https://github.com/DeeNewcum/termdetect/blob/master/release/README.txt) inside.

Add this to your startup script, eg. .bashrc:   <tt>export TERM=$(termdetect -t)</tt>

Requirements: [Any Un*x](https://github.com/DeeNewcum/termdetect/blob/master/doc/tested_on.txt), and a standard installation of Perl.

## Other uses

termdetect data can be used in many ways.  People are used to mistrusting $TERM and terminfo, but once you're able to trust them, your configuration can become more adaptive and flexible.

````vim
" ~/.vimrc
syntax on
if &t_Co >= 256 || has('gui_running')
    " your prefered colorscheme when the current terminal supports 256 colors
    let g:solarized_termcolors=&t_Co
    colorscheme solarized
else
    " your prefered colorscheme when the current terminal supports 16 colors
    colorscheme pablo
endif
````

## Documentation

* run <tt>termdetect --help</tt>
* see [doc/termmatch.md](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md)

