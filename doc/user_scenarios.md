The following are possible [user scenarios](http://en.wikipedia.org/wiki/Scenario_%28computing%29).  They are listed here to try to help determine what kinds of output the program should produce.

## Single exception

The user accesses her main server from several different computers, using different terminals.  Most of the time, the server's settings are good, but there is one terminal that she uses that she wants to tweak slightly.  Either it doesn't support something the others do, or it's the one standout that supports a nice feature that none of the others do.

How she uses this information is up to her — she might set the shell prompt differently, or change an environment variable that triggers a corresponding change in her .vimrc, etc.  All she wants is a way to identify the one outlier.

### Implementation

In this case, she doesn't necessarily need a global database to recognize her terminals.  She just wants to recognize the one, so she uses the <tt>--snapshot</tt> function to record the one terminal she's interested in, names the terminal with her own name, and triggers her extra functionality based on that.


## Single exception, already in the global database

Same as above, but in this case, the one exception she's interested in has already been cataloged by us; we can identify it correctly.

### Implementation

She just needs SOME identifier that uniquely identifies the one outlier.  She  doesn't care what it's name, we can totally make it up if we want.


## The results of one test

The user just wants to know whether the current terminal supports one capability.  She doesn't want or need to run a bunch of tests, she's just interested in one.  For instance, she wants to know if the current terminal is able to set the window title (or, at the very least, won't display garbled stuff to the user if you try).

### Implementation

If there's a specific test that termdetect has, we can just run that one test and return the results.  If there's NOT a test, then we'd have to do the complicated 1) run all termdetect tests, 2) find a matching terminfo entry, 3) look for that specific capability within that terminfo entry.  Because that's much more complicated, we would like to provide the shortcut to the user if possible.

This has been implemented via the <tt>--result</tt> option.


## Match a bundled terminfo database

The user uses many different computers, and doesn't trust the local terminfo files because they vary so much across machines.  So she puts termdetect in her [centralized dotfile repo](https://github.com/search?utf8=%E2%9C%93&q=dotfiles&repo=&langOverride=&start_value=1&type=Repositories&language=), and asks termdetect to choose the most appropriate terminfo file for the specific terminal, whenever she logs in.

### Implementation

There are two possible ways:

1. when we look in our database to find a matching terminal, the terminal-IDs will be the same as the bundled terminfo database
2. we maintain a separate mapping from our terminal-ID to the appropriate bundled terminfo database name

We would probably use both options: The first when an individual terminal has its own dedicated entry in the terminfo database, and the second when the best terminfo entry is a generic entry that works for multiple terminals.

Termdetect would accomplish this by setting the [$TERMINFO environment variable](http://tldp.org/HOWTO/Text-Terminal-HOWTO-16.html).


## Match the local terminfo database

The user doesn't want to use the terminfo database that's bundled with our program, instead she wants to use her local OS's terminfo database.  (or any other terminfo database that she points to)

### Implementation

There are two ways to do this:

1. The long way: A) run all termdetect tests, B) find the closest matching terminal-ID in termdetect's own database, C) find the corresponding entry in our bundled terminfo, D) compare terminfo entries in the bundled and local terminfos and find the closest match.
2. If we know that the local terminfo uses the same nomenclature as the bundled terminfo (and thus, also of our termdetect's own database), then after step B, we can just look for that name in the local terminfo database.
