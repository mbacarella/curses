(**************************************************************************
 * TmkArea
 * Class that encloses the global functions curses windows and pads
 **************************************************************************)

class virtual window = object (self)
  val mutable refresh_queued = false

  method virtual window : Curses.window

  (* Sets the viewport (relative to the parent) for this window *)
  method set_view (_ : int) (_ : int) (_ : int) (_ : int) = ()

  (* Center this window inside its viewport *)
  method set_center (_ : int) (_ : int) = ()

  method resize (_ : int) (_ : int) = ()
  method destroy () = ()

  (* Returns the screen position given the window coordinates *)
  method real_position (p : int * int) = p

  method refresh () =
    refresh_queued <- false

  method queue_refresh q =
    if not refresh_queued then
      let () = Queue.add self#refresh q in
      refresh_queued <- true
end

(* Window used before initialization *)
class null_window = object (self)
  inherit window as super
  method window = assert false
end
let null_window = (new null_window :> window)

(* Toplevel window *)
class toplevel w = object (self)
  inherit window as super
  method window = w
  method refresh () =
    ignore (Curses.refresh ());
    super#refresh ()
end

(* Pad *)
(* TODO: allow to be inside another pad *)
class pad p w h = object (self)
  inherit window as super

  val mutable w = w
  val mutable h = h
  val mutable vx = 0
  val mutable vy = 0
  val mutable vw = 0
  val mutable vh = 0
  val mutable px = 0
  val mutable py = 0

  method window = p

  method refresh () =
    ignore (Curses.prefresh p py px vy vx (vy + vh - 1) (vx + vw - 1));
    ignore (Curses.refresh ());
    super#refresh ()

  method set_view nvx nvy nvw nvh =
    vx <- nvx;
    vy <- nvy;
    vw <- nvw;
    vh <- nvh

  method set_center x y =
    px <- max 0 (min (w - vw) (x - vw / 2));
    py <- max 0 (min (h - vh) (y - vh / 2))

  method resize nw nh =
    w <- nw;
    h <- nh;
    ignore (Curses.wresize p h w)

  method real_position (x,y) =
    (x - px + vx, y - py + vy)

  method destroy () =
    ignore (Curses.delwin p)

end
