open TmkStruct

exception Not_container
exception Not_toplevel

let rec find_next_widget prop prev cur d =
  let filtrer_direction = match d with
      | Direction.Previous | Direction.Left | Direction.Up ->
	  List.rev
      | Direction.Next | Direction.Right | Direction.Down ->
	  (fun x -> x) in
  let rec find_next_widget_list = function
    | [] -> None
    | h::t ->
	if prop h then Some h
	else
	  let c = try h#children () with Not_container -> [] in
	  let c = filtrer_direction c in
	  match find_next_widget_list c with
	    | (Some _) as r -> r
	    | None -> find_next_widget_list t in
  if prop cur then Some cur
  else
    let c = filtrer_direction (cur#children ()) in
    let rec split_list l = function
      | h::t when h == prev -> (List.rev (h::l), t)
      | h::t -> split_list (h::l) t
      | [] -> assert false in
    let (l,r) = split_list [] c in
    match find_next_widget_list r with
      | (Some _) as r -> r
      | None ->
	  let r =
	    try find_next_widget prop cur cur#parent d
	    with Not_found -> None in
	  match r with
	    | Some _ -> r
	    | None -> find_next_widget_list l


(****************************************************************************************
 * La classe Widget
 ****************************************************************************************)

let real_class_widget = Class.create "Widget" []

class virtual widget = object (self)
  val mutable window = Curses.null_window
  val mutable window_info = TmkArea.null_window
  val geometry = Geom.null ()
  val mutable state = State.normal
  val attributes = Array.create
    (succ State.to_int_max) Curses.A.normal
  val mutable attribute = Curses.A.normal
  val mutable name = ""
  val mutable need_redraw = false
  val mutable configured = false

  method virtual real_class : Class.t
  method virtual parent : widget
  method virtual terminal : widget TmkTerminal.terminal
  method can_focus = false
  method has_focus = State.has_focus state

  (* Gasp, I don't know how to write that type safely _and_ without
     writing all the type. *)
  method coerce = (Obj.magic self : widget)

  method set_name n =
    let p = if n = "" then "" else "." ^ n in
    let q =
      try (self#parent#name) ^ p
      with Not_found -> n in
    name <- q;
    if n <> "" then self#do_configuration ()

  method name = name

  method queue_redraw () =
    if not need_redraw then (
      need_redraw <- true;
      try self#parent#redraw_register self#coerce
      with Not_found ->
	Queue.add self#redraw_deliver self#terminal#event_queue
    )

  method redraw_deliver () =
    if geometry.Geom.w > 0 && geometry.Geom.h > 0 then (
      if need_redraw then self#signal_draw#emit ();
      need_redraw <- false
    )

  method is_container = false

  method add (w : widget) =
    (raise Not_container : unit)

  method remove (w : widget) =
    (raise Not_container : unit)

  method children () =
    (raise Not_container : widget list)

  method redraw_register (w : widget) =
    (raise Not_container : unit)

  method set_variable name subscripts value =
    match (name, subscripts, value) with
      | ("style", Some s, TmkStyle.S.Str v) ->
	  let res = self#terminal#resource in
	  let fixer_style n =
	    let v = TmkStyle.C.parse_style_string res attributes.(n) v in
	    attributes.(n) <- v;
	    if n = State.to_int state then attribute <- v in
	  List.iter fixer_style (TmkStyle.C.state_names s)
      | _ -> prerr_endline ("Unknown variable or illegal use: " ^ name)

  method do_configuration () =
    configured <- true;
    let v = self#terminal#configuration () in
    let v = TmkStyle.S.relevant_variables (fun _ -> "") name v in
    let accept_var (n, s, v) = self#set_variable n s v in
    List.iter accept_var v

  method toplevel_pass (m : widget Toplevel.m) =
    self#parent#toplevel_pass m

  method set_cursor (c : int * int) =
    (self#parent#set_cursor c : unit)

  (* Signals *)

  val signal_map =
    new TmkSignal.signal "map" TmkSignal.Marshall.all_unit
  val signal_get_size =
    new TmkSignal.signal "get_size" TmkSignal.Marshall.filter
  val signal_set_geometry =
    new TmkSignal.signal "set_geometry" TmkSignal.Marshall.all_unit
  val signal_set_state =
    new TmkSignal.signal "set_state" TmkSignal.Marshall.all_unit
  val signal_draw =
    new TmkSignal.signal "draw" TmkSignal.Marshall.all_unit
  val signal_got_focus =
    new TmkSignal.signal "got_focus" TmkSignal.Marshall.all_unit
  val signal_lost_focus =
    new TmkSignal.signal "lost_focus" TmkSignal.Marshall.all_unit
  val signal_key_event =
    new TmkSignal.signal "key_event" TmkSignal.Marshall.until_true
  val signal_add_descendant =
    new TmkSignal.signal "add_descendant" TmkSignal.Marshall.all_unit
  val signal_remove_descendant =
    new TmkSignal.signal "remove_descendant" TmkSignal.Marshall.all_unit
  val signal_toplevel_event = 
    new TmkSignal.signal "toplevel_event" TmkSignal.Marshall.all_unit

  method signal_map = signal_map
  method signal_get_size = signal_get_size
  method signal_set_geometry = signal_set_geometry
  method signal_set_state = signal_set_state
  method signal_draw = signal_draw
  method signal_got_focus = signal_got_focus
  method signal_lost_focus = signal_lost_focus
  method signal_key_event = signal_key_event
  method signal_add_descendant = signal_add_descendant
  method signal_remove_descendant = signal_remove_descendant
  method signal_toplevel_event = signal_toplevel_event

  method class_map w =
    window_info <- w;
    window <- w#window;
    if not configured then self#do_configuration ()

  method virtual class_get_size : int * int -> int * int

  method class_set_geometry g =
    Geom.record g geometry;
    self#queue_redraw ()

  method class_set_state s =
    state <- s;
    let n = attributes.(State.to_int s) in
    if n <> attribute then (
      attribute <- n;
      self#queue_redraw ()
    )

  method class_draw () =
    need_redraw <- false

  method class_got_focus () =
    assert self#can_focus;
    self#signal_set_state#emit (State.set_focus state true)

  method class_lost_focus () =
    assert self#can_focus;
    self#signal_set_state#emit (State.set_focus state false)

  method class_key_event k =
    let aux d =
      let w = match find_next_widget
	(fun w -> w#can_focus) self#coerce (self#parent) d with
	  | None -> assert false
	  | Some w -> w in
      let () = self#toplevel_pass (Toplevel.Give_focus w) in
      true in
    if k =  Curses.Key.up then aux Direction.Up
    else if k = Curses.Key.down then aux Direction.Down
    else if k = Curses.Key.left then aux Direction.Left
    else if k = Curses.Key.right then aux Direction.Right
    else if k = 9 then aux Direction.Next
    else
      try
	self#parent#signal_key_event#emit k
      with Not_found -> false

  method class_add_descendant (w : widget) =
    ()

  method class_remove_descendant (w : widget) =
    ()

  method class_toplevel_event (e : Toplevel.t) =
    raise Not_toplevel

  initializer
    let p = TmkStyle.R.color_pair_alloc self#terminal#resource 1 4 in
    attributes.(1) <- (Curses.A.color_pair p) lor Curses.A.bold;
    self#set_name "";
    self#signal_map#connect 101 (fun w -> self#class_map w);
    self#signal_get_size#connect 101 (fun t -> self#class_get_size t);
    self#signal_set_geometry#connect 101 (fun g -> self#class_set_geometry g);
    self#signal_set_state#connect 101 (fun s -> self#class_set_state s);
    self#signal_draw#connect 101 (fun () -> self#class_draw ());
    self#signal_got_focus#connect 101 (fun () -> self#class_got_focus ());
    self#signal_lost_focus#connect 101 (fun () -> self#class_lost_focus ());
    self#signal_key_event#connect (-1) (fun k -> self#class_key_event k);
    self#signal_add_descendant#connect 101 (fun w -> self#class_add_descendant w);
    self#signal_remove_descendant#connect 101 (fun w -> self#class_remove_descendant w);
    self#signal_toplevel_event#connect 101 (fun e -> self#class_toplevel_event e)
end

let warning w t =
  prerr_string w#name;
  prerr_string ": ";
  prerr_endline t

let rec full_tree_do_post f (w : widget) =
  if w#is_container then
    List.iter (full_tree_do_post f) (w#children ());
  f w

let rec find_first_focusable ex (w : widget) =
  if w#can_focus then (
    if w == ex then None
    else Some w
  ) else if w#is_container then
    let rec aux = function
      | [] -> None
      | h::t -> match find_first_focusable ex h with
	  | None -> aux t
	  | s -> s in
    aux (w#children ())
  else
    None

type terminal = widget TmkTerminal.terminal
