{
  let strbuf = Buffer.create 128
}

let word = ['a'-'z' 'A'-'Z' '0'-'9' '_']
let word_start = ['a'-'z' 'A'-'Z' '_']

rule lexeme = parse
    [' ' '\n' '\r' '\t'] { lexeme lexbuf }
  | '=' { TmkStyle_p.Equal }
  | "!=" { TmkStyle_p.Nequal }
  | '~' { TmkStyle_p.Tilde }
  | '[' { TmkStyle_p.LBracket }
  | ']' { TmkStyle_p.RBracket }
  | '{' { TmkStyle_p.LBrace }
  | '}' { TmkStyle_p.RBrace }
  | '(' { TmkStyle_p.LParen }
  | ')' { TmkStyle_p.RParen }
  | ',' { TmkStyle_p.Comma }
  | '&' '&'? { TmkStyle_p.And }
  | '|' '|'? { TmkStyle_p.Or }
  | '!' { TmkStyle_p.Not }
  | '$' word+ { TmkStyle_p.Env (Lexing.lexeme lexbuf) }
  | word_start word* { TmkStyle_p.Ident (Lexing.lexeme lexbuf) }
  | ['0'-'9']+ { TmkStyle_p.Int (int_of_string (Lexing.lexeme lexbuf)) }
  | ('0' ['x' 'X']) ['0'-'9' 'a'-'f' 'A'-'F']+
      { TmkStyle_p.Int (int_of_string ((Lexing.lexeme lexbuf))) }
  | ('0' ['o' 'O']) ['0'-'7']+ { TmkStyle_p.Int (int_of_string ((Lexing.lexeme lexbuf))) }
  | '"' { TmkStyle_p.Str (string lexbuf) }
  | eof { TmkStyle_p.Eof }

and string = parse
    "\\\\" { Buffer.add_char strbuf '\\'; string lexbuf }
  | "\\\n" { string lexbuf }
  | "\\\"" { Buffer.add_char strbuf '"'; string lexbuf }
  | '\\' _ { Buffer.add_char strbuf '\\';
	     Buffer.add_char strbuf (Lexing.lexeme lexbuf).[1];
	     string lexbuf }
  | [^ '\\' '"']* { Buffer.add_string strbuf (Lexing.lexeme lexbuf);
		    string lexbuf }
  | '"' { let r = Buffer.contents strbuf in Buffer.clear strbuf; r }

{
}
