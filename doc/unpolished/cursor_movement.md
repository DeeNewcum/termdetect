Things that can cause cursor movement:

## ANSI sequences

TODO.  For now, look at the 'termdetect' source code.

## terminfo boolean capabilities

<table>
<tr><th>cap name    <th>full name       <th>widespread?     <th>meaning
<tr><td>am      <td>auto_right_margin   <td>good mix    <td>when the cursor pushes against the right edge of the screen, it automatically wraps to the next line
<tr><td>bw      <td>auto_left_margin    <td>good mix    <td>when the cursor pushes against the left edge of the screen, it automatically jumps to the right side of the screen
<tr><td>xhpa    <td>col_addr_glitch     <td>good mix    <td>??
<tr><td>xenl    <td>eat_newline_glitch  <td>good mix    <td>??
<tr><td>in      <td>insert_null_glitch  <td>too rare    <td>
<tr><td>mir     <td>move_insert_mode    <td>good mix    <td>?
<tr><td>msgr    <td>move_standout_mode  <td>good mix    <td>?
<tr><td>npc     <td>no_pad_char         <td>borderline  <td>??
</table>

## appendicies

To tell how widespread a capability is, run 'tic' on the ncurses terminfo.src file (which will populate your ~/.terminfo/ directory), and then run this:

    find ~/.terminfo -type f | perl -ple 's#^.*/##' | sort | perl -nle 'my $tf = (`infocmp -1 $_` =~ /^\s+msgr,$/m) ? "Y" : " "; print "$tf $_"' | less

(here, 'msgr' is the capability being scanned for)
