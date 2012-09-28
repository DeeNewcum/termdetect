If the termdetect database doesn't know about a particular terminal, Users are encouraged to capture the output of termdetect and send them in.

## Adding new terminal entries — snapshot

The quickest way is just to use termdetect's "snapshot" feature:

    ./termdetect --snap "terminal_name"

## Adding new terminal entries -- manual tweaks

To generate a entry that's useful to many people, it's best to manually edit the snapshot file and change a few things:

* version_dot_1 -- indicate where to place the first decimal in the version number
* version_dot_2 -- indicate where to place the second decimal in the version number


