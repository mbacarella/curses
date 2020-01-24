open TmkStruct

let real_class_misc = Class.create "Misc" [TmkWidget.real_class_widget]

class virtual misc w h = object (self)
  inherit TmkWidget.widget as super

  val mutable xalign = 50
  val mutable yalign = 50
  val mutable width = w
  val mutable height = h

  method set_align x y =
    if x >= 0 && x <= 100 then
      xalign <- x;
    if y >= 0 && y <= 100 then
      yalign <- y

  method class_get_size (w, h) =
    (width, height)

  method class_set_geometry (x, y, w, h) =
    let wa = w - width
    and ha = h - height in
    let g = (x + xalign * wa / 100, y + yalign * ha / 100,
      width, height) in
    super#class_set_geometry g
end

(****************************************************************************************
 * La classe Label
 ****************************************************************************************)

let real_class_label = Class.create "Label" [real_class_misc]

class label parent t = object (self)
  inherit misc (String.length t) 1 as super

  val mutable txt = t
  val terminal = parent#terminal

  method real_class = real_class_label
  method parent = parent
  method terminal = terminal

  method class_get_size t =
    (String.length txt, 1)

  method class_draw () =
    super#class_draw ();
    let l = String.length txt in
    if l <= geometry.Geom.w then (
      Curses.wattrset window attribute;
      ignore (Curses.mvwaddstr window geometry.Geom.y geometry.Geom.x txt)
    ) else (
    )

  initializer
    parent#add self#coerce;
end
