If you want to add or modify fingerprints in the fingerprint database: 

Check if you're using the single-file version of termdetect.  Open the <tt>termdetect</tt> script in an editor, and if it says "FatPack" at the top, then you're using the single-file version.

If you're using the single-file version, then you'll have to [download the existing database](https://github.com/DeeNewcum/termdetect/raw/release/src/fingerprints.src) as a separate file before you can modify it.  If you simply place your updated fingerprints in an empty file, then the existing known fingerprints will become unavailable.

The fingerprints.src file can be placed in three possible places:

* <tt>fingerprints.src</tt>, located in the same directory as the <tt>termdetect</tt> script
* <tt>~/.fingerprints.src</tt>
* <tt>/etc/fingerprints.src</tt>

Items higher in the list take precedence.

To capture your own fingerprint, run <tt>termdetect --snapshot</tt>, and cut-n-paste the output to the fingerprints.src file.
