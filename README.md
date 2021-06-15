## homepage: [http://bit.ly/termdetect](http://deenewcum.github.com/termdetect/)

<p align="center">
  <img src="http://deenewcum.github.com/termdetect/images/termdetect_putty.png"/>
</p>

Termdetect is a script that auto-detects which terminal you're using (eg. Putty, Xterm, Konsole). It does its job solely by communicating with the terminal via escape codes, so it's much more reliable than $TERM, and connecting remotely never causes a problem.

**Current status:** Fingerprints are more brittle than I originally thought they might be; they vary due to terminal version number as well as terminal settings changes. Currently the fingerprints database is manually updated. I'm looking at ways to make this easier.
