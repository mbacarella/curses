1.0.11 (2023-01-19)
=====
* Don't hard-code gcc, use cc instead. Thanks @atupone for PR #7
* Remove Windows builds from Github workflow, too difficult to diagnose
  right now; Mac and Linux remain
* Add missing dependency on Unix #8 (Thanks @dra27)
* Add a test bin
* Fix up for OCaml 5.0.0. Thanks @rrbq for #9
* Make it possible to vendor this package. Thanks @gridbugs for #10

1.0.10 (2021-11-21)
=====
* Updated to dune-lang 2.7, so that we don't have that generated .opam file
  bug anymore.
* Fixed build on Arch Linux, issue #4
* Fixed discover.ml to more durably locate curses.h headers
* Fixed build for Windows
* Added Github Workflow for CI build on Mac/Windows/Linux (uses ocaml-setup)
* Ran ocamlformat

1.0.9 (2021-10-12)
=====
* Convert to dune. Thanks to Olaf Hering <olafhering> for doing most of this!
* Dead code in tmk/ and other junk files removed.

1.0.8 (2021-09-21)
=====
* Makefile still had VERSION = 1.0.4 the whole time. Fix it with a new release.

1.0.7
=====
* <credit bug reporter>

1.0.6 (2020-02-22)
=====
* Fix segfault bug in delscreen (thanks to Shang Tsung for the report!)

1.0.5 (2020-01-24)
=====
* Move project to github.com/mbacarella/curses
* Install *.cmx files to LIBDIR so that dune doesn't warn about
  projects that build against curses.

1.0.4 (2018-11-20)
=====
* Update configure script for ncurses 6.1 (Paul Pelzl).
* Use CFLAGS from ./configure.
* Enable debugging for all builds.
* Allow compilation against PDCurses on Windows.

1.0.3 (2008-11-17)
=====
* get*yx now return coordinates in the right order (thanks Brian Campbell).
* Fix possible segfault with get_ripoff (thanks Brian Campbell).
* Indicate that we should link with the curses library (thanks Jeff Meister).

1.0.2 (2007-10-09)
=====
* Started to add documentation in curses.mli.
* Using OCamlMakefile for the makefile, now handles bytecode-only compilation.
* Libraries are now named curses.cm(x)a.

1.0.1 (2007-08-25)
=====
* Initial release.
