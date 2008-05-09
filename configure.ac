############################################################################
# configure.ac
#
# Build configuration script for OCaml curses bindings.  
#
# History:
#
#  2008-04-08  pjp   Derived from Wyrd 1.4.4 build system.
############################################################################

# Check for a particular file from the source tree

AC_INIT(config.ml.in)

# optional arguments

AC_ARG_ENABLE(widec,
[  --enable-widec          link against a wide-character-enabled ncurses)],
[try_widec=$enable_widec], [try_widec=no])


# Find a C compiler

AC_PROG_CC()

ORIG_LIBS="$LIBS"
ORIG_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CURSES_INCLUDE $ORIG_CPPFLAGS"


# Check for ncurses, and test a number of different locations for the header

AC_MSG_CHECKING(for working ncurses library)

if test "$try_widec" != "no"
then
LIBS="-lncursesw $ORIG_LIBS"
AC_TRY_LINK(
  [#include <ncursesw/curses.h>], [initscr(); use_default_colors()],
  [CURSES_LIB=-lncursesw
   AC_DEFINE(CURSES_HEADER, <ncursesw/curses.h>, [Defined to ncurses header file])])
fi

if test -z "$CURSES_LIB"
then
LIBS="-lncurses $ORIG_LIBS"
AC_TRY_LINK(
  [#include <ncurses/curses.h>], [initscr(); use_default_colors()],
  [CURSES_LIB=-lncurses
   AC_DEFINE(CURSES_HEADER, <ncurses/curses.h>, [Defined to ncurses header file])],
  [
LIBS="-lncurses $ORIG_LIBS"
AC_TRY_LINK(
  [#include <ncurses.h>], [initscr(); use_default_colors()],
  [CURSES_LIB=-lncurses
   AC_DEFINE(CURSES_HEADER, <ncurses.h>, [Defined to ncurses header file])],
  [
LIBS="-lcurses $ORIG_LIBS"
AC_TRY_LINK(
  [#include <curses.h>], [initscr(); use_default_colors()],
  [CURSES_LIB=-lcurses
   AC_DEFINE(CURSES_HEADER, <curses.h>, [Defined to ncurses header file])],
  [
LIBS="-lncurses $ORIG_LIBS"
AC_TRY_LINK(
  [#include <curses.h>], [initscr(); use_default_colors()],
  [CURSES_LIB=-lcurses
   AC_DEFINE(CURSES_HEADER, <curses.h>, [Defined to ncurses header file])],
) ]) ]) ])
fi

if test -n "$CURSES_LIB"
then
AC_MSG_RESULT([found in $CURSES_LIB])
else
AC_MSG_ERROR([not found])
fi

# Try to locate term.h, which has a sadly nonstandardized location

AC_MSG_CHECKING(for ncurses term.h)
AC_TRY_COMPILE(
   [#include <term.h>], [TERMTYPE __dummy],
   [TERM_H_STRING="<term.h>"
    AC_DEFINE(CURSES_TERM_H, <term.h>, [Defined to ncurses term.h file])],
   [
AC_TRY_COMPILE(
   [#include <ncurses/term.h>], [TERMTYPE __dummy],
   [TERM_H_STRING="<ncurses/term.h>"
    AC_DEFINE(CURSES_TERM_H, <ncurses/term.h>, [Defined to ncurses term.h file])],
   [
AC_TRY_COMPILE(
   [#include <curses/term.h>], [TERMTYPE __dummy],
   [TERM_H_STRING="<curses/term.h>"
    AC_DEFINE(CURSES_TERM_H, <curses/term.h>, [Defined to ncurses term.h file])],
) ]) ])

if test -n "$TERM_H_STRING"
then
   AC_MSG_RESULT([found in $TERM_H_STRING])
else
   AC_MSG_ERROR([not found])
fi


# Determine whether the detected curses has wide character support

BOOL_WIDE_CURSES="false"
if test -n "$CURSES_LIB"
then
  LIBS="$CURSES_LIB $ORIG_LIBS"

  if test "$try_widec" != "no"
  then
    AC_MSG_CHECKING(for wide character support in ncurses library)
    AC_TRY_LINK(
      [#include <wchar.h>
       #include CURSES_HEADER
      ],
      [wchar_t wch = 0;
       addnwstr(&wch, 1);],
      [AC_MSG_RESULT(yes)
       AC_DEFINE(HAVE_WIDE_CURSES, 1, [Defined if ncurses library includes wide character support])
       BOOL_WIDE_CURSES="true"],
      [AC_MSG_RESULT(no)])
  fi
fi

CURSES_LIB_BASE=`expr "$CURSES_LIB" : '-l\(.*\)'`
CPPFLAGS="$ORIG_CPPFLAGS"
LIBS="$ORIG_LIBS"


# Perform substitutions

AC_SUBST(CURSES_HEADER)
AC_SUBST(CURSES_TERM_H)
AC_SUBST(CURSES_LIB)
AC_SUBST(CURSES_LIB_BASE)
AC_SUBST(BOOL_WIDE_CURSES)
AC_SUBST(DEFS)
AC_SUBST(CC)
AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)


# Generate the Makefile and config module

AC_OUTPUT(Makefile config.ml)
chmod a-w Makefile



