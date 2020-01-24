open TmkStruct

(****************************************************************************************
 * La classe Entry
 ****************************************************************************************)

let real_class_entry = Class.create "Entry" [TmkWidget.real_class_widget]

class entry parent = object (self)
  inherit TmkWidget.widget as super

  val terminal = parent#terminal

  val mutable text = String.create 128
  val mutable text_length = 0
  val mutable text_offset = 0
  val mutable cursor = 0

  val mutable accept_key = function _ -> true

  method real_class = real_class_entry
  method parent = parent
  method terminal = terminal
  method can_focus = true

  method class_get_size _ =
    (2, 1)

  method class_draw () =
    super#class_draw ();
    Curses.wattrset window attribute;
    ignore (Curses.wmove window geometry.Geom.y geometry.Geom.x);
    Curses.whline window 32 geometry.Geom.w;
    ignore (Curses.waddnstr window text text_offset
      (min (text_length - text_offset) geometry.Geom.w));
    if self#has_focus then
      self#set_cursor (geometry.Geom.x + cursor - text_offset,
      geometry.Geom.y)

  method cursor = cursor

  method move_cursor pos =
    let pos = min (max pos 0) text_length in
    cursor <- pos;
    if cursor < text_offset || cursor >= text_offset + geometry.Geom.w then (
      text_offset <- max 0 (cursor - geometry.Geom.w / 2);
      self#queue_redraw ()
    );
    if self#has_focus then
      terminal#set_cursor
	(geometry.Geom.x + cursor - text_offset, geometry.Geom.y)

  method insert_string string =
    let len = String.length string in
    let lt = String.length text in
    if text_length + len > lt then (
      let rec aux t =
	if t >= text_length + len then t - lt
	else aux (t * 2) in
      let t = aux (lt * 2) in
      text <- text ^ (String.create t)
    );
    String.blit text cursor text (cursor + len) (text_length - cursor);
    String.blit string 0 text cursor len;
    text_length <- text_length + len;
    self#move_cursor (cursor + len);
    self#queue_redraw ()

  method delete pos len =
    if pos < 0 || pos + len > text_length then
      invalid_arg "Entry#delete";
    String.blit text (pos + len) text pos (text_length - pos - len);
    text_length <- text_length - len;
    if cursor > pos then
      self#move_cursor (max pos (cursor - len));
    self#queue_redraw ()

  method class_key_event key =
    if key >= 32 && key <= 126 || key >= 160 && key <= 255 then (
      let char = char_of_int key in
      if accept_key char then
    	let string = String.make 1 char in
	self#insert_string string
      else
	ignore (Curses.beep ());
      true
    ) else if key = Curses.Key.right then (
      self#move_cursor (succ cursor);
      true
    ) else if key = Curses.Key.left then (
      self#move_cursor (pred cursor);
      true
    ) else if key = Curses.Key.backspace then (
      if cursor > 0 then
	self#delete (pred cursor) 1;
      true
    ) else if key = Curses.Key.dc then (
      if cursor < text_length then
	self#delete cursor 1;
      true
    ) else
      super#class_key_event key

  initializer
    parent#add self#coerce;
    String.blit "foobar" 0 text 0 6;
    text_length <- 6
end
