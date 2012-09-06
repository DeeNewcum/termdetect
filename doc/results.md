"results.csv" is a table of results collected so far.  Below is additional information related to results.csv:

## Legend
* X = not supported
* [+2] = not supported;  the terminal supports it so badly that the text is unintentionally displayed to the user, and the cursor shifts over N positions

## To find the version of a specific emulator:
* libvte — run <tt>readelf -d $(which gnome-terminal)</tt>
* Linux VT console — the console driver is [part of the kernel](https://github.com/torvalds/linux/blob/master/drivers/tty/vt/vt.c), so just use the kernel version
