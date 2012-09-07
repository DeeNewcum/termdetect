'tdect'  (Terminal Autodetect) is a tool that determines what terminal emulator it's currently attached to.

Why not just use $TERM?  Because it has often been changed/overwritten, particularly if you've SSH'd somewhere.

This tool does something akin to [browser sniffing](http://en.wikipedia.org/wiki/Browser_sniffing) -- it has its own database of how different terminals respond to different things, and it locates the closest match in its database.
