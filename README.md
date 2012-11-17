## termdetect

    $ termdetect
                terminal:   vte / gnome-terminal / xfce4-terminal
                 version:   libvte v0.32.1
                encoding:   utf8
           terminal size:   318 x 74   (characters)
               font size:   6 x 13   (pixels)
         window position:   5 x 81   (pixels)
             screen size:   3200 x 1080   (pixels)

termdetect is a tool that determine which terminal you're using (eg. Putty, Xterm, Konsole).  It does this by communicating directly with the terminal via escape codes, it doesn't use any other information.  Thus, it's much more reliable than $TERM.

There are various ways to use it, but one thing it can do is automatically set your $TERM:

````bash
export TERM=$(termdetect -t)
````

## How does it work?

Terdetect figures out a "fingerprint" of the current terminal by sending [various ANSI escape codes](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md#r_-capabilities-%E2%80%94-requestreply-tests) to the terminal and seeing how the terminal responds.  It looks up the fingerprint in a database of known terminal fingerprints, and reports which terminal matches the fingerprint.

## Installation

    curl -L http://is.gd/termdetect -o termdetect;  chmod +x termdetect
        or
    wget http://is.gd/termdetect;  chmod +x termdetect

Requirements: A base installation of Perl, and [any Un*x or OS/X](https://github.com/DeeNewcum/termdetect/blob/master/doc/tested_on.txt).

## Other ways to use it

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
* [online documentation](https://github.com/DeeNewcum/termdetect/blob/master/doc/README.md)

## License

GPL 2
