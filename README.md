## termdetect

There hasn't been a good way to automatically set the $TERM variable.  Your terminal emulator doesn't know what terminfo entries are available on your remote machine, and your remote machine doesn't know exactly what your terminal is actually capable of, so both sides make blind guesses about the other.

Termdetect solves this.  By sending various ANSI queries<sup>[(1)](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md#capability-names-tests)</sup> and looking up the replies in a table of known responses,<sup>[(2)](https://github.com/DeeNewcum/termdetect/blob/master/src/termmatch.src)</sup> termdetect can know *exactly* which terminal it's talking to.

    $ termdetect
                terminal:   vte / gnome-terminal / xfce4-terminal
                 version:   libvte v0.32.1
                encoding:   utf8
           terminal size:   318 x 74   (characters)
               font size:   6 x 13   (pixels)
         window position:   5 x 81   (pixels)
             screen size:   3200 x 1080   (pixels)

This information is determined solely by communicating directly with the remote terminal, none of it comes from the local OS.

## Installation

    curl -L http://is.gd/termdetect -o termdetect;  chmod +x termdetect
        or
    wget http://is.gd/termdetect;  chmod +x termdetect

Requirements: A base installation of Perl, and [any Un*x or OS/X](https://github.com/DeeNewcum/termdetect/blob/master/doc/tested_on.txt).

## Ways to use it

Some possible ways to use termdetect:

````bash
# ~/.bashrc
export TERM=$(termdetect -t)
````

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

Most people have learned to mistrust $TERM and terminfo, and so hard-code everything.  Once you're able to trust them again, your configuration can be much more flexible and adaptive.

## Documentation

* run <tt>termdetect --help</tt>
* see [doc/termmatch.md](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md)
