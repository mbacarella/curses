%{
  open TmkStyle
%}

%token Equal Nequal Tilde
%token LBracket RBracket
%token LBrace RBrace
%token LParen RParen
%token Comma
%token <string> Ident
%token <string> Env
%token <string> Str
%token <int> Int
%token And Or Not
%token Eof

%left Or
%left And
%nonassoc Not

%start parse
%type <TmkStyle.S.configuration> parse

%%

parse:
  specification_list Eof { List.rev $1 }
;

specification_list:
  /* empty */ { [] }
| specification_list specification { $2::$1 }
;

specification:
  Ident subscript Equal rvalue { S.Def ($1, $2, $4) }
| LParen condition RParen LBrace specification_list RBrace { S.Sub ($2, $5) }
;

subscript:
  /* empty */ { None }
| LBracket subscript_list RBracket { Some (List.rev $2) }
;

subscript_list:
  Ident { [$1] }
| subscript_list Comma Ident { $3::$1 }
;

rvalue:
  Int { S.Int $1 }
| Str { S.Str $1 }
;

condition:
  condition And condition { S.And ($1, $3) }
| condition Or condition { S.Or ($1, $3) }
| Not condition { S.Not $2 }
| LParen condition RParen { $2 }
| term { S.Term $1 }
;

term:
  Ident { S.Var $1 }
| Str { S.Pat (P.compile $1) }
| Ident Equal Str { S.Eq ($1, $3) }
| Env Equal Str { S.Eq ($1, $3) }
| Ident Nequal Str { S.Neq ($1, $3) }
| Env Nequal Str { S.Neq ($1, $3) }
| Ident Tilde Str { S.Match ($1, P.compile $3) }
| Env Tilde Str { S.Match ($1, P.compile $3) }
;

%%
