
# create the fatpacked version of termdetect


all:	termdetect.fatpacked

termdetect.fatpacked:	termdetect
	@# we manually create lib/ and fatlib/, because we know for sure that we don't need any
	@# external libraries
	@mkdir lib
	@mkdir fatlib
	@cp *.pm lib
	@echo "$$FATPACK_HEADER" > termdetect.fatpacked
	fatpack file           >> termdetect.fatpacked
	@cat termdetect         >> termdetect.fatpacked
	@chmod +x termdetect.fatpacked
	@rm lib/*
	@rmdir fatlib lib

clean:
	@rm lib/*                  2>/dev/null    || true
	@rmdir fatlib lib          2>/dev/null    || true
	@rm termdetect.fatpacked   2>/dev/null    || true






define FATPACK_HEADER
#!/usr/bin/env perl
#
# This file is generated code.
# Please DO NOT EDIT or send patches for it.
#
# Please take a look at the source from
#    https://github.com/DeeNewcum/termdetect
# and submit patches against the individual files
# that build it.
#



endef

export FATPACK_HEADER


