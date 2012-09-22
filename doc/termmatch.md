Termmatch files have the *exact* same syntax as terminfo files, with only a few differences:

* capability names are different  (and often longer)
* percent syntax is entirely different

Terminal names in termmatch files are intended to align with the terminal names in terminfo files.  The built-in termmatch files are intended to align with the [terminfo database that comes with ncurses](http://invisible-island.net/ncurses/ncurses.faq.html#which_terminfo), because it's one of the most up-to-date.

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

## Capability names

Unfortunately, there is very little possible overlap between terminfo capabilities and termmatch capabilities.  Here's the documentation for termmatch capabilities:

<table>

<tr><th>capability
    <th>other names
    <th>test consists of
    <th>see reference

<tr><td><tt>device_status
    <td>DSR, device status report
    <td><tt>\e[?5n
    <td>

<tr><td><tt>printer_status
    <td>printer variant of DSR
    <td><tt>\e?15n
    <td>

<tr><td><tt>device_attr
    <td>DA, primary device attributes
    <td><tt>\e[c
    <td>

<tr><td><tt>device_attr2
    <td>DA2, secondary device attributes
    <td><tt>\e[>c
    <td>

<tr><td><tt>device_attr3
    <td>DA3, tertiary device attributes
    <td><tt>\e[=c
    <td>

<tr><td><tt>term_param
    <td>DECREQTPARM, request terminal parameters
    <td><tt>\e[x
    <td>

<tr><td><tt>enquiry
    <td>ENQ, enquiry character
    <td><tt>\x05
    <td>c0_c1

<tr><td><tt>ext_cursor_pos
    <td>extended cursor position report
    <td><tt>\e[?6n
    <td>vt510

<tr><td><tt>window_title
    <td>report window title
    <td><tt>\e[21t
    <td>xterm

<tr><td><tt>window_icon_label
    <td>report window icon label
    <td><tt>\e[20t
    <td>xterm

<tr><td><tt>window_size_px
    <td>window size in pixels
    <td><tt>\e[14t
    <td>xterm

<tr><td><tt>window_size_chr
    <td>window size in characters
    <td><tt>\e[18t
    <td>xterm

<tr><td><tt>window_pos
    <td>window position in pixels
    <td><tt>\e[13t
    <td>xterm

<tr><td><tt>window_state
    <td>window state (iconified or no)
    <td><tt>\e[11t
    <td>xterm

<tr><td><tt>screen_size
    <td>screen size in characters
    <td><tt>\e[19t
    <td>xterm

<tr><td><tt>c1
    <td>is the C1 character set supported?<br>C1 version of erase to EOL
    <td><tt>\x9b0k
    <td>c0_c1

</table>

Documents referenced:

* vt510 — [VT510 Video Terminal Programmer Information](http://www.vt100.net/docs/vt510-rm/chapter4#S4.6)
* xterm — [Xterm Control Sequences](http://www.xfree86.org/current/ctlseqs.html)
* c0_c1 — [wikipedia's article on "C0 and C1 control codes"](http://en.wikipedia.org/wiki/C0_and_C1_control_codes#C0_.28ASCII_and_derivatives.29)

