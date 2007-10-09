# $Id: Makefile,v 1.11 2007/10/09 12:02:25 smimram Exp $

PACKAGE = ocaml-curses
VERSION = 1.0.3
CURSES = ncurses

RESULT = curses
SOURCES = ml_curses.c keys.ml curses.mli curses.ml

CFLAGS = -g -Wall
LIBINSTALL_FILES = $(wildcard *.mli *.cmi *.cma *.cmxa *.a *.so)
OCAMLDOCFLAGS = -stars

all: byte opt

opt: ncl META

byte: bcl META

install: byte libinstall

uninstall: libuninstall

test: test.ml byte
	$(OCAMLC) -I . -o $@ curses.cma $<

test.opt: test.ml opt
	$(OCAMLOPT) -I . -o $@ curses.cmxa $<

META: META.in
	sed \
	  -e 's/@PACKAGE@/curses/' \
	  -e 's/@VERSION@/$(VERSION)/' \
	  -e 's/@CURSES@/$(CURSES)/' \
	  < $< > $@

doc: htdoc

distclean: clean
	rm -rf doc/curses

# Distribution.

dist:
	$(MAKE) check-manifest
	rm -rf $(PACKAGE)-$(VERSION)
	mkdir $(PACKAGE)-$(VERSION)
	tar -cf - -T MANIFEST | tar -C $(PACKAGE)-$(VERSION) -xf -
	tar zcf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	rm -rf $(PACKAGE)-$(VERSION)
	ls -l $(PACKAGE)-$(VERSION).tar.gz

check-manifest:
	@for d in `find -type d -name CVS | grep -v '^\./debian/'`; \
	do \
	  b=`dirname $$d`/; \
	  awk -F/ '$$1 != "D" {print $$2}' $$d/Entries | \
	  sed -e "s|^|$$b|" -e "s|^\./||"; \
	done | grep -v \.cvsignore | sort > .check-manifest; \
	sort MANIFEST > .orig-manifest; \
	diff -u .orig-manifest .check-manifest; rv=$$?; \
	rm -f .orig-manifest .check-manifest; \
	exit $$r

# Upload to Savannah.

USER = $(shell whoami)

upload:
	rm -f $(PACKAGE)-$(VERSION).tar.gz.sig
	gpg -b $(PACKAGE)-$(VERSION).tar.gz
	scp $(PACKAGE)-$(VERSION).tar.gz{,.sig} \
	  $(USER)@dl.sv.nongnu.org:/releases/ocaml-tmk

include OCamlMakefile

.PHONY: doc
