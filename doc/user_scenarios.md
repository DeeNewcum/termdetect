The following are possible [user scenarios](http://en.wikipedia.org/wiki/Scenario_%28computing%29).  They are listed here to try to help determine what kinds of output the program should produce.

## Single exception

The user accesses her main server from several different computers, using different terminals.  Most of the time, the server's settings are good, but there is one terminal that she uses that she wants to tweak slightly.  Either it doesn't support something the others do, or it's the one standout that supports a nice feature that none of the others do.

How she uses this information is up to her — she might set the shell prompt differently, or change an environment variable that triggers a corresponding change in her .vimrc, etc.  All she wants is a way to identify the one outlier.

### Implementation

In this case, she doesn't necessarily need a global database to recognize her terminals.  She just wants to recognize the one, so she uses the "snapshot" function to record the one outlier, and tags it with her own custom name.

## Match a built-in terminfo database

The user uses many different computers, and doesn't trust the local terminfo files because they vary so much across machines.  So she puts termdetect in her [centralized dotfile repo](https://github.com/search?utf8=%E2%9C%93&q=dotfiles&repo=&langOverride=&start_value=1&type=Repositories&language=), and asks termdetect to choose the most appropriate terminfo file for the specific terminal, whenever she logs in.

### Implementation

????
