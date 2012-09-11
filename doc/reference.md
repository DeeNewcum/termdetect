## Available request/response sequences

* [MS-DOS Kermit 3.13 Terminal Emulator Technical Summary](http://www.columbia.edu/kermit/ftp/a/msvibm.vt), section "VT320 Report Requests and Responses"
* there are various sections in [vttest](http://invisible-island.net/vttest/) that reference reporting codes:
 * terminal reports
 * non-VT100 terminals > XTerm > reporting functions
 * non-VT100 terminals > XTerm > window report-operations

## Behavior in edge cases

* [console codes(4) man page](http://www.kernel.org/doc/man-pages/online/pages/man4/console_codes.4.html), section "Comparisons With Other Terminals > Escape Sequences"
* [vttest](http://invisible-island.net/vttest/) — a script that tests conformance to the VT100 spec
* "VT100 Magic", by Sami Tabih, Proceedings of the DEC Users Society, St. Louis, Missouri, May 1983  (referenced in vttest's "known bugs" section)
* [Mosh discussion of UTF-8, and UTF8 + ISO2022 interactions](http://mosh.mit.edu/#techinfo)

## General

* http://vt100.net/ — lots of original manuals
 * VT510, [ANSI control function](http://www.vt100.net/docs/vt510-rm/chapter4#S4.6) section
* [Xterm Control Sequences](http://www.xfree86.org/current/ctlseqs.html)
* [console codes(4) man page](http://www.kernel.org/doc/man-pages/online/pages/man4/console_codes.4.html), for the linux kernel VT console
* GNU screen manual, [console sequences section](http://www.gnu.org/software/screen/manual/html_node/Control-Sequences.html)
* [ECMA-48](http://www.ecma-international.org/publications/standards/Ecma-048.htm)  (first adopted in 1976)
* [Thomas E. Dickey's website: invisible-island.net](http://invisible-island.net/) — he maintains 'xterm', 'vttest', and 'ncurses' (which contains the most up-to-date package of terminfo entries)

## Canonical sequence names

Is there a list of canonical names for various ANSI sequences?

* terminfo capability names — [terminfo(5) man page](http://www.manpages.info/linux/terminfo.5.html)
* [ECMA-48](http://www.ecma-international.org/publications/standards/Ecma-048.htm)  (first adopted in 1976)
* [mnemonic listed in the VT510 manual](http://www.vt100.net/docs/vt510-rm/chapter4#S4.6)

## Canonical terminal names

Is there a list of canonical names for various terminals / terminal emulators?

* [the most actively-maintained terminfo database](http://invisible-island.net/ncurses/ncurses.faq.html#which_terminfo).  Although some entries are generic, there are some terminal-specific entries, such as putty, linux console, DOS ansi.sys, rxvt, aterm, gnome (vte), etc.
