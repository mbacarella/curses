open Curses
open TmkStruct

(*smkx, rmkx *)
let key_list = [
Key.backspace,	"kbs";	Key.home,	"khome";Key.up,		"kcuu1";	
Key.seol,	"kEOL";	Key.sexit,	"kEXT";	Key.scopy,	"kCPY";
Key.ctab,	"kctab";Key.find,	"kfnd";	Key.ssuspend,	"kSPD";
Key.restart,	"krst";	Key.close,	"kclo";	Key.redo,	"krdo";
Key.smove,	"kMOV";	Key.ssave,	"kSAV";	Key.npage,	"knp";
Key.sundo,	"kUND";	Key.a1,		"ka1";	Key.a3,		"ka3";
Key.sleft,	"kLFT";	Key.b2,		"kb2";	Key.c1,		"kc1";
Key.c3,		"kc3";	Key.smessage,	"kMSG";	Key.help,	"khlp";
Key.replace,	"krpl";	Key.eic,	"krmir";Key.stab,	"khts";
Key.dc,		"kdch1";Key.dl,		"kdl1";	Key.beg,	"kbeg";
Key.create,	"kcrt";	Key.sfind,	"kFND";	Key.command,	"kcmd";
Key.resume,	"kres";	Key.mouse,	"kmous";Key.end_,	"kend";
Key.open_,	"kopn";	Key.btab,	"kcbt";	Key.eol,	"kel";
Key.eos,	"ked";	Key.ic,		"kich1";Key.il,		"kil1";
Key.sredo,	"kRDO";	Key.cancel,	"kcan";	Key.sdc,	"kDC";
Key.sdl,	"kDL";	Key.right,	"kcuf1";Key.ll,		"kll";
Key.options,	"kopt";	Key.sic,	"kIC";	Key.sreplace,	"kRPL";
Key.enter,	"kent";	Key.shelp,	"kHLP";	Key.shome,	"kHOM";
Key.scommand,	"kCMD";	Key.sf,		"kind";	Key.sr,		"kri";
Key.message,	"kmsg";	Key.sright,	"kRIT";	Key.down,	"kcud1";	
Key.catab,	"ktbc";	Key.refresh,	"krfr";	Key.sprevious,	"kPRV";
Key.soptions,	"kOPT";	Key.mark,	"kmrk";	Key.next,	"knxt";
Key.previous,	"kprv";	Key.reference,	"kref";	Key.select,	"kslt";
Key.print,	"kprt";	Key.exit,	"kext";	Key.copy,	"kcpy";
Key.ppage,	"kpp";	Key.clear,	"kclr";	Key.screate,	"kCRT";
Key.srsume,	"kRES";	Key.suspend,	"kspd";	Key.snext,	"kNXT";
Key.move,	"kmov";	Key.save,	"ksav";	Key.scancel,	"kCAN";
Key.sprint,	"kPRT";	Key.undo,	"kund";	Key.sbeg,	"kBEG";
Key.left,	"kcub1";Key.send,	"kEND";
] @ (let rec f k l = if k < 0 then l else
  f (k - 1) ((Key.f k, "kf" ^ (string_of_int k)) :: l) in f 63 [])

module KeyTree = struct
  type t = {
    mutable key: int;
    mutable subtree: (int, t) Hashtbl.t option;
  }

  let create () =
    { key = -1; subtree = None }

  let rec add_key tree key = function
    | [] -> tree.key <- key
    | h::t ->
        let s = match tree.subtree with
	  | None ->
	    let h =  Hashtbl.create 17 in
	    tree.subtree <- Some h; h
	  | Some h -> h in
        let n = try
	  Hashtbl.find s h
	with Not_found ->
	  let n = create () in
	  Hashtbl.add s h n; n in
	add_key n key t

  (* TODO: un mode avec temporisation *)
  let try_key tree key =
    let rec try_key_aux best tree seq =
      let sb =
	if tree.key = -1 then best
      	else (tree.key, seq) in
      match tree.subtree with
	| None -> sb
	| Some ht ->
	    match seq with
	      | [] -> (-1, key)
	      | h::t ->
		  let sto =
		    try Some (Hashtbl.find ht h)
		    with Not_found -> None in
		  match sto with
		    | None -> sb
		    | Some st -> try_key_aux sb st t in
    match key with
      | [] -> (-1, [])
      | h::t -> try_key_aux (h,t) tree key

end

let get_terminfo_string s =
  try
    Some (tigetstr s)
  with Failure _ -> None
  
let int_list_of_string s =
  let rec aux a = function
    | -1 -> a
    | n -> aux ((int_of_char s.[n]) :: a) (n - 1) in
  aux [] (String.length s - 1)

let construire_arbre_terminfo r =
  List.iter (fun (x,y) -> match get_terminfo_string y with
    | Some t ->
        KeyTree.add_key r x (int_list_of_string t);
	if t.[0] = '\027' && t.[1] = 'O' then (
	  t.[1] <- '[';
	  KeyTree.add_key r x (int_list_of_string t)
	)
    | None -> ()) key_list 


