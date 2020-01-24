open TmkStruct
open Curses

(****************************************************************************************
 * La classe Frame
 ****************************************************************************************)

let real_class_frame = Class.create "Frame" [TmkContainer.real_class_bin]

class frame parent text = object (self)
  inherit TmkContainer.bin as super

  val acs = parent#terminal#acs

  method real_class = real_class_frame
  method parent = parent
  method terminal = parent#terminal

  method class_get_size t =
    match child with
      | None -> t
      | Some c ->
	  let (w, h) = c#signal_get_size#emit t in
	  let w = max w (String.length text) in
	  (w + 2, h + 2)

  method class_set_geometry g =
    super#class_set_geometry g;
    match child with
      | None -> ()
      | Some c ->
	  c#signal_set_geometry#emit
	    (succ geometry.Geom.x, succ geometry.Geom.y,
	    geometry.Geom.w - 2, geometry.Geom.h)

  method class_draw () =
    super#class_draw ();
    let x1 = geometry.Geom.x
    and y1 = geometry.Geom.y
    and w = geometry.Geom.w - 2
    and h = geometry.Geom.h - 2 in
    let x2 = succ x1 + w
    and y2 = succ y1 + h in
    ignore (wmove window y1 x1);
    wattrset window attribute;
    ignore (waddch window acs.Acs.ulcorner);
    ignore (waddstr window text);
    ignore (whline window 0 (w - (String.length text)));
    ignore (mvwaddch window y1 x2 acs.Acs.urcorner);
    ignore (mvwaddch window y2 x1 acs.Acs.llcorner);
    ignore (whline window 0 w);
    ignore (mvwaddch window y2 x2 acs.Acs.lrcorner);
    ignore (wmove window (succ y1) x1);
    ignore (wvline window 0 h);
    ignore (wmove window (succ y1) x2);
    ignore (wvline window 0 h)

  initializer
    parent#add self#coerce;
end


(****************************************************************************************
 * La classe Rule
 ****************************************************************************************)

let real_class_rule = Class.create "Rule" [TmkWidget.real_class_widget]

class rule parent direction = object (self)
  inherit TmkWidget.widget as super

  val terminal = parent#terminal

  method real_class = real_class_rule
  method parent = parent
  method terminal = terminal

  method class_get_size t =
    (1, 1)

  method class_draw () =
    super#class_draw ();
    wattrset window attribute;
    match direction with
      | `Vertical ->
	  ignore (wmove window geometry.Geom.y
	    (geometry.Geom.x + geometry.Geom.w / 2));
	  ignore (wvline window 0 geometry.Geom.h)
      | `Horizontal ->
	  ignore (wmove window (geometry.Geom.y + geometry.Geom.h / 2)
	    geometry.Geom.x);
	  ignore (whline window 0 geometry.Geom.w)

  initializer
    parent#add self#coerce;
end
