
# create the fatpacked version of termdetect


all:	termdetect.fatpacked

termdetect.fatpacked:	termdetect
	# we manually create lib/ and fatlib/, because we know for sure that we don't need any
	# external libraries
	mkdir lib
	mkdir fatlib
	cp *.pm lib
	echo "#!/usr/bin/perl" > termdetect.fatpacked
	fatpack file          >> termdetect.fatpacked
	cat termdetect        >> termdetect.fatpacked
	chmod +x termdetect.fatpacked
	rm lib/*
	rmdir fatlib lib

clean:
	-rm lib/*
	-rmdir fatlib lib
	-rm termdetect.fatpacked
