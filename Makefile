# $Id: Makefile,v 1.9 2007/08/28 08:54:00 smimram Exp $

PACKAGE		:= ocaml-curses
VERSION		:= 1.0.2

OCAMLC		:= ocamlfind ocamlc
OCAMLOPT	:= ocamlfind ocamlopt
OCAMLMKLIB	:= ocamlmklib

CC		:= gcc
CFLAGS		:= -Wall -fPIC -DPIC
CPP		:= $(CC) -x c -E

CURSES		:= ncurses

all: byte opt META

opt: libcurses_stubs.a curses.cmxa

byte: libcurses_stubs.a curses.cma

ml_curses.o: ml_curses.c functions.c
	$(OCAMLC) -c -cc $(CC) -ccopt "$(CFLAGS)" -o $@ $<

libcurses_stubs.a: ml_curses.o
	$(OCAMLMKLIB) -o curses_stubs $^

curses.cma: curses.cmo ml_curses.o
	$(OCAMLC) -a -custom -dllib dllcurses_stubs.so -ccopt -l$(CURSES) -cclib -lcurses_stubs -o $@ $<

curses.cmxa: curses.cmx ml_curses.o
	$(OCAMLOPT) -a -ccopt -l$(CURSES) -cclib -lcurses_stubs -o $@ $<

curses.cmi: curses.mli
	$(OCAMLC) -c $^

curses.cmo: curses.ml curses.cmi functions.c keys.ml
	$(OCAMLC) -pp "$(CPP)" -c $<

curses.cmx: curses.ml curses.cmi functions.c keys.ml
	$(OCAMLOPT) -pp "$(CPP)" -c $<

test: test.ml curses.cma
	$(OCAMLC) -I . -o $@ curses.cma $<

test.opt: test.ml curses.cmxa
	$(OCAMLOPT) -I . -o $@ curses.cmxa $<

clean:
	rm -f *.cm* *.o *.a dll*.so test test.opt
	rm -rf doc/html

META: META.in
	sed \
	  -e 's/@PACKAGE@/curses/' \
	  -e 's/@VERSION@/$(VERSION)/' \
	  -e 's/@CURSES@/$(CURSES)/' \
	  < $< > $@

doc: $(wildcard *.mli)
	mkdir -p doc/html
	ocamldoc -html -stars -d doc/html $(wildcard *.mli)

install:
	ocamlfind install curses META $(wildcard *.cmi *.cmx *.cma *.cmxa *.a *.so *.mli)

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
	done | sort > .check-manifest; \
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

.PHONY: doc
