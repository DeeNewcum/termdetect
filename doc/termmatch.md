The 'termmatch.src' file is the database of known terminals that termdetect uses to determine what the current terminal is.

## Syntax

Termmatch files have the *exact* same syntax as terminfo files, with only a few differences:

* capability names are different  (and often longer)
* percent syntax is entirely different

The terminal names used in termmatch files should be the exact same as is used in terminfo files.  The $TERM names in the built-in termmatch files are designed to correspond to the $TERM names in the [terminfo database that comes with ncurses](http://invisible-island.net/ncurses/ncurses.faq.html#which_terminfo), because it's one of the most up-to-date terminfo files.

## Percent codes

Percent codes may sometimes look like termcap entries, but they have completely different meanings:

<table>

<tr><td><tt>%x+[0-9]
    <td>The terminal responded by moving the cursor right N positions. (often because it printed some characters)

<tr><td><tt>%*
    <td>Matches zero or more of *any* character.   (it's not a regexp, so you don't have to put anything like a "%." in front)

<tr><td><tt>%+
    <td>Matches one or more of *any* character.  (it's not a regexp, so you don't have to put anything like a "%." in front)

<tr><td><tt>%%
    <td>a way to specify just the "%" character

</table>

The empty string means that nothing happened — no characters were received, and no cursor movement occurred.

## Capability names (tests)

Unfortunately, there is very little overlap between terminfo capabilities and termmatch capabilities, so these names are unique to termmatch files.

Within termmatch files, "capabilities" can also be called "tests" — each refers to a specific test performed on the terminal.

### r_* capabilities — Request/Reply tests

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
    <td><tt>\e[?15n
    <td><tt>\e[?10n
    <td>

<tr><td><tt>r_term_id
    <td>DCID, identify terminal
    <td><tt>\eZ
    <td>
    <td>vt510

<tr><td><tt>r_device_attr
    <td>DA, primary device attributes
    <td><tt>\e[c
    <td><tt>\e[?62;9;c
    <td>xterm

<tr><td><tt>r_device_attr2
    <td>DA2, secondary device attributes
    <td><tt>\e[>c
    <td><tt>\e[>1;2600;0c
    <td>xterm

<tr><td><tt>r_device_attr3
    <td>DA3, tertiary device attributes
    <td><tt>\e[=c
    <td>?
    <td>vt510

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
    <td>DECXCPR, extended cursor position report
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
    <td><tt>\e]L</tt>...<tt>\e\\
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

<tr><td><tt>r_window_size_char
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

### m_* capabilities — tests whose only goal is to detect cursor Movement

There are three main ways that a terminal emulator chooses to respond to an ANSI code:

1. SUPPORTED.  The code is minimally supported — the terminal changes a setting or moves the cursor, or does something in response.
2. HIDDEN.  The code isn't supported at all, but the terminal recognizes it as ANSI code that another terminal would support, so it hides it from the user, but does nothing else with the code.
3. DISPLAYED.  The code isn't supported.  Further, the terminal doesn't even recognize it as a legitimate ANSI code, and it displays some or all of the sequences's characters to the user.

We can detect group #3 by watching for cursor movement, using the CPR (cursor position report) sequence.

Group #3 happens because there is no standard or agreement on the format of all possible ANSI sequences.  Terminal programmers want to be conservative and not hide anything that was intended to be displayed.  (okay, there is [this carefully-researched document describing the DEC VT500 behavior](http://www.vt100.net/emu/dec_ansi_parser), but it isn't very well-known.  Also, VT500-compatibility may not be the highest priority)

<table>

<tr><th>capability name
    <th>other names
    <th>test
    <th>reference

<tr><td><tt>m_c1
    <td>is the C1 character set supported?<br>C1-CSI version of erase to EOL
    <td><tt>\x9b0k
    <td>c0_c1

<tr><td><tt>m_pad_null
    <td>padding
    <td><tt>\x00
    <td>terminfo

<tr><td><tt>m_pad_c1
    <td>padding, C1 version
    <td><tt>\0200
    <td>terminfo<br>c0_c1

<tr><td><tt>m_null_inside
    <td>
    <td><tt>\e\x00K
    <td>

<tr><td><tt>m_cancel
    <td>CAN, cancel character
    <td><tt>\e[?\x18
    <td>vt510

<tr><td><tt>m_sub
    <td>SUB, substitute character
    <td><tt>\e[?\x1A
    <td>vt510

<tr><td><tt>m_esc
    <td>ESC, escape character in the middle of a sequence
    <td><tt>\e[?\eK
    <td>

</table>

### s\_\* capabilities — Synthetic tests, tests that are more complicated than r\_\* or m\_\*

Some tests have custom code written for each test.  Their behavior may be more complicated, so each is described in more detail below.

<table>
<tr><th>capability name
    <th>description

<tr><td><tt>s_ff_clears
    <td>Does the form-feed character (^L) clear the screen?  ("true" or "false")

<tr><td><tt>s_term_version
    <td>The specific version number of the terminal.  See also <tt>c_version_decimalplaces</tt>.

<tr><td><tt>s_window_title
    <td>Only available on terminals that support <tt>r_window_title</tt>.

<tr><td><tt>s_char_encoding
    <td>The current character-encoding setting.

<tr><td><tt>s_font_size
    <td>Useful mainly for <tt>--results</tt>.  The size of each character, in pixels.  The format is "width x height".  Only available on terminals that support <tt>r_window_size_px</tt> and <tt>r_window_size_char</tt>.

<tr><td><tt>s_screen_size
    <td>Useful mainly for <tt>--results</tt>.  The size of the screen, in pixels.  Only available on terminals that support <tt>r_window_size_px</tt> and <tt>r_window_size_char</tt> and <tt>r_screen_size</tt>.

</table>

### References

Documents referenced:

* vt102 — [VT102 User Guide, Appendix C](http://vt100.net/docs/vt102-ug/appendixc.html)
* vt510 — [VT510 Video Terminal Programmer Information](http://www.vt100.net/docs/vt510-rm/chapter4#S4.6)
* xterm — [Xterm Control Sequences](http://www.xfree86.org/current/ctlseqs.html)
* all — [all-escapes.txt from bjh21 (Ben Harris)](http://bjh21.me.uk/all-escapes/all-escapes.txt)
* c0_c1 — [wikipedia's article on "C0 and C1 control codes"](http://en.wikipedia.org/wiki/C0_and_C1_control_codes#C0_.28ASCII_and_derivatives.29)
* terminfo — [terminfo(5) man page](http://invisible-island.net/ncurses/man/terminfo.5.html)

