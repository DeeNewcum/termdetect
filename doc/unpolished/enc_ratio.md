The main goal is to find varations in the ratio:

        (number of bytes sent) : (number of spaces the cursor moves)

Things like tabs (more than one spaces horizontally) or newlines (*vertical* movement) would *seem* like a good idea.  Unfortunately, these are usually in the 0x00 - 0x7F range.  What WOULD be useful is if any of these "atypical cursor movement characters" can be found outside the lower-128 range.

Put simply, we are looking for:

        ATYPICAL MOTION IN ATYPICAL LOCATIONS

"Atypical motion" — The *overwhelming* majority of characters cause a cursor movement of x+1.  What we're looking for is *any* other kind of cursor movement. There are a variety of ways to induce other cursor movement:

* X+8 (tab)
* Y+1 (newline)
* X+0 (zero-width space)
* X-1 (backspace)

"Atypical locations" (atypical codepoints) — If we see X+8 movement for the 0x09 character, that doesn't give us any information, because lots of character encodings have that behavior there.   What we're looking for is tab behavior on anything OTHER than the characters it frequently occurs on.
