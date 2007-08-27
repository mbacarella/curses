# $Id: Makefile,v 1.7 2007/08/27 16:41:31 smimram Exp $

PACKAGE		:= ocaml-curses
VERSION		:= 1.0.1

OCAMLC		:= ocamlfind ocamlc
OCAMLOPT	:= ocamlfind ocamlopt
OCAMLMKLIB	:= ocamlmklib

CC		:= gcc
CFLAGS		:= -Wall -fPIC -DPIC
#CPP		:= cpp
CPP		:= $(CC) -x c -E

CURSES		:= ncurses

all: byte opt META

opt: mlcurses.cmxa

byte: libmlcurses.a mlcurses.cma

ml_curses.o: ml_curses.c functions.c
	$(OCAMLC) -ccopt "$(CFLAGS)" -c $<

libmlcurses.a: ml_curses.o
	$(OCAMLMKLIB) -o mlcurses $< -l$(CURSES)

mlcurses.cma: curses.cmo
	$(OCAMLMKLIB) -o mlcurses -linkall $^

mlcurses.cmxa: curses.cmx
	$(OCAMLMKLIB) -o mlcurses -linkall $^

curses.cmi: curses.mli
	$(OCAMLC) -c $^

curses.cmo: curses.ml curses.cmi functions.c keys.ml
	$(OCAMLC) -pp "$(CPP)" -c $<

curses.cmx: curses.ml curses.cmi functions.c keys.ml
	$(OCAMLOPT) -pp "$(CPP)" -c $<

test: test.ml mlcurses.cma libmlcurses.a
	$(OCAMLC) -o $@ mlcurses.cma $<

clean:
	rm -f *.cm* *.o *.a dll*.so test

META:	META.in
	sed \
	  -e 's/@PACKAGE@/$(CURSES)/' \
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

upload:
	rm -f $(PACKAGE)-$(VERSION).tar.gz.sig
	gpg -b $(PACKAGE)-$(VERSION).tar.gz
	scp $(PACKAGE)-$(VERSION).tar.gz{,.sig} \
	  rwmj@dl.sv.nongnu.org:/releases/ocaml-tmk
