type t =
  { wfoo : Curses.window;
    wbar : Curses.window;
    wbazzes : Curses.window;
    wsnoos : Curses.window
  }

let init title =
  (* init *)
  let _window = Curses.initscr () in
  assert (Curses.start_color ());
  (* set title *)
  Curses.attron Curses.A.bold;
  assert (Curses.addstr title);
  Curses.attroff Curses.A.bold;
  assert (Curses.refresh ());
  (* create windows *)
  let wfoo = Curses.newwin 1 80 1 0 in
  let wbar = Curses.newwin 3 80 2 0 in
  let wbazzes = Curses.newwin 3 80 5 0 in
  let wsnoos = Curses.newwin 10 80 8 0 in
  let demo_window win str =
    Curses.box win 0 0;
    assert (Curses.waddstr win str);
    assert (Curses.wrefresh win)
  in
  demo_window wfoo "foos";
  demo_window wbar "bars";
  demo_window wbazzes "bazzes";
  demo_window wsnoos "snoos";
  let wsnoos_left = Curses.derwin wsnoos 6 38 2 2 in
  let wsnoos_right = Curses.derwin wsnoos 6 30 2 44 in
  demo_window wsnoos_left "left side\nfoobar\n";
  assert (Curses.waddstr wsnoos_left "third\n");
  assert (Curses.wrefresh wsnoos_left);
  demo_window wsnoos_right "right side";
  { wfoo; wbar; wbazzes; wsnoos }

let () =
  let _t = init "the title" in
  ignore (Curses.getch () : int);
  Curses.endwin ();
  ()
