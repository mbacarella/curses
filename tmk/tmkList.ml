open TmkStruct

(****************************************************************************************
 * La classe List
 ****************************************************************************************)

let real_class_list = Class.create "List" [TmkWidget.real_class_widget]

type column_width = {
  mutable min: int;
  mutable elasticity: int;
  mutable left_margin: int;
  mutable right_margin: int;
  mutable alignment: int;
  mutable width: int;
  mutable x: int
}

let array_insert source target pos length init =
  let tl = Array.length target
  and sl = Array.length source in
  let target = if length + sl <= tl then target
  else
    let rec enough t =
      if t >= length + sl then t
      else enough (t * 2) in
    let t = enough (tl * 2) in
    Array.append target (Array.create (t - tl) init) in
  Array.blit target pos target (pos + sl) (length - pos);
  Array.blit source 0 target pos sl;
  target

class list parent columns = object (self)
  inherit TmkWidget.widget as super

  val terminal = parent#terminal

  val widths = Array.init columns
    (fun _ ->
      { min = 1; elasticity = 1; left_margin = 0; right_margin = 0;
        alignment = 0; width = 0; x = 0 })

  val mutable total_fixed_width = columns
  val mutable total_elasticity = columns

  val mutable lines = Array.create 32 [||]
  val mutable selection = Array.create 32 false
  val mutable num_lines = 0

  val mutable current_line = -1
  val mutable top_line = 0
  val mutable scroll_step = 1

  val mutable multi_selection = false

  method real_class = real_class_list
  method parent = parent
  method terminal = terminal
  method can_focus = true

  method set_multi_selection = function
    | true -> multi_selection <- true
    | false ->
	multi_selection <- true;
	Array.fill selection 0 (Array.length selection) false;
	if current_line >= 0 then
	  selection.(current_line) <- true;
	self#queue_redraw ()

  method set_column ~col ~min ~expand ~left ~right ~align =
    let width = widths.(col) in
    total_fixed_width <- total_fixed_width + min + left + right
      - width.min - width.left_margin - width.right_margin;
    total_elasticity <- total_elasticity + expand - width.elasticity;
    width.min <- min;
    width.elasticity <- expand;
    width.left_margin <- left;
    width.right_margin <- right;
    width.alignment <- align;
    self#recompute_widths ();
    self#queue_redraw ()

  method recompute_widths () =
    let expanding = geometry.Geom.w - total_fixed_width in
    let rec column i elasticity rigid beam =
      let width = widths.(i) in
      let e = elasticity + width.elasticity in
      let b = expanding * e / total_elasticity in
      let r = width.min + width.left_margin + width.right_margin in
      width.width <- width.min + b - beam;
      width.x <- rigid + beam + width.left_margin;
      if i < pred columns then
	column (succ i) e (rigid + r) b in
    column 0 0 geometry.Geom.x 0

  method insert_lines pos more_lines =
    let pos = if pos < 0 || pos > num_lines then num_lines else pos in
    let n = Array.length more_lines in
    for i = 0 to pred n do
      if Array.length more_lines.(i) < columns then
	invalid_arg "List#insert_lines: too few columns"
    done;
    lines <- array_insert more_lines lines pos num_lines [||];
    let more_selection = Array.create n false in
    selection <- array_insert more_selection selection pos num_lines false;
    let new_current =
      if current_line < 0 then 0 else
      	if current_line >= pos then current_line + n else current_line in
    num_lines <- num_lines + n;
    self#go_to_line new_current;
    self#queue_redraw ()

  method append_lines more_lines =
    self#insert_lines num_lines more_lines

  method insert_line pos line =
    self#insert_lines pos [|line|]

  method append_line line =
    self#insert_lines num_lines [|line|]

  method set_variable name subscripts value =
    match (name, subscripts, value) with
      | ("scroll_step", None, TmkStyle.S.Int v) ->
	  scroll_step <- v
      | _ -> super#set_variable name subscripts value

  method class_get_size _ =
    (total_fixed_width, 1)

  method class_set_geometry g =
    super#class_set_geometry g;
    self#recompute_widths ();
    self#realign ()

  method draw_line line =
    let y = geometry.Geom.y + line - top_line in
    let line_state = State.set_focus state
      (State.has_focus state && line = current_line) in
    let line_state = State.set_selected line_state selection.(line) in
    let attribute = attributes.(State.to_int line_state) in
    Curses.wattrset window attribute;
    ignore (Curses.wmove window y geometry.Geom.x);
    Curses.whline window 32 geometry.Geom.w;
    if State.has_focus line_state then
      self#set_cursor (geometry.Geom.x, y);
    if line < num_lines then
      let line = lines.(line) in
      for i = 0 to pred columns do
      	let string = line.(i) in
      	let length = String.length string in
      	let x_more = widths.(i).width - length in
      	if x_more >= 0 then
	  let x = widths.(i).x + widths.(i).alignment * x_more / 100 in
      	  ignore (Curses.mvwaddstr window y x string)
      	else
	  let o = widths.(i).alignment * (-x_more) / 100 in
	  ignore (Curses.mvwaddnstr window y widths.(i).x string
	    o widths.(i).width)
      done

  method class_draw () =
    super#class_draw ();
    for i = 0 to pred geometry.Geom.h do
      self#draw_line (top_line + i)
    done

  method realign () =
    if current_line < top_line ||
      current_line >= top_line + geometry.Geom.h
    then (
      top_line <- current_line - geometry.Geom.y / 2;
      top_line <- max 0 (min (num_lines - geometry.Geom.h) top_line);
      self#queue_redraw ()
    )

  method go_to_line l =
    let l = max (min l (pred num_lines)) 0 in
    let emit = l != current_line in
    let old = if current_line < 0 then l else current_line in
    current_line <- l;
    if not multi_selection then (
      selection.(old) <- false;
      selection.(l) <- true
    );
    if geometry.Geom.h > 0 then (
      if l >= top_line && l < top_line + geometry.Geom.h then (
      	self#draw_line old;
      	self#draw_line l
      ) else (
      	let t = l - old + top_line in
      	let t =
	  if t < top_line then min t (top_line - scroll_step)
	  else max t (top_line + scroll_step) in
      	let t = max 0 (min (num_lines - geometry.Geom.h) t) in
      	top_line <- t;
      	self#realign ();
	self#queue_redraw ()
      )
    );
    self#signal_move_to_line#emit l

  method set_select_line line value =
    if not multi_selection then
      failwith "List#select_line: illegal";
    if selection.(line) != value then (
      selection.(line) <- value;
      if value then self#signal_select_line#emit line
      else self#signal_deselect_line#emit line;
    	self#draw_line line
    )

  method select_line line = self#set_select_line line true
  method deselect_line line = self#set_select_line line false

  method current_line = current_line
  method selected line = selection.(line)
  method get_line line = lines.(line)
  method get_lines () = Array.sub lines 0 num_lines

  method set_line line value =
    if Array.length value < columns then
      invalid_arg "List#set_line: too few columns";
    lines.(line) <- value;
    self#draw_line line

  method delete_lines start num =
    let stop = start + num in
    if start < 0 || num <= 0 || stop > num_lines then
      invalid_arg "List#delete_lines";
    Array.blit lines stop lines start (num_lines - stop);
    Array.blit selection stop selection start (num_lines - stop);
    num_lines <- num_lines - num;
    Array.fill lines num_lines num [||];
    Array.fill selection num_lines num false;
    (* TODO: réduire les tableaux *)
    if current_line >= start then (
      let new_line =
	if current_line >= stop then current_line - num else start in
      self#realign ()
    );
    self#queue_redraw ()

  method class_got_focus () =
    super#class_got_focus ();
    self#set_cursor (geometry.Geom.x, geometry.Geom.y + (max current_line 0))

  method class_key_event key =
    if key = 32 || key = 10 && multi_selection && current_line >= 0 then (
      self#set_select_line current_line (not selection.(current_line));
      true
    ) else
      let keys = [
      	Curses.Key.up, current_line - 1;
      	Curses.Key.down, current_line + 1;
      	Curses.Key.ppage, current_line - geometry.Geom.h;
      	Curses.Key.npage, current_line + geometry.Geom.h;
      	Curses.Key.home, 0;
      	Curses.Key.end_, pred num_lines ] in
      try
      	let l = List.assoc key keys in
      	if current_line >= 0 then
	  self#go_to_line l;
      	true
      with Not_found -> super#class_key_event key

  val signal_select_line =
    new TmkSignal.signal "select_line" TmkSignal.Marshall.all_unit
  val signal_deselect_line =
    new TmkSignal.signal "deselect_line" TmkSignal.Marshall.all_unit
  val signal_move_to_line =
    new TmkSignal.signal "move_to_line" TmkSignal.Marshall.all_unit

  method signal_select_line = signal_select_line
  method signal_deselect_line = signal_deselect_line
  method signal_move_to_line = signal_move_to_line

  method class_select_line line = ()
  method class_deselect_line line = ()
  method class_move_to_line line = ()

  initializer
    if columns < 1 then invalid_arg "List: too few columns";
    self#signal_select_line#connect 101 (fun l -> self#class_select_line l);
    self#signal_deselect_line#connect 101 (fun l -> self#class_deselect_line l);
    self#signal_move_to_line#connect 101 (fun l -> self#class_move_to_line l);
    parent#add self#coerce

end
