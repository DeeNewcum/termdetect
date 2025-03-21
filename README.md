```diff
- STATUS: No significant updates since 2016. This code should be considered to be
-         abandoned and no longer working. However, it did successfully work at
-         one point. (see "current status" below)
```

## homepage: [https://deenewcum.github.io/termdetect/](https://deenewcum.github.io/termdetect/)

<p align="center">
  <img src="http://deenewcum.github.io/termdetect/images/termdetect_putty.png"/>
</p>

Termdetect is a script that auto-detects which terminal you're using (eg. Putty, Xterm, Konsole). It does its job solely by communicating with the terminal via escape codes, so it's much more reliable than $TERM, and connecting remotely never causes a problem.

**Current status:** Fingerprints are more brittle than I originally thought they might be; they vary due to terminal version number as well as terminal settings changes. It ended up being somewhat labor-intensive to keep the signatures updated for each new version of each terminal that was released.

This software ran somewhat well (albeit as alpha-quality software) back in 2016. Since then, the fingerprint database hasn't been updated in so long that I consider this software no longer functional.

I consider the underlying design to be pretty sound and practical. It should be possible to get the signature database back up and running on current versions of each terminal, however that would take a lot of work. Currently I'm not planning to put the effort in to get it resurrected.
