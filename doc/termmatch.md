Termmatch files have the *exact* same syntax as terminfo files, with only a few differences:

* capability names are different  (and often longer)
* percent syntax is entirely different

Terminal names in termmatch files should be the same as in terminfo files.  The $TERM names in the built-in termmatch files are designed to correspond to the $TERM names in the [terminfo database that comes with ncurses](http://invisible-island.net/ncurses/ncurses.faq.html#which_terminfo), because it's one of the most up-to-date.

## Percent codes

Percent codes may sometimes look like termcap entries, but they have completely different meanings:

<table>

<tr><td><tt>%!
    <td>The terminal sent no text in response.

<tr><td><tt>%x[0-9]
    <td>The terminal responded by moving the cursor right N positions. (often because it printed some characters)

<tr><td><tt>%*
    <td>The terminal responded with SOME text.  This is the opposite of <tt>%!</tt>.

</table>

## Capability names (tests)

Unfortunately, there is very little overlap between terminfo capabilities and termmatch capabilities, so these names are unique to termmatch files.

Within termmatch files, "capabilities" can also called "tests" — each refers to a specific test performed on the terminal.

### r_* capabilities — [R]equest/[R]eply tests

<table>

<tr><th>capability name
    <th>other names
    <th>request
    <th>example reply
    <th>reference

<tr><td><tt>r_device_status
    <td>DSR, device status report
    <td><tt>\e[?5n
    <td><tt>\e[0n
    <td>

<tr><td><tt>r_printer_status
    <td>printer variant of DSR
    <td><tt>\e?15n
    <td><tt>\e[?10n
    <td>

<tr><td><tt>r_device_attr
    <td>DA, primary device attributes
    <td><tt>\e[c
    <td><tt>\e[?62;9;c
    <td>

<tr><td><tt>r_device_attr2
    <td>DA2, secondary device attributes
    <td><tt>\e[>c
    <td><tt>\e[>1;2600;0c
    <td>

<tr><td><tt>r_device_attr3
    <td>DA3, tertiary device attributes
    <td><tt>\e[=c
    <td>?
    <td>

<tr><td><tt>r_term_param
    <td>DECREQTPARM, request terminal parameters
    <td><tt>\e[x
    <td><tt>\e[2;1;1;128;128;1;0x
    <td>

<tr><td><tt>r_enquiry
    <td>ENQ, enquiry character
    <td><tt>\x05
    <td><tt>PUTTY
    <td>c0_c1

<tr><td><tt>r_ext_cursor_pos
    <td>extended cursor position report
    <td><tt>\e[?6n
    <td><tt>\e[25;80;2R
    <td>vt510

<tr><td><tt>r_window_title
    <td>report window title
    <td><tt>\e[21t
    <td><tt>\e]l</tt>...<tt>\e\\
    <td>xterm

<tr><td><tt>r_window_icon_label
    <td>report window icon label
    <td><tt>\e[20t
    <td>?
    <td>xterm

<tr><td><tt>r_window_state
    <td>window state (iconified or no)
    <td><tt>\e[11t
    <td><tt>\e[1t
    <td>xterm

<tr><td><tt>r_window_pos
    <td>window position in pixels
    <td><tt>\e[13t
    <td><tt>\e[3;3;60t
    <td>xterm

<tr><td><tt>r_window_size_px
    <td>window size in pixels
    <td><tt>\e[14t
    <td><tt>\e[4;681;1005t
    <td>xterm

<tr><td><tt>r_window_size_chr
    <td>window size in characters
    <td><tt>\e[18t
    <td><tt>\e[8;25;77t
    <td>xterm

<tr><td><tt>r_screen_size
    <td>screen size in characters
    <td><tt>\e[19t
    <td><tt>\e[9;28;78t
    <td>xterm

</table>

### m_* capabilities — tests whose only goal is to detect cursor [M]ovement

For most tests we run, we do a CPR (cursor position report) just before the test, and just after.  This allows us to detect any time the cursor moves.  For many of these, the cursor moves because something (ie. the escape code itself) has been printed to the screen.

The escape sequences below are sequences that some terminal emulators choose to display, while others choose to hide.

<table>

<tr><th>capability name
    <th>other names
    <th>test
    <th>reference

<tr><td><tt>m_c1
    <td>is the C1 character set supported?<br>C1 version of erase to EOL
    <td><tt>\x9b0k
    <td>c0_c1

<tr><td><tt>m_pad_null
    <td>padding
    <td><tt>\x00
    <td>terminfo

<tr><td><tt>m_pad_200
    <td>padding
    <td><tt>\0200
    <td>terminfo

<tr><td><tt>m_cancel
    <td>CAN, cancel character
    <td><tt>\e[\x18
    <td>vt510

<tr><td><tt>m_sub
    <td>SUB, substitute character
    <td><tt>\e[\x1A
    <td>vt510

</table>

Documents referenced:

* vt510 — [VT510 Video Terminal Programmer Information](http://www.vt100.net/docs/vt510-rm/chapter4#S4.6)
* xterm — [Xterm Control Sequences](http://www.xfree86.org/current/ctlseqs.html)
* c0_c1 — [wikipedia's article on "C0 and C1 control codes"](http://en.wikipedia.org/wiki/C0_and_C1_control_codes#C0_.28ASCII_and_derivatives.29)
* terminfo — [terminfo(5) man page](http://invisible-island.net/ncurses/man/terminfo.5.html)

