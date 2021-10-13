(lang dune 1.11)

(generate_opam_files true)

(license "LGPL-2.1-or-later WITH OCaml-linking-exception")

(homepage "https://github.com/mbacarella/curses")

(source
 (github mbacarella/curses))

(package
 (name curses)
 (synopsis "Bindings to ncurses")
 (description "Tools for building terminal-based user interfaces")
 (depends
  dune.configurator
  (ocaml
   (>= 4.02.0))))
