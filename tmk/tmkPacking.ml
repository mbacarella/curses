open TmkStruct

type 'a box_element = {
  mutable base: int;
  mutable expand: int;
  element: 'a
}

let compute_position t l =
  let (bt, et) = List.fold_left
    (fun (x,y) e -> (x + e.base, y + e.expand)) (0,0) l in
  if bt > t then failwith "too small allocation";
  let et = if et = 0 then 1 else et in
  let ep = t - bt in
  let rec aux xb xe a = function
    | [] -> []
    | h::t ->
	let a = a + h.expand in
	let nxe = a * ep / et in
	((xb + xe, h.base + nxe - xe) ::
	   (aux (xb + h.base) nxe a t)) in
  aux 0 0 0 l


let real_class_box = Class.create "Box" [TmkContainer.real_class_container]

class virtual box parent = object (self)
  inherit TmkContainer.container as super

  val mutable children = []
  val terminal = parent#terminal

  method parent = parent
  method terminal = terminal
  method children () =
    let rec aux = function
      | [] -> []
      | { element = None } :: t -> aux t
      | { element = Some e } :: t -> e :: (aux t) in
    aux children

  method add w =
    children <- children @ [{ base = 0; expand = 0; element = Some w }];
    self#signal_add_descendant#emit w

  method remove w =
    super#remove w;
    let rec aux a = function
      | ({ element = Some c} as h)::t when c == w -> (List.rev a) @ t
      | h::t -> aux (h::a) t
      | [] -> raise Not_found in
    children <- aux [] children

  method add_glue b e =
    children <- children @ [{ base = b; expand = e; element = None }]

  method set_child_expand w e =
    let aux = function
      | { element = Some x } -> x == w
      | _ -> false in
    let c = List.find aux children in
    c.expand <- e

  initializer
    parent#add self#coerce
end

let real_class_vbox = Class.create "VBox" [real_class_box]

class vbox parent = object (self)
  inherit box parent as super

  method real_class = real_class_vbox

  method class_get_size t =
    let aux (cw,ch) e =
      match e.element with
	| Some w ->
	    let (ew,eh) = w#signal_get_size#emit (0,0) in
	    e.base <- eh;
	    (max cw ew, ch + eh)
	| None ->
	    (cw, ch + e.base) in
    List.fold_left aux t children

  method class_set_geometry ((gx,gy,gw,gh) as g) =
    super#class_set_geometry g;
    let ta = compute_position gh children in
    let aux (y,h) = function
      | { element = None } -> ()
      | { element = Some w } ->
	  w#signal_set_geometry#emit (gx, gy + y, gw, h) in
    List.iter2 aux ta children
end


let real_class_hbox = Class.create "Box" [real_class_box]

class hbox parent = object (self)
  inherit box parent as super

  method real_class = real_class_hbox

  method class_get_size t =
    let aux (cw,ch) e =
      match e.element with
	| Some w ->
	    let (ew,eh) = w#signal_get_size#emit (0,0) in
	    e.base <- ew;
	    (cw + ew, max ch eh)
	| None ->
	    (cw + e.base, ch) in
    List.fold_left aux t children

  method class_set_geometry ((gx,gy,gw,gh) as g) =
    super#class_set_geometry g;
    let ta = compute_position gw children in
    let aux (x,l) = function
      | { element = None } -> ()
      | { element = Some w } ->
	  w#signal_set_geometry#emit (gx + x, gy, l, gh) in
    List.iter2 aux ta children
end
