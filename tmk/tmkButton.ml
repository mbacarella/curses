open TmkStruct

(****************************************************************************************
 * La classe Button
 ****************************************************************************************)

let real_class_button = Class.create "Button" [TmkContainer.real_class_bin]

class button parent = object (self)
  inherit TmkContainer.bin as super

  val terminal = parent#terminal
  val mutable left_margin = 1
  val mutable right_margin = 1
  val mutable draw_sides = true
  val mutable left_side = 60
  val mutable right_side = 62

  method real_class = real_class_button
  method parent = parent
  method terminal = terminal
  method can_focus = true

  method activate () =
    self#signal_activate#emit ()

  val signal_activate =
    new TmkSignal.signal "activate" TmkSignal.Marshall.all_unit

  method signal_activate = signal_activate

  method class_get_size t =
    let (w,h) = match child with
      | None -> (0,0)
      | Some w -> w#signal_get_size#emit (0,0) in
    (w + left_margin + right_margin, min h 1)

  method class_set_geometry g =
    super#class_set_geometry g;
    match child with
      | None -> ()
      | Some w -> w#signal_set_geometry#emit
	  (geometry.Geom.x + left_margin, geometry.Geom.y,
	   geometry.Geom.w - left_margin - right_margin, geometry.Geom.h)

  method class_draw () =
    Curses.wattrset window attribute;
    for i = geometry.Geom.y to geometry.Geom.y + geometry.Geom.h - 1 do
      ignore (Curses.wmove window i geometry.Geom.x);
      Curses.whline window 32 geometry.Geom.w
    done;
    super#class_draw ();
    Curses.wattrset window attribute;
    if draw_sides then (
      ignore (Curses.mvwaddch window geometry.Geom.y
	geometry.Geom.x left_side);
      ignore (Curses.mvwaddch window geometry.Geom.y
	(geometry.Geom.x + geometry.Geom.w - 1) right_side)
    )

  method class_got_focus () =
    super#class_got_focus ();
    self#set_cursor (succ geometry.Geom.x, geometry.Geom.y)

  method class_key_event k =
    if k = 32 || k = 10 then
      let () = self#activate () in
      true
    else
      super#class_key_event k

  method class_activate () =
    ()

  initializer
    self#signal_activate#connect 101 (fun () -> self#class_activate ());
    parent#add self#coerce
end


(****************************************************************************************
 * La classe ToggleButton
 ****************************************************************************************)

let real_class_toggle_button = Class.create "ToggleButton" [real_class_button]

class toggle_button parent = object (self)
  inherit button parent as super
  val mutable selected = false
  val mutable mark = 215

  method real_class = real_class_toggle_button

  method selected = selected
  method set_selected value =
    let change = value <> selected in
    selected <- value;
    self#queue_redraw ();
    if change then
      self#signal_toggle#emit value

  method class_draw () =
    super#class_draw ();
    ignore (Curses.wmove window geometry.Geom.y geometry.Geom.x);
    ignore (Curses.waddch window left_side);
    ignore (Curses.waddch window (if selected then mark else 32));
    ignore (Curses.waddch window right_side)

  method class_activate () =
    self#set_selected (not selected)

  val signal_toggle =
    new TmkSignal.signal "toggle" TmkSignal.Marshall.all_unit

  method signal_toggle = signal_toggle

  method class_toggle (value : bool) =
    ()

  initializer
    left_margin <- 4;
    right_margin <- 0;
    left_side <- 91;
    right_side <- 93;
    draw_sides <- false;
    self#signal_toggle#connect 101 (fun v -> self#class_toggle v);
end


(****************************************************************************************
 * La classe RadioButton
 ****************************************************************************************)

let real_class_radio_button = Class.create "RadioButton" [real_class_toggle_button]

module Radiogroup = struct
  type 'a t = {
    mutable current: 'a option;
    unset: 'a -> unit
  }

  let create unset =
    { current = None; unset = unset }

  let set group element =
    match group.current with
      | None -> group.current <- Some element
      | Some e when e == element -> ()
      | Some e ->
	  group.unset e;
	  group.current <- Some element

  let is_empty group =
    group.current == None

  type has_set_selected = < set_selected : bool -> unit >

    let trivial_unset (element : has_set_selected) =
      element#set_selected false
end

class radio_button parent group = object (self)
  inherit toggle_button parent as super

  val group = match group with
    | None -> Radiogroup.create Radiogroup.trivial_unset
    | Some g -> g

  method real_class = real_class_radio_button

  method group = group

  method class_activate () =
    self#set_selected true

  method set_selected value =
    super#set_selected value;
    if value then
      Radiogroup.set group (self :> Radiogroup.has_set_selected)

  initializer
    left_side <- 40;
    right_side <- 41;
    mark <- 42;
    draw_sides <- false;
    self#signal_toggle#connect 101 (fun v -> self#class_toggle v);
    if Radiogroup.is_empty group then
      self#set_selected true
end
