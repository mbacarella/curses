open TmkStruct

(****************************************************************************************
 * La classe Container
 ****************************************************************************************)

let real_class_container = Class.create "Container" [TmkWidget.real_class_widget]

class virtual container = object (self)
  inherit TmkWidget.widget as super

  val mutable redrawing_children = ([] : TmkWidget.widget list)

  method is_container = true

  method queue_redraw () =
    if not need_redraw then (
      super#queue_redraw ();
      redrawing_children <- [];
      List.iter (fun c -> c#queue_redraw ()) (self#children ())
    )

  method redraw_register (w : TmkWidget.widget) =
    if not need_redraw then (
      redrawing_children <- w :: redrawing_children;
      try self#parent#redraw_register self#coerce
      with Not_found ->
	Queue.add self#redraw_deliver self#terminal#event_queue
    )

  method redraw_deliver () =
    if geometry.Geom.w > 0 && geometry.Geom.h > 0 then (
      if need_redraw then
	super#redraw_deliver ()
      else (
	List.iter (fun c -> c#redraw_deliver ()) redrawing_children;
	redrawing_children <- []
      )
    )

  method add w =
    self#signal_add_descendant#emit w

  method remove w =
    TmkWidget.full_tree_do_post
      (fun d -> self#signal_remove_descendant#emit d)
      (w :> TmkWidget.widget)

  method class_map w =
    super#class_map w;
    List.iter (fun c -> c#signal_map#emit w) (self#children ())

  method class_set_state s =
    super#class_set_state s;
    List.iter (fun c -> c#signal_set_state#emit s) (self#children ())

  method class_draw () =
    super#class_draw ();
    List.iter (fun c -> c#signal_draw#emit ()) (self#children ())

  method class_add_descendant (w : TmkWidget.widget) =
    try
      self#parent#signal_add_descendant#emit w
    with Not_found -> assert false

  method class_remove_descendant (w : TmkWidget.widget) =
    try
      self#parent#signal_remove_descendant#emit w
    with Not_found -> assert false
end


(****************************************************************************************
 * La classe Bin
 ****************************************************************************************)

let real_class_bin = Class.create "Bin" [real_class_container]

class virtual bin = object (self)
  inherit container as super

  val mutable child : TmkWidget.widget option = None

  method children () = match child with
    | Some w -> [w]
    | None -> []

  method add (w : TmkWidget.widget) =
    match child with
      | Some _ -> failwith "bin has already a child"
      | None ->
 	  child <- Some w;
	  self#signal_add_descendant#emit w

  method remove w =
    match child with
      | Some c when c == w ->
	  super#remove w;
	  child <- None
      | _ -> raise Not_found
end


(****************************************************************************************
 * La classe utilitaire Toplevel
 ****************************************************************************************)

let real_class_toplevel = Class.create "Toplevel" []

class virtual toplevel (term : TmkWidget.terminal) = object (self)
  val mutable focus = (None : TmkWidget.widget option)

  method toplevel_pass = function
    | Toplevel.Give_focus (w : TmkWidget.widget) ->
	assert w#can_focus;
	let f = match focus with
	  | None -> assert false
	  | Some f -> f in
	f#signal_lost_focus#emit ();
	w#signal_got_focus#emit ();
	focus <- Some w

  method set_cursor c =
    term#set_cursor c
    

  method class_add_descendant (w : TmkWidget.widget) =
    if w#can_focus then (
      match focus with
	| Some _ -> ()
	| None -> focus <- Some w
    );
    term#queue_resize ()

  method class_remove_descendant (w : TmkWidget.widget) =
    let () = match focus with
      | Some f when f == w ->
	  focus <- TmkWidget.find_first_focusable w self#coerce;
	  (match focus with
	    | Some f -> w#signal_got_focus#emit ()
	    | None -> ())
      | _ -> () in
    term#queue_resize ()

  method class_toplevel_event = function
    | Toplevel.Activate ->
	let () = match focus with
	  | None -> ()
	  | Some w -> w#signal_got_focus#emit () in
	()
    | Toplevel.Desactivate -> ()
    | Toplevel.Key k ->
	let () = match focus with
	  | None -> ()
	  | Some w -> ignore (w#signal_key_event#emit k) in
	()
end


(****************************************************************************************
 * La classe Window
 ****************************************************************************************)

let real_class_window = Class.create "Window" [real_class_bin; real_class_toplevel]

class window (term : TmkWidget.terminal) = object (self)
  inherit bin as super
  inherit toplevel term as super_toplevel

  val mutable child_size = (0,0)
  val mutable child_scroll = false
  val mutable child_window = TmkArea.null_window
  val child_geometry = Geom.null ()

  val mutable left_glue = 0
  val mutable right_glue = 0
  val mutable top_glue = 0
  val mutable bottom_glue = 0

  method real_class = real_class_window
  method parent = raise Not_found
  method terminal = term

  method set_glue l r t b =
    if l < 0 || r < 0 || t < 0 || b < 0 || l + r > 100 || t + b > 100 then
      invalid_arg "Window#set_glue";
    left_glue <- l;
    right_glue <- r;
    top_glue <- t;
    bottom_glue <- b

  method set_cursor ((x,y) as c) =
    child_window#set_center x y;
    super_toplevel#set_cursor (child_window#real_position c)

  method class_map w =
    super#class_map w;
    child_window <- w;
    let s = self#signal_get_size#emit (0,0) in
    child_size <- s

  method class_get_size t =
    match child with
      | None -> t
      | Some c -> c#signal_get_size#emit t

  method class_set_geometry g =
    super#class_set_geometry g;
    match child with
      | None -> ()
      | Some c ->
	  let (w, h) = child_size in
	  let center g1 g2 ew iw =
	    if iw > ew then
	      (0, ew, iw)
	    else
	      let gt = g1 + g2 in
	      let gc = 100 - gt in
	      let rw = iw + gc * (ew - iw) / 100 in
	      let rx = if gt = 0 then 0 else g1 * (ew - rw) / gt in
	      (rx, rw, rw) in
	  let (vx, vw, cw) = center left_glue right_glue geometry.Geom.w w
	  and (vy, vh, ch) = center top_glue bottom_glue geometry.Geom.h h in
	  let cs = w > geometry.Geom.w || h > geometry.Geom.h in
	  let cg = if cs then (
	    if child_scroll then (
	      child_window#set_view vx vy vw vh;
	      child_window#resize cw ch
	    ) else (
	      let pad = Curses.newpad ch cw in
	      child_window <- new TmkArea.pad pad cw ch;
	      child_window#set_view vx vy vw vh;
	      c#signal_map#emit child_window
	    );
	    (0, 0, cw, ch)
	  ) else (
	    if child_scroll then (
	      child_window#destroy ();
	      child_window <- window_info;
	      c#signal_map#emit child_window
	    );
	    (vx, vy, cw, ch)
	  ) in
	  Geom.record cg child_geometry;
	  c#signal_set_geometry#emit cg;
	  child_scroll <- cs

  method class_draw () =
    Curses.wattrset child_window#window attribute;
    let y = child_geometry.Geom.y in
    for i = y to y + child_geometry.Geom.h - 1 do
      ignore (Curses.wmove child_window#window i child_geometry.Geom.x);
	Curses.whline child_window#window (32 lor attribute)
	  child_geometry.Geom.w
    done;
    super#class_draw ()

  initializer
    term#add_toplevel self#coerce;
    attributes.(0) <- Curses.A.standout;
    attribute <- Curses.A.standout
end
