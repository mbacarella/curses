class ['a,'b] signal name filter = object (self)
  val mutable callbacks : (int * ('a -> 'b)) list = []

  method emit : 'a -> 'b =
    function x -> filter x callbacks

  method connect p f =
    let rec connect_aux = function
      | [] -> [p, f]
      | (ph,_)::_ as q when ph < p -> (p,f)::q
      | h::t -> h::(connect_aux t) in
    callbacks <- connect_aux callbacks

  method disconnect f =
    let rec disconnect_aux = function
      | [] -> []
      | (_,fh)::t as q when fh == f -> t
      | h::t -> h::(disconnect_aux t) in
    callbacks <- disconnect_aux callbacks
end

module Marshall = struct
  let rec all_unit a = function
    | (_,h)::t -> let () = h a in all_unit a t
    | [] -> ()

  let rec filter a = function
    | (_,h)::t -> let a = h a in filter a t
    | [] -> a

  let rec until_true a = function
    | (_,h)::t -> (h a) && (until_true a t)
    | [] -> false
end
