The $TERM variable is handy because it gets passed between machines when you SSH.  At best though, it's a crude approximation of the terminal you're using.  $TERM often gets overwritten by intermediate startup scripts.  And at worst, you just set it to "vt100" to get things minimally working.

What if don't just want things minimally working, but you want things to work *well*?

Fortunately, there are [some request/reply ANSI sequences](https://github.com/DeeNewcum/termdetect/blob/master/doc/termmatch.md) that give us bits of information about the terminal.  This program looks up the responses in a database of known terminals and finds the closest match.  This allows your remote machine to know *exactly* what terminal it's talking to.

    $ termdetect
    teraterm4.59
    
    $ export TERM=$(termdetect -t)

    $ termping 
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)
       1 ms    (min 1,  max 1,   avg 1.0)

    # ^^ from this, we can surmise that the end-user's terminal is located on the same machine, or in close physical proximity to it
