open TmkStruct

exception Exit_run
  
let all_terms = ref []

let try_parse_config_file f () =
  try
    let f = open_in f in
    try
      let l = Lexing.from_channel f in
      let r = TmkStyle_p.parse TmkStyle_l.lexeme l in
      close_in f;
      r
    with e -> close_in f; raise e
  with e ->
    List.iter prerr_string ["Tmk config: "; f; ": "; Printexc.to_string e];
    prerr_newline ();
    []

let init_raw () =
  TmkStyle.S.add_config_source (try_parse_config_file "tmkrc");
  TmkStyle.S.process_config_sources ()

let add_terminal t =
  all_terms := t :: !all_terms

let init () =
  let () = init_raw () in
  let r = new TmkTerminal.terminal_unique in
  all_terms := [r];
  r

let iterate_term (term : TmkWidget.terminal) =
  term#activate ();
  let q = term#event_queue in
  let () = try
    let k = term#read_key () in
    if k = 113 then raise Exit_run;
    if k = -1 then raise Exit;
    let w = term#current_toplevel () in
    Queue.add (fun () -> w#signal_toplevel_event#emit (Toplevel.Key k)) q
  with Exit -> () in
  let something = ref false in
  let () = try
    while true do
      let t = Queue.take q in
      t ();
      something := true
    done
  with Queue.Empty -> () in
  if !something then (
    let (x,y) = term#get_cursor () in
    ignore (Curses.move y x);
    (*ignore (Curses.refresh ())*)
  )
 
  
let iterate () =
  List.iter iterate_term !all_terms
  
let run () =
  try
    while true do
      iterate ();
      Curses.napms 1
    done
  with Exit_run -> ()

let exit () =
  List.iter (fun t -> t#exit ()) !all_terms
