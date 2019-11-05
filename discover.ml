module C = Configurator.V1

let () =
C.main ~name:"curses" (fun c ->

let ml_file = "config.ml" in
let ml_code = [ "let wide_ncurses = true" ] in
C.Flags.write_lines ml_file ml_code ;

let stale_ncursesw : C.Pkg_config.package_conf = {
 libs = [ "-lncursesw" ];
 cflags = []
} in

let conf =
  match C.Pkg_config.get c with
  | None -> C.die "'pkg-config' missing"
  | Some pc ->
    match (C.Pkg_config.query pc ~package:"ncursesw") with
      | None -> stale_ncursesw
      | Some deps -> deps
  in

  let config_h = [
  "#define CURSES_HEADER <ncursesw/curses.h>";
  "#define CURSES_TERM_H <ncursesw/term.h>";
  "#define HAVE_TERMIOS_H 1";
  "#define HAVE_SYS_IOCTL_H 1"
  ] in
  C.Flags.write_lines "_config.h" config_h;

  let extra_cflags = [ "-DHAVE_CONFIG_H" ] in
  C.Flags.write_sexp "c_flags.sexp"         (List.append conf.cflags extra_cflags);
  C.Flags.write_sexp "c_library_flags.sexp" conf.libs)
