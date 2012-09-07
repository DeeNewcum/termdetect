Some ANSI responses require some decoding to understand.

## Primary device attributes

Parameter position doens't matter.  Each describes some attribute of the device.  These mean:

* 1 — 132 columns
* 2 — Printer port
* 4 — Sixel
* 6 — Selective erase
* 7 — Soft character set (DRCS)
* 8 — User-defined keys (UDKs)
* 9 — National replacement character sets (NRCS) (International terminal only)
* 12 — Yugoslavian (SCS)
* 15 — Technical character set
* 18 — Windowing capability
* 21 — Horizontal scrolling
* 23 — Greek
* 24 — Turkish
* 42 — ISO Latin-2 character set
* 44 — PCTerm
* 45 — Soft key map
* 46 — ASCII emulation

## Secondary device attributes

* first param — terminal type (0=VT100, 1=VT220, 83=GNU Screen)
* second param — firmware version (for example, the VT510 returns "10" to mean v1.0, and "20" to mean v2.0)
* third param — "0c" = STD keyboard option, "1c" = PC keyboard option

## Tertiary device attributes

This is a [unique ID](http://www.vt100.net/docs/vt510-rm/DA3), akin to a serial number or MAC address.

## Terminal parameters

* first param — parity
* second param — number of bits
* third param — transmit speed (0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128 correspond to speeds of 50,75,110,134.5,150,200,300,600,1200,1800,2000,2400,3600,4800,9600,19200, and 38400 baud or above)
* fourth param — receive speed
* fifth param — clock multiplier
* sixth param — flags (0-15)
