OCAMLC=ocamlc.opt
OCFLAGS=-I .. -g

OBJECTS=tmkStruct.cmo tmkArea.cmo tmkStyle.cmo tmkStyle_p.cmo tmkStyle_l.cmo \
tmkSignal.cmo tmkTerminal.cmo tmkMain.cmo \
tmkWidget.cmo tmkContainer.cmo tmkPacking.cmo \
tmkMisc.cmo tmkButton.cmo tmkList.cmo tmkEntry.cmo tmkFrame.cmo

%.cmi: %.mli
	$(OCAMLC) $(OCFLAGS) -c $<

%.cmo %.cmi: %.ml
	$(OCAMLC) $(OCFLAGS) -w m -c $<

tmk.cma: $(OBJECTS)
	$(OCAMLC) -a -o $@ $^

tmkSignal.cmo tmkSignal.cmi: 
tmkStruct.cmo tmkStruct.cmi: 
tmkArea.cmo tmkArea.cmi: 
tmkStyle.cmo tmkStyle.cmi: 
tmkMain.cmo tmkMain.cmi: tmkTerminal.cmi tmkWidget.cmi tmkStyle.cmi tmkStyle_l.cmi tmkStyle_p.cmi
tmkTerminal.cmo tmkTerminal.cmi: tmkStruct.cmi tmkArea.cmi tmkStyle.cmi
tmkWidget.cmo tmkWidget.cmi: tmkSignal.cmi tmkStruct.cmi tmkArea.cmi tmkStyle.cmi tmkTerminal.cmi
tmkContainer.cmo tmkContainer.cmi: tmkStruct.cmi tmkArea.cmi tmkWidget.cmi
tmkButton.cmo tmkButton.cmi: tmkContainer.cmi tmkStruct.cmi
tmkPacking.cmo tmkPacking.cmi: tmkContainer.cmi tmkStruct.cmi
tmkMisc.cmo tmkMisc.cmi: tmkStruct.cmi tmkWidget.cmi
tmkList.cmo tmkList.cmi: tmkWidget.cmi tmkStruct.cmi
tmkEntry.cmo tmkEntry.cmi: tmkWidget.cmi tmkStruct.cmi
tmkFrame.cmo tmkFrame.cmi: tmkContainer.cmi tmkStruct.cmi

tmkStyle_p.ml tmkStyle_p.mli: tmkStyle_p.mly
	ocamlyacc tmkStyle_p.mly
tmkStyle_l.ml: tmkStyle_l.mll
	ocamllex tmkStyle_l.mll
tmkStyle_p.cmo: tmkStyle_p.ml tmkStyle_p.cmi
tmkStyle_p.cmi: tmkStyle_p.mli tmkStyle.cmi
tmkStyle_l.cmo tmkStyle_l.cmi: tmkStyle_l.ml tmkStyle_p.cmi tmkStyle.cmi


test: test.ml $(INTERFACES) tmk.cma
	$(OCAMLC) -g -o test -I ../curses ../curses/mlcurses.cma -custom \
	tmk.cma unix.cma test.ml

clean:
	rm -f *.cmo *.cmi *.cma tmkStyle_p.ml tmkStyle_p.mli tmkStyle_l.ml
