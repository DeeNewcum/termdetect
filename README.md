## termdetect

<p align="center">
  <img src="http://deenewcum.github.com/termdetect/images/termdetect_putty.png"/>
</p>

termdetect is a tool that auto-detects which terminal you're using (eg. Putty, Xterm, Konsole).  It's typically used by server-side scripts that want to tailor their behavior to specific terminals. Termdetect does its job by communicating directly with the terminal via escape codes, and doesn't use any other information, so it's much more reliable than $TERM.

There are various ways to use it, but one thing it can do is automatically set your $TERM:

````bash
export TERM=$(termdetect -t)
````

## How does it work?

Terdetect figures out a "fingerprint" of the current terminal by sending [various ANSI escape codes](https://github.com/DeeNewcum/termdetect/blob/master/doc/fingerprint_db.md#r_-capabilities-%E2%80%94-requestreply-tests) to the terminal and seeing how the terminal responds.  It looks up the fingerprint in a [database of known terminal fingerprints](https://github.com/DeeNewcum/termdetect/blob/master/src/fingerprints.src), and reports which terminal matches the fingerprint.

## Installation

    curl -L http://is.gd/termdetect -o termdetect;  chmod +x termdetect
        or
    wget http://is.gd/termdetect;  chmod +x termdetect

Requirements: A base installation of Perl, and [any Un*x or OS/X](https://raw.github.com/DeeNewcum/termdetect/master/doc/tested_on.txt).

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
