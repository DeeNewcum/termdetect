The $TERM variable is handy because it gets passed between machines when you SSH.  At best though, it's a crude approximation of the terminal you're using.  $TERM often gets overwritten by intermediate startup scripts.  And at worst, you just set it to "vt100" to get things minimally working.

What if don't just want things minimally working, but you want things to work *well*?

Fortunately, there are some request/reply ANSI sequences that give us bits of information about the terminal.  This program interrogates the terminal, looks up the responses in a database of known terminals, and finds the closest match.  This allows your remote machine to know *exactly* what terminal it's talking to.

# Current status

Completed:

* Some good routines have been written to perform individual ANSI sequence queries on the terminal.
* Quite a few request/reply ANSI sequences have been identified.  (there is still more work to do for more obscure ones, but the broadly-supported ones are identified)
* Responses from 9 terminals have been collected in an ad-hoc database.  (see "results.csv")

Not completed:

* The ad-hoc database needs to be converted into a standardized machine-readable database.
* We need to nail down exactly how we'll match the query responses to the machine-readable database.
* We need to figure out exactly what sort of output would be most useful to the end user.
