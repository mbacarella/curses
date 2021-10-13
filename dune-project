(lang dune 1.11)

(generate_opam_files true)

(license "LGPL-2.1-or-later WITH OCaml-linking-exception")

(authors "Nicolas George")

(maintainers "Michael Bacarella <m@bacarella.com>")

(homepage "https://github.com/mbacarella/curses")

(source
 (github mbacarella/curses))

(package
 (name curses)
 (synopsis "Bindings to ncurses")
 (description "Tools for building terminal-based user interfaces")
 (depends
  conf-ncurses
  dune-configurator
  (ocaml
   (>= 4.02.0))))
