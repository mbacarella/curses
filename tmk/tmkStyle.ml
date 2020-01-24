module R = struct
  type t = {
    can_color: bool;
    mutable color_init: bool;
    mutable max_pairs: int;
    mutable num_pairs: int;
    mutable pairs: string
  }

  let create () =
    { can_color = Curses.has_colors ();
      color_init = false;
      max_pairs = 0;
      num_pairs = 1;
      pairs = "" }

  let can_color r = r.can_color

  let color_init r =
    assert r.can_color;
    if not r.color_init then (
      ignore (Curses.start_color ());
      r.color_init <- true;
      r.max_pairs <- min (max (Curses.color_pairs ()) 0) 256;
      r.pairs <- String.make r.max_pairs '\255'
    )

  let color_pair_alloc r f b =
    if r.can_color then
      let () = color_init r in
      let i = f + b * 8 in
      let t = int_of_char r.pairs.[i] in
      if t < r.num_pairs then t
      else
      	let t = r.num_pairs in
      	let () = r.num_pairs <- succ t in
      	let _ = Curses.init_pair t f b in
      	let () = r.pairs.[i] <- char_of_int t in
      	t
    else 0

  let color_pair_query r p =
    try
      let c = String.index r.pairs (char_of_int p) in
      (c land 7, c lsl 3)
    with Not_found -> (0,0)
end

module P = struct
  type t = (bool * int list) array

  let star = '*'

  module CSet = Set.Make (struct type t = char  let compare = compare end)

  let compile m =
    let l = String.length m in
    let rec transition at oe ne le fb =
      if ne + oe = l then
      	(true, if fb = ne then [fb lsl 8] else []) :: at
      else
      	let c = m.[ne + oe] in
      	if m.[ne + oe] = star then
      	  transition at (succ oe) ne [ne] ne
      	else
      	  let rec etat cc = function
	    | [] -> if fb < 0 then [] else [fb lsl 8]
	    | he::te ->
	      	let c = m.[he + oe] in
	      	if CSet.mem c cc then
	      	  etat cc te
	      	else
	      	  (((succ he) lsl 8) + (int_of_char c)) ::
	      	  (etat (CSet.add c cc) te) in
      	  let rec etats = function
	    | [] -> if fb < 0 then [] else [fb]
	    | h::t ->
	      	let r = etats t in
	      	if m.[h + oe] = c then (succ h) :: r
	      	else r in
      	  let tr = etat CSet.empty le in
      	  transition ((false, tr) :: at) oe (succ ne) (etats le) fb in
    let tt = transition [] 0 0 [0] (-1) in
    let l = List.length tt in
    let r = Array.create l (false, []) in
    let rec fill i = function
      | [] -> ()
      | h::t -> r.(i) <- h; fill (pred i) t in
    fill (pred l) tt;
    (r : t)

  let match_string (cp : t) t =
    let rec find c = function
      | [] -> raise Not_found
      | h::_ when h land 255 = c || h land 255 = 0 -> h lsr 8
      | _::t -> find c t in
    let lt = String.length t in
    let rec aux e i =
      let (ete,etr) = cp.(e) in
      if i = lt then ete
      else
      	let ne = find (int_of_char t.[i]) etr in
      	aux ne (succ i) in
    try aux 0 0
    with Not_found -> false
end

