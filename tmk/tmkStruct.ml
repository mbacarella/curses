module Geom = struct
  type t = {
    mutable x: int;
    mutable y: int;
    mutable w: int;
    mutable h: int;
  }

  let null () =
    { x = 0; y = 0; w = 0; h = 0 }

  let record (x,y,w,h) g =
    g.x <- x;
    g.y <- y;
    g.w <- w;
    g.h <- h
end

module State = struct
  type t = bool * bool * bool

		(* focus, selected, sensitive *)
  let normal : t = (false, false, true)

  let to_int (f,s,a) =
    if a then (if f then 1 else if s then 2 else 0) else 3

  let to_int_max = 3

  let set_focus (_,s,a) f = (f,s,a)
  let set_selected (f,_,a) s = (f,s,a)
  let set_sensitive (f,s,_) a = (f,s,a)

  let has_focus (f,_,_) = f
  let is_selected (_,s,_) = s
  let is_sensitive (_,_,a) = a
end

module Direction = struct
  type t =
    | Previous
    | Next
    | Left
    | Right
    | Up
    | Down
end

module Class = struct
  type t = {
    name : string;
    parents : t list
  }

  let all_classes = Hashtbl.create 127
    
  let create n p =
    let c = { name = n; parents = p } in
    Hashtbl.add all_classes n c;
    c

  let get = Hashtbl.find all_classes

  let rec is_a p c =
    (c == p) ||
    (List.exists (is_a p) c.parents)
end

module Toplevel = struct
  type t =
    | Activate
    | Desactivate
    | Key of int

  type 'w m =
    | Give_focus of 'w
end

module Cache = struct
  type 'a t = 'a Weak.t * (unit -> 'a)

  let create f =
    let t = Weak.create 1 in
    ((t,f) : _ t)

  let get ((t,f) : _ t) =
    match Weak.get t 0 with
      | Some v -> v
      | None ->
	  let v = f () in
	  Weak.set t 0 (Some v);
	  v

  let clear ((t,_) : _ t) =
    Weak.set t 0 None
end

module Once = struct
  type t = {
    mutable already: bool;
    queue: (unit -> unit) Queue.t;
    func: (unit -> unit)
  }

  let create q =
    { already = true; queue = q; func = ignore }

  let deliver o () =
    ()

  let add o f =
    if not o.already then (
      o.already <- true;
      Queue.add (deliver o) o.queue
    )
end
