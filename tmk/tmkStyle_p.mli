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

val parse :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> TmkStyle.S.configuration
