(*let t = TmkMain.init ()*)

(*let fdi = Unix.openfile "/dev/ttyr0" [Unix.O_RDONLY] 0
and fdo = Unix.openfile "/dev/ttyr0" [Unix.O_WRONLY] 0

let () = TmkMain.init_raw ()
let t = new TmkTerminal.terminal_from_fd fdi fdo
let () = TmkMain.add_terminal t*)
(*let t = TmkMain.init ()*)

let init term =
  if term = "" then
    let t = TmkMain.init () in
    t
  else
    let fdi = Unix.openfile term [Unix.O_RDONLY] 0
    and fdo = Unix.openfile term [Unix.O_WRONLY] 0 in
    TmkMain.init_raw ();
    let t = new TmkTerminal.terminal_from_fd fdi fdo in
    TmkMain.add_terminal t;
    t

let create_dialog term text buttons =
  let w = new TmkContainer.window term in
  w#set_glue 50 50 40 60;
  w#set_name "window";
  let f = new TmkFrame.frame (w :> TmkContainer.container) "" in
  f#set_name "frame";
  let v = new TmkPacking.vbox f in
  let aux t =
    let l = new TmkMisc.label (v :> TmkContainer.container) t in
    l#set_align 0 0 in
  List.iter aux text;
  let r = new TmkFrame.rule (v :> TmkContainer.container) `Horizontal in
  let h = new TmkPacking.hbox (v :> TmkContainer.container) in
  let aux t =
    h#add_glue 1 1;
    let b = new TmkButton.button (h :> TmkContainer.container) in
    let l = new TmkMisc.label (b :> TmkContainer.container) t in
    b#set_name "bouton";
    l#set_name "label";
    b in
  let b = List.map aux buttons in
  let callback () =
    term#remove_toplevel () in
  List.iter (fun b -> b#signal_activate#connect 0 callback) b;
  h#add_glue 1 1;
  w

let create_sample_screen t =
  let w = new TmkContainer.window t in
  w#set_name "top";
  let v = new TmkPacking.vbox (w :> TmkContainer.container) in
  v#set_name "box";
  let entry = new TmkEntry.entry (v :> TmkContainer.container) in
  entry#set_name "entry";

  for i = 1 to 3 do
    let t = Printf.sprintf "Label n°%d" i in
    let b = new TmkButton.button (v :> TmkContainer.container) in
    b#set_name (Printf.sprintf "l%d" i);
    let l = new TmkMisc.label (b :> TmkContainer.container) t in
    l#set_name "label";
    v#add_glue 0 2;
    b#signal_activate#connect 0 (fun () -> prerr_endline t)
  done;

  let list = new TmkList.list (v :> TmkContainer.container) 2 in
  v#set_child_expand (list : #TmkWidget.widget :> TmkWidget.widget) 10;
  list#set_name "liste";
  list#set_multi_selection true;
  let f l =
    [| Printf.sprintf "Ligne %d" l;
       Printf.sprintf "Inverse %d" (1000000 / (succ l))|] in
  list#insert_lines 0 (Array.init 100 f);
  list#set_column ~col:0 ~min:1 ~expand:2 ~left:1 ~right:1 ~align:100;
  list#signal_select_line#connect 0
    (fun l -> prerr_endline (string_of_int l); list#delete_lines l 3);

  let h = new TmkPacking.hbox (v :> TmkContainer.container) in
  h#set_name "hbox";
  v#add_glue 0 4;
  h#add_glue 0 1;
  let rec aux i g =
    let t = Printf.sprintf "Bouton %d" i in
    let b = new TmkButton.radio_button (h :> TmkContainer.container) g in
    b#set_name (Printf.sprintf "b%d" i);
    let l = new TmkMisc.label (b :> TmkContainer.container) t in
    l#set_name "label";
    h#add_glue 0 1;
    if i < 3 then aux (succ i) (Some b#group) in
  aux 1 None

let main () =
  let tty =
    if Array.length Sys.argv < 2 then ""
    else Sys.argv.(1) in
  let term = init tty in
  create_sample_screen term;
  let dialog = create_dialog term
    ["This is a simple question to test the dialog.";
      "With two lines of text."]
    ["Ok"; "Cancel"; "Help"] in
  TmkMain.run ();
  TmkMain.exit ()

let () = main ()