module S = struct
  type configuration =
      specification list
  and specification =
    | Def of string * string list option * value
    | Sub of condition * configuration
  and value =
    | Int of int
    | Str of string
  and condition =
    | And of condition * condition
    | Or of condition * condition
    | Not of condition
    | Term of term
  and term =
    | Var of string
    | Pat of P.t
    | Eq of string * string
    | Neq of string * string
    | Match of string * P.t

  let config_sources = ref []

  let add_config_source s =
    config_sources := s :: !config_sources

  let config_tree = ref ([] : configuration)

  let process_config_sources () =
    let rec aux a = function
      | [] -> a
      | h::t -> let a = (h ()) @ a in aux a t in
    let t = aux [] (List.rev !config_sources) in
    config_tree := t

  let eval_bool_string s =
    (s <> "" ) &&
    (try int_of_string s <> 0 with Failure "int_of_string" -> true)


  let check_condition var wid cond =
    let rec aux = function
      | And (c1, c2) -> (aux c1) && (aux c2)
      | Or (c1, c2) -> (aux c1) || (aux c2)
      | Not c -> not (aux c)
      | Term (Var v) -> eval_bool_string (var v)
      | Term (Pat p) -> P.match_string p wid
      | Term (Eq (v,s)) -> var v = s
      | Term (Neq (v,s)) -> var v <> s
      | Term (Match (v,p)) -> P.match_string p (var v) in
    aux cond

  let relevant_variables var wid cfg =
    let rec aux a = function
      | (Def (v,i,d)) :: t -> aux ((v,i,d) :: a) t
      | (Sub (c,s)) :: t ->
	  let a =
	    if check_condition var wid c then (aux [] s) @ a
	    else a in
	  aux a t
      | [] -> List.rev a in
    aux [] cfg

  type simplified_condition =
    | True
    | False
    | Cond of condition

  let simplify_condition var wid cond =
    let rec aux = function
      | And (c1, c2) ->
	  (match aux c1 with
	     | True -> aux c2
	     | False -> False
	     | Cond c1 ->
		 match aux c2 with
		   | True -> Cond c1
		   | False -> False
		   | Cond c2 -> Cond (And (c1, c2)))
      | Or (c1, c2) ->
	  (match aux c1 with
	     | False -> aux c2
	     | True -> True
	     | Cond c1 ->
		 match aux c2 with
		   | False -> Cond c1
		   | True -> True
		   | Cond c2 -> Cond (Or (c1, c2)))
      | Not c ->
	  (match aux c with
	     | False -> True
	     | True -> False
	     | c -> c)
      | Term (Var v) as t ->
	  (match var v with
	     | Some v ->
		 if eval_bool_string v then True else False
	     | None -> Cond t)
      | Term (Pat p) as t ->
	  (match wid with
	     | Some wid -> if P.match_string p wid then True else False
	     | None -> Cond t)
      | Term (Eq (v,s)) as t ->
	  (match var v with
	    | Some v -> if v = s then True else False
	    | None -> Cond t)
      | Term (Neq (v,s)) as t ->
	  (match var v with
	    | Some v -> if v <> s then True else False
	    | None -> Cond t)
      | Term (Match (v,p)) as t ->
	  (match var v with
	    | Some v -> if P.match_string p v then True else False
	    | None -> Cond t) in
    aux cond

  let simplify_configuration var wid cfg =
    let rec aux a = function
      | (Sub (c,s)) :: t ->
	  (match simplify_condition var wid c with
	     | True -> aux ((aux [] s) @ a) t
	     | False -> aux a t
	     | Cond c -> aux ((Sub (c, aux [] s)) :: a) t)
      | h::t -> aux (h::a) t
      | [] -> List.rev a in
    aux [] cfg

end

module C = struct
  let style_comm m c v =
    if c then v lor m else v land (lnot m)

  let style_u = style_comm Curses.A.underline
  let style_r = style_comm Curses.A.reverse
  let style_l = style_comm Curses.A.blink
  let style_g = style_comm Curses.A.bold
  let style_s = style_comm Curses.A.standout

  let style_color = function
    | 'r' -> Curses.Color.red
    | 'g' -> Curses.Color.green
    | 'y' -> Curses.Color.yellow
    | 'l' -> Curses.Color.blue
    | 'm' -> Curses.Color.magenta
    | 'c' -> Curses.Color.cyan
    | 'w' -> Curses.Color.white
    | _ -> Curses.Color.black

  let style_f c v =
    (v land (lnot 0x0F)) lor (style_color c)

  let style_b c v =
    (v land (lnot 0xF0)) lor ((style_color c) lsl 4)

  let encode r a =
    let f = a land Curses.A.attributes land (lnot Curses.A.color)
    and p = Curses.A.pair_number a in
    let (fg,bg) = R.color_pair_query r p in
    f lor (fg land 7) lor ((bg land 7) lsr 4)

  let decode r a =
    let f = a land 0x7FFFFF00
    and fg = a land 0x07
    and bg = (a land 0x70) lsr 4 in
    let p = R.color_pair_alloc r fg bg in
    f lor (Curses.A.color_pair p)

  let parse_style_string r a f =
    let a = encode r a in
    let l = String.length f in
    let rec aux v i =
      if i = l then v
      else
	let i = succ i in
	match f.[pred i] with
	  | '<' -> aux a i
	  | 'U' -> aux (style_u true v) i
	  | 'u' -> aux (style_u false v) i
	  | 'R' -> aux (style_r true v) i
	  | 'r' -> aux (style_r false v) i
	  | 'L' -> aux (style_l true v) i
	  | 'l' -> aux (style_l false v) i
	  | 'G' -> aux (style_g true v) i
	  | 'g' -> aux (style_g false v) i
	  | 'S' -> aux (style_s true v) i
	  | 's' -> aux (style_s false v) i
	  | 'F' when i < l -> aux (style_f f.[i] v) (succ i)
	  | 'B' when i < l -> aux (style_b f.[i] v) (succ i)
	  | _ -> aux v i in
    decode r (aux 0 0)

  let state_names s =
    let rec aux a = function
      | "normal"::t -> aux (0::a) t
      | "focus"::t -> aux (1::a) t
      | "selected"::t -> aux (2::a) t
      | "insensitive"::t -> aux (3::a) t
      | "all"::t -> [0;1;2;3]
      | _::t -> aux a t
      | [] -> a in
    aux [] s

end
