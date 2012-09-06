## Legend
* X = not supported
* [+2] = not supported;  the terminal supports it so badly that the text is unintentionally displayed to the user, and the cursor shifts over N positions


## To find the version of a specific emulator:
* libvte — run <tt>readelf -d $(which gnome-terminal)</tt>
* Linux VT console — the console driver is [part of the kernel](http://www.kernel.org/doc/man-pages/online/pages/man4/console_codes.4.html), so just use the kernel version
