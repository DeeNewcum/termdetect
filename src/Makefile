# Created a self-contained single-file version.  All modules are included in the single-file
# version.  This way, all someone needs to do to try it out is wget a single file.
# 
# All this is done thanks to App::FatPacker.


all:	termdetect.fatpacked termping.fatpacked

termdetect.fatpacked:	termdetect *.pm
	@# we manually create lib/ and fatlib/, because we know for sure that we don't need any
	@# external libraries
	@mkdir lib
	@mkdir fatlib
	@cp *.pm lib
	@echo "package FingerprintDB; sub fingerprint_db {join '', <DATA>}; 1" > lib/FingerprintDB.pm
	@echo "__DATA__"                                                      >> lib/FingerprintDB.pm
	@cat fingerprints.src                                                 >> lib/FingerprintDB.pm
	@echo "$$FATPACK_HEADER" > termdetect.fatpacked
	fatpack file            >> termdetect.fatpacked
	@cat termdetect         >> termdetect.fatpacked
	@chmod +x termdetect.fatpacked
	@rm lib/*
	@rmdir fatlib lib


termping.fatpacked:	termping Termdetect_IO.pm
	@# we manually create lib/ and fatlib/, because we know for sure that we don't need any
	@# external libraries
	@mkdir lib
	@mkdir fatlib
	@cp Termdetect_IO.pm lib
	@echo "$$FATPACK_HEADER" > termping.fatpacked
	fatpack file            >> termping.fatpacked
	@cat termping           >> termping.fatpacked
	@chmod +x termping.fatpacked
	@rm lib/*
	@rmdir fatlib lib

clean:
	@rm lib/*                  2>/dev/null    || true
	@rmdir fatlib lib          2>/dev/null    || true
	@rm termdetect.fatpacked   2>/dev/null    || true
	@rm termping.fatpacked     2>/dev/null    || true






define FATPACK_HEADER
#!/usr/bin/env perl
#
# This file is generated code.
# Please DO NOT EDIT or send patches for it.
#
# The source is available at:
#    https://github.com/DeeNewcum/termdetect
# Submit patches against the individual files that build it.
#
#
# You may redistribute this program and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Copyright (C) 2014  Dee Newcum
 



endef

export FATPACK_HEADER


