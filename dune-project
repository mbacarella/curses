(lang dune 1.11)

(generate_opam_files true)

(license "LGPL-2.1-or-later WITH OCaml-linking-exception")

(homepage "https://www.nongnu.org/ocaml-tmk/")

(source
 (github olafhering/ocaml-curses))

(package
 (name curses)
 (synopsis "Bindings to ncurses")
 (description
   "Tools for building terminal-based user interfaces")
 (depends
  (dune
   (>= 1.11))
  dune.configurator
  (ocaml
   (>= 4.02.0))))
