type token =
    Equal
  | Nequal
  | Tilde
  | LBracket
  | RBracket
  | LBrace
  | RBrace
  | LParen
  | RParen
  | Comma
  | Ident of (string)
  | Env of (string)
  | Str of (string)
  | Int of (int)
  | And
  | Or
  | Not
  | Eof

open Parsing

# 2 "tmkStyle_p.mly"
# 2 "tmkStyle_p.mly"
  open TmkStyle

# 7 "tmkStyle_p.ml"
let yytransl_const = [|
  257 (* Equal *);
  258 (* Nequal *);
  259 (* Tilde *);
  260 (* LBracket *);
  261 (* RBracket *);
  262 (* LBrace *);
  263 (* RBrace *);
  264 (* LParen *);
  265 (* RParen *);
  266 (* Comma *);
  271 (* And *);
  272 (* Or *);
  273 (* Not *);
  274 (* Eof *);
    0|]

let yytransl_block = [|
  267 (* Ident *);
  268 (* Env *);
  269 (* Str *);
  270 (* Int *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\003\000\003\000\004\000\004\000\007\000\
\007\000\005\000\005\000\006\000\006\000\006\000\006\000\006\000\
\008\000\008\000\008\000\008\000\008\000\008\000\008\000\008\000\
\000\000"

let yylen = "\002\000\
\002\000\000\000\002\000\004\000\006\000\000\000\003\000\001\000\
\003\000\001\000\001\000\003\000\003\000\002\000\003\000\001\000\
\001\000\001\000\003\000\003\000\003\000\003\000\003\000\003\000\
\002\000"

let yydefred = "\000\000\
\002\000\000\000\025\000\000\000\000\000\000\000\001\000\003\000\
\000\000\000\000\000\000\018\000\000\000\000\000\016\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\014\000\000\000\000\000\000\000\008\000\000\000\000\000\015\000\
\019\000\021\000\023\000\020\000\022\000\024\000\002\000\012\000\
\000\000\007\000\000\000\011\000\010\000\004\000\000\000\009\000\
\005\000"

let yydgoto = "\002\000\
\003\000\004\000\008\000\017\000\046\000\014\000\030\000\015\000"

let yysindex = "\002\000\
\000\000\000\000\000\000\250\254\254\254\009\255\000\000\000\000\
\254\254\032\255\035\255\000\000\254\254\248\254\000\000\028\255\
\030\255\005\255\027\255\029\255\031\255\033\255\034\255\036\255\
\000\000\037\255\254\254\254\254\000\000\020\255\013\255\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\026\255\000\000\039\255\000\000\000\000\000\000\021\255\000\000\
\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\044\255\000\000\000\000\
\000\000\007\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\008\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000"

let yygindex = "\000\000\
\000\000\009\000\000\000\000\000\000\000\247\255\000\000\000\000"

let yytablesize = 50
let yytable = "\018\000\
\026\000\005\000\001\000\025\000\006\000\009\000\027\000\028\000\
\010\000\011\000\012\000\007\000\016\000\032\000\013\000\017\000\
\013\000\040\000\041\000\027\000\028\000\017\000\017\000\013\000\
\042\000\044\000\045\000\049\000\005\000\043\000\031\000\006\000\
\019\000\020\000\021\000\022\000\023\000\024\000\029\000\033\000\
\027\000\034\000\039\000\035\000\006\000\036\000\037\000\047\000\
\038\000\048\000"

let yycheck = "\009\000\
\009\001\008\001\001\000\013\000\011\001\008\001\015\001\016\001\
\011\001\012\001\013\001\018\001\004\001\009\001\017\001\009\001\
\009\001\027\000\028\000\015\001\016\001\015\001\016\001\016\001\
\005\001\013\001\014\001\007\001\008\001\010\001\001\001\011\001\
\001\001\002\001\003\001\001\001\002\001\003\001\011\001\013\001\
\015\001\013\001\006\001\013\001\001\001\013\001\013\001\039\000\
\013\001\011\001"

let yynames_const = "\
  Equal\000\
  Nequal\000\
  Tilde\000\
  LBracket\000\
  RBracket\000\
  LBrace\000\
  RBrace\000\
  LParen\000\
  RParen\000\
  Comma\000\
  And\000\
  Or\000\
  Not\000\
  Eof\000\
  "

let yynames_block = "\
  Ident\000\
  Env\000\
  Str\000\
  Int\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun parser_env ->
    let _1 = (peek_val parser_env 1 : 'specification_list) in
    Obj.repr((

# 28 "tmkStyle_p.mly"
                          # 27 "tmkStyle_p.mly"
                           List.rev _1 ) : TmkStyle.S.configuration))
; (fun parser_env ->
    Obj.repr((

# 32 "tmkStyle_p.mly"
               # 31 "tmkStyle_p.mly"
                [] ) : 'specification_list))
; (fun parser_env ->
    let _1 = (peek_val parser_env 1 : 'specification_list) in
    let _2 = (peek_val parser_env 0 : 'specification) in
    Obj.repr((

# 33 "tmkStyle_p.mly"
                                    # 32 "tmkStyle_p.mly"
                                     _2::_1 ) : 'specification_list))
; (fun parser_env ->
    let _1 = (peek_val parser_env 3 : string) in
    let _2 = (peek_val parser_env 2 : 'subscript) in
    let _4 = (peek_val parser_env 0 : 'rvalue) in
    Obj.repr((

# 37 "tmkStyle_p.mly"
                                # 36 "tmkStyle_p.mly"
                                 S.Def (_1, _2, _4) ) : 'specification))
; (fun parser_env ->
    let _2 = (peek_val parser_env 4 : 'condition) in
    let _5 = (peek_val parser_env 1 : 'specification_list) in
    Obj.repr((

# 38 "tmkStyle_p.mly"
                                                            # 37 "tmkStyle_p.mly"
                                                             S.Sub (_2, _5) ) : 'specification))
; (fun parser_env ->
    Obj.repr((

# 42 "tmkStyle_p.mly"
               # 41 "tmkStyle_p.mly"
                None ) : 'subscript))
; (fun parser_env ->
    let _2 = (peek_val parser_env 1 : 'subscript_list) in
    Obj.repr((

# 43 "tmkStyle_p.mly"
                                    # 42 "tmkStyle_p.mly"
                                     Some (List.rev _2) ) : 'subscript))
; (fun parser_env ->
    let _1 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 47 "tmkStyle_p.mly"
         # 46 "tmkStyle_p.mly"
          [_1] ) : 'subscript_list))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : 'subscript_list) in
    let _3 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 48 "tmkStyle_p.mly"
                              # 47 "tmkStyle_p.mly"
                               _3::_1 ) : 'subscript_list))
; (fun parser_env ->
    let _1 = (peek_val parser_env 0 : int) in
    Obj.repr((

# 52 "tmkStyle_p.mly"
       # 51 "tmkStyle_p.mly"
        S.Int _1 ) : 'rvalue))
; (fun parser_env ->
    let _1 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 53 "tmkStyle_p.mly"
       # 52 "tmkStyle_p.mly"
        S.Str _1 ) : 'rvalue))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : 'condition) in
    let _3 = (peek_val parser_env 0 : 'condition) in
    Obj.repr((

# 57 "tmkStyle_p.mly"
                           # 56 "tmkStyle_p.mly"
                            S.And (_1, _3) ) : 'condition))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : 'condition) in
    let _3 = (peek_val parser_env 0 : 'condition) in
    Obj.repr((

# 58 "tmkStyle_p.mly"
                          # 57 "tmkStyle_p.mly"
                           S.Or (_1, _3) ) : 'condition))
; (fun parser_env ->
    let _2 = (peek_val parser_env 0 : 'condition) in
    Obj.repr((

# 59 "tmkStyle_p.mly"
                 # 58 "tmkStyle_p.mly"
                  S.Not _2 ) : 'condition))
; (fun parser_env ->
    let _2 = (peek_val parser_env 1 : 'condition) in
    Obj.repr((

# 60 "tmkStyle_p.mly"
                           # 59 "tmkStyle_p.mly"
                            _2 ) : 'condition))
; (fun parser_env ->
    let _1 = (peek_val parser_env 0 : 'term) in
    Obj.repr((

# 61 "tmkStyle_p.mly"
        # 60 "tmkStyle_p.mly"
         S.Term _1 ) : 'condition))
; (fun parser_env ->
    let _1 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 65 "tmkStyle_p.mly"
         # 64 "tmkStyle_p.mly"
          S.Var _1 ) : 'term))
; (fun parser_env ->
    let _1 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 66 "tmkStyle_p.mly"
       # 65 "tmkStyle_p.mly"
        S.Pat (P.compile _1) ) : 'term))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : string) in
    let _3 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 67 "tmkStyle_p.mly"
                   # 66 "tmkStyle_p.mly"
                    S.Eq (_1, _3) ) : 'term))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : string) in
    let _3 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 68 "tmkStyle_p.mly"
                 # 67 "tmkStyle_p.mly"
                  S.Eq (_1, _3) ) : 'term))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : string) in
    let _3 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 69 "tmkStyle_p.mly"
                    # 68 "tmkStyle_p.mly"
                     S.Neq (_1, _3) ) : 'term))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : string) in
    let _3 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 70 "tmkStyle_p.mly"
                  # 69 "tmkStyle_p.mly"
                   S.Neq (_1, _3) ) : 'term))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : string) in
    let _3 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 71 "tmkStyle_p.mly"
                   # 70 "tmkStyle_p.mly"
                    S.Match (_1, P.compile _3) ) : 'term))
; (fun parser_env ->
    let _1 = (peek_val parser_env 2 : string) in
    let _3 = (peek_val parser_env 0 : string) in
    Obj.repr((

# 72 "tmkStyle_p.mly"
                 # 71 "tmkStyle_p.mly"
                  S.Match (_1, P.compile _3) ) : 'term))
(* Entry parse *)
; (fun parser_env -> raise (YYexit (peek_val parser_env 0)))
|]
let yytables =
  { actions=yyact;
    transl_const=yytransl_const;
    transl_block=yytransl_block;
    lhs=yylhs;
    len=yylen;
    defred=yydefred;
    dgoto=yydgoto;
    sindex=yysindex;
    rindex=yyrindex;
    gindex=yygindex;
    tablesize=yytablesize;
    table=yytable;
    check=yycheck;
    error_function=parse_error;
    names_const=yynames_const;
    names_block=yynames_block }
let parse (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (yyparse yytables 1 lexfun lexbuf : TmkStyle.S.configuration)
