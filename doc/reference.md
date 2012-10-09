## Available request/response sequences

* [MS-DOS Kermit 3.13 Terminal Emulator Technical Summary](http://www.columbia.edu/kermit/ftp/a/msvibm.vt), section "VT320 Report Requests and Responses"
* there are various sections in [vttest](http://invisible-island.net/vttest/) that reference reporting codes:
 * terminal reports
 * non-VT100 terminals > XTerm > reporting functions
 * non-VT100 terminals > XTerm > window report-operations

## Behavior in edge cases

* [What X3.64 Doesn’t Say](http://www.vt100.net/emu/dec_ansi_parser#GAPS), part of the excellent vt100.net state machine
* [Mosh: An Interactive Remote Shell for Mobile Clients](http://mosh.mit.edu/mosh-paper-draft.pdf), section 3.3 "The Challenge of Unicode"
* [tack](http://invisible-island.net/ncurses/tack/tack.html) — a tool that helps to build or verify a terminfo entry
* [console codes(4) man page](http://www.kernel.org/doc/man-pages/online/pages/man4/console_codes.4.html), section "Comparisons With Other Terminals > Escape Sequences"
* [console codes(4) man page](http://www.kernel.org/doc/man-pages/online/pages/man4/console_codes.4.html#BUGS), section "Bugs"
* [vttest](http://invisible-island.net/vttest/) — a script that tests conformance to the VT100 spec
* ["Illegal and ambiguous sequences in use" on Wikipedia](http://en.wikipedia.org/wiki/ANSI_escape_code#Illegal_and_ambiguous_sequences_in_use)
* "VT100 Magic", by Sami Tabih, Proceedings of the DEC Users Society, St. Louis, Missouri, May 1983  (referenced in vttest's "known bugs" section)
* [Mosh discussion of UTF-8, and UTF8 + ISO2022 interactions](http://mosh.mit.edu/#techinfo)
* [Soft hyphen (SHY) – a hard problem?](http://www.cs.tut.fi/~jkorpela/shy.html)

## General

Terminals:
* http://vt100.net/ — lots of original manuals
 * VT510, [ANSI control function](http://www.vt100.net/docs/vt510-rm/chapter4#S4.6) section
* [Xterm Control Sequences](http://www.xfree86.org/current/ctlseqs.html)
* [console codes(4) man page](http://www.kernel.org/doc/man-pages/online/pages/man4/console_codes.4.html), for the linux kernel VT console
* GNU screen manual, [console sequences section](http://www.gnu.org/software/screen/manual/html_node/Control-Sequences.html)
* [ECMA-48](http://www.ecma-international.org/publications/standards/Ecma-048.htm)  (first adopted in 1976)

Terminfo:
* [terminfo(5) man page](http://www.manpages.info/linux/terminfo.5.html)
* to show a compiled terminfo entry: <tt>[infocmp](http://man.cx/infocmp) -l -1 $terminal</tt>

Other good resources:
* [Thomas E. Dickey's website: invisible-island.net](http://invisible-island.net/) — he maintains 'xterm', 'vttest', and 'ncurses' (which contains the most up-to-date package of terminfo entries)

## Canonical sequence names

Is there a list of canonical names for various ANSI sequences?

* terminfo capability names — [terminfo(5) man page](http://www.manpages.info/linux/terminfo.5.html)
* [ECMA-48](http://www.ecma-international.org/publications/standards/Ecma-048.htm)  (first adopted in 1976)
* [mnemonic listed in the VT510 manual](http://www.vt100.net/docs/vt510-rm/chapter4#S4.6)

## Canonical terminal names

Is there a list of canonical names for various terminals / terminal emulators?

* [the most actively-maintained terminfo database](http://invisible-island.net/ncurses/ncurses.faq.html#which_terminfo).  Although some entries are generic, there are some terminal-specific entries, such as putty, linux console, DOS ansi.sys, rxvt, aterm, gnome (vte), etc.

## Canonical character-encoding names

Is there a list of canonical names for various character encodings?

* for Perl, run <tt>perl -MData::Dumper -MEncode -le 'print Dumper [Encode->encodings(":all")]'</tt>
* what LANG/LC_ALL/etc use.  See [The Open Group Base Specifications Issue 6, section 8.3](http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap08.html#tag_08_02)
  * Unfortunately, that says "settings of language, territory, and codeset are implementation-defined".
  * in Linux, language/territory/codeset are defined in [setlocale(3)](http://manpages.ubuntu.com/manpages/precise/en/man3/setlocale.3.html)
  * just run <tt>locale -a</tt>, and run <tt>locale -m</tt> to see the list of codesets
  * "[There are no standard for codeset and modifier](http://www.debian.org/doc/manuals/intro-i18n/ch-locale.en.html)"
* [how to list the available locales on different OS's](http://perldoc.perl.org/perllocale.html#Finding-locales)
* [Encode::Locale](https://metacpan.org/module/Encode::Locale) will translate the OS's name to Perl's own name
  * it internally uses [I18N::Langinfo](https://metacpan.org/module/I18N::Langinfo)  (on Unix systems anyway)
  * and I18N::Langinfo simply calls [nl_langinfo()](http://manpages.ubuntu.com/manpages/precise/man3/nl_langinfo.3.html)

Background info:

* [a good intro on what a "locale" is](http://perldoc.perl.org/perllocale.html)

## Scope of all possible escape codes, from a lexer standpoint

Is there any sort of standard-ish document that suggests the total possible scope?

* http://www.vt100.net/emu/dec_ansi_parser — very complete, I think
* ["The Ecma-35 / ISO/IEC 2200 standard defines an escape sequence to be a sequence of characters beginning with esc, with a final byte in the range x30–x7E, and any number (including zero) of intermediate bytes in the range x20-x2F."](http://www.gnu.org/software/teseq/manual/html_node/Escape-Sequence-Recognition.html)
* http://en.wikipedia.org/wiki/ANSI_escape_code#Sequence_elements
* http://bjh21.me.uk/all-escapes/all-escapes.txt section "Description: Escape".  It says: "in summary, m# \e [\x20 - /]*  [0 - ~]  #x"
* http://www.vt100.net/emu/fingers/  though they're a little difficult to decipher

## Terminfo 

The terminfo database that we bundle is the [one that comes with ncurses](http://invisible-island.net/ncurses/ncurses.faq.html#which_terminfo).

To quickly survey the terminfo:

    perl -nle 'print "" if /^####/; print if /^[^# \t]|^####/' terminfo.src

Or use the enclosed script 'terminfo_summarize'.