let variables v =
  if v = "" then ""
  else if v.[0] = '$' then
    try Sys.getenv (String.sub v 1 (pred (String.length v)))
    with Not_found -> ""
  else
    ""
  


(****************************************************************************
 * The terminal class
 ****************************************************************************)

class virtual ['a] terminal = object (self)
  val keytree = KeyTree.create ()
  val mutable key_spool = []
  val mutable toplevels = []
  val event_queue = Queue.create ()
  val mutable cursor = (0, 0)
  val simplified_configuration =
    Cache.create (fun () -> TmkStyle.S.simplify_configuration
      (fun v -> Some (variables v)) None !TmkStyle.S.config_tree)

  method virtual activate : unit -> unit
  method virtual exit : unit -> unit
  method virtual main_window : TmkArea.window
  method virtual resource : TmkStyle.R.t
  method virtual get_size : unit -> int * int

  method virtual acs : Curses.Acs.acs

  method event_queue = event_queue

  val mutable resize_queued = false

  method queue_resize () =
    if not resize_queued then (
      resize_queued <- true;
      Queue.add self#resize_toplevels event_queue
    )

  method resize_toplevels () =
    let (h, w) = self#get_size () in
    ignore (Curses.wclear self#main_window#window);
    let send t = t#signal_set_geometry#emit (0, 0, w, h) in
    Queue.add (fun () -> List.iter send (List.rev toplevels)) event_queue;
    resize_queued <- false

  method read_key () =
    let rec all_keys a =
      match getch () with
	| -1 -> List.rev a
	| k -> all_keys (k::a) in
    let k = all_keys [] in
    key_spool <- key_spool @ k;
    let (t,r) = KeyTree.try_key keytree key_spool in
    key_spool <- r;
    if t = Curses.Key.resize then (
      self#resize_toplevels ();
      self#read_key ()
    ) else
      t

  method private activate_last_toplevel () =
    match toplevels with
      | [] -> ()
      | t::_ ->
	  Queue.add (fun () -> t#signal_toplevel_event#emit Toplevel.Activate)
	    event_queue

  method add_toplevel (t : 'a) =
    toplevels <- t :: toplevels;
    Queue.add (fun () -> t#signal_map#emit self#main_window)
      event_queue;
    self#queue_resize ();
    self#activate_last_toplevel ()

  method remove_toplevel () =
    match toplevels with
      | [] -> failwith "no toplevel to remove"
      | h::t ->
	  toplevels <- t;
	  self#queue_resize ();
	  self#activate_last_toplevel ()

  method current_toplevel () =
    List.hd toplevels

  method get_cursor () =
    cursor
  method set_cursor c =
    cursor <- c

  method configuration () =
    Cache.get simplified_configuration

end

class ['a] terminal_unique = object
  inherit ['a] terminal

  val main_window =
    let t = Curses.initscr () in
    if t = Curses.null_window then failwith "screen initialisation";
    ignore (cbreak ());
    ignore (noecho ());
    new TmkArea.toplevel t

  val acs = Curses.get_acs_codes ()
  method acs = acs

  method main_window = main_window
  method activate () = ()
  method exit () =
    Curses.endwin ()

  val resource = TmkStyle.R.create ()

  method resource = resource

  method get_size () =
    let (h,w) as s = Curses.get_size () in
    ignore (Curses.resizeterm h w);
    s

  initializer
    let w = main_window#window in
    if not (Curses.raw ()) then failwith "raw mode";
    if not (Curses.noecho ()) then failwith "echo mode";
    if not (Curses.nodelay w true) then failwith "no delay mode";
    Curses.winch_handler_on ();
    construire_arbre_terminfo keytree
end

class ['a] terminal_from_fd fdout fdin =
  let screen = Curses.newterm "xterm" fdin fdout in object
  inherit ['a] terminal

  val main_window =
    let t = Curses.stdscr () in
    if t = Curses.null_window then failwith "screen initialisation";
    new TmkArea.toplevel t

  val acs = Curses.get_acs_codes ()
  method acs = acs

  method main_window = main_window
  method activate () =
    ignore (Curses.set_term screen)

  method exit () =
    Curses.endwin ()

  val resource = TmkStyle.R.create ()

  method resource = resource

  method get_size () =
    let (h,w) as s = Curses.get_size_fd fdin in
    prerr_endline (Printf.sprintf "%dx%d" w h);
    ignore (Curses.resizeterm h w);
    s

  initializer
    let w = main_window#window in
    if not (Curses.raw ()) then failwith "raw mode";
    if not (Curses.noecho ()) then failwith "echo mode";
    if not (Curses.nodelay w true) then failwith "no delay mode";
    Curses.winch_handler_on ();
    construire_arbre_terminfo keytree
end
