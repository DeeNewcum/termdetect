The $TERM variable is handy because it gets passed between machines when you SSH.  At best though, it's a crude approximation of the terminal you're using.  $TERM often gets overwritten by intermediate startup scripts.  And at worst, you just set it to "vt100" to get things minimally working.

What if don't just want things minimally working, but you want things to work *well*?

Fortunately, there are some request/reply ANSI sequences that allow us to interrogate some parts of the terminal.  This program interrogates the terminal, and then looks up the responses in a database of known terminals, and find the closest match.  This allows you to know exactly what terminal you're talking to.

# Current status

Completed:

* Some good routines have been written to perform individual ANSI sequence queries on the terminal.
* Quite a few request/reply ANSI sequences have been identified.  (there is still more work to do for more obscure ones, but the broadly-supported ones are identified)
* An ad-hoc database of responses from 9 terminals has been created, to help get an idea of which ANSI sequences are most useful.  (see "results.csv")

Not completed:

* The ad-hoc database needs to be converted into a standardized machine-readable database.
* We need to nail down exactly how we'll match the query responses to the machine-readable database.
