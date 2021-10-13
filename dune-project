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
  ; 2021-10-13 mbacarella: there's a conf-ncurses but we don't use it, since
  ; we use pkg-config to probe for ncursesw. ncurses and ncursesw are similar
  ; but not quiteidentical libraries, even though some distros alias one to
  ; the other. For now, as a matter of safety, we're not going to depend on
  ; conf-ncurses (and it would probably needlessly confuse matters to create
  ; a conf-ncursesw).
  dune.configurator
  (ocaml
   (>= 4.02.0))))
