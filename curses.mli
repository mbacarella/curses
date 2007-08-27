(**
  * Bindings to the ncurses library.
  *
  * Functions whose name start with a "w" take as first argument the window the
  * function applies to.
  * Functions whose name start with "mv" take as first two arguments the
  * coordinates [y] and [x] of the point to move the cursor to. For example
  * [mvaddch y x ch] is the same as [move y x; addch ch].
  *)

type window
type screen
type terminal
type chtype = int
type attr_t = int
(** A return value. [false] means that an error occured. *)
type err = bool

module Acs :
sig
  type acs =
  {
    ulcorner : chtype;
    llcorner : chtype;
    urcorner : chtype;
    lrcorner : chtype;
    ltee : chtype;
    rtee : chtype;
    btee : chtype;
    ttee : chtype;
    hline : chtype;
    vline : chtype;
    plus : chtype;
    s1 : chtype;
    s9 : chtype;
    diamond : chtype;
    ckboard : chtype;
    degree : chtype;
    plminus : chtype;
    bullet : chtype;
    larrow : chtype;
    rarrow : chtype;
    darrow : chtype;
    uarrow : chtype;
    board : chtype;
    lantern : chtype;
    block : chtype;
    s3 : chtype;
    s7 : chtype;
    lequal : chtype;
    gequal : chtype;
    pi : chtype;
    nequal : chtype;
    sterling : chtype;
  }
  val bssb : acs -> chtype
  val ssbb : acs -> chtype
  val bbss : acs -> chtype
  val sbbs : acs -> chtype
  val sbss : acs -> chtype
  val sssb : acs -> chtype
  val ssbs : acs -> chtype
  val bsss : acs -> chtype
  val bsbs : acs -> chtype
  val sbsb : acs -> chtype
  val ssss : acs -> chtype
end


(** {2 Initialization functions} *)

(** Initialize the curses library. *)
val initscr : unit -> window

(** Restore the terminal (should be called before exiting). *)
val endwin : unit -> unit

(** Has [endwin] been called without any subsequent call to [werefresh]? *)
val isendwin : unit -> bool

(** Create a new terminal. *)
val newterm : string -> Unix.file_descr -> Unix.file_descr -> screen

(** Switch terminal. *)
val set_term : screen -> unit

(** Delete a screen. *)
val delscreen : screen -> unit
val stdscr : unit -> window


(** {2 Cursor} *)
(** Get the current cursor position. *)
val getyx : window -> int * int
val getparyx : window -> int * int
val getbegyx : window -> int * int
val getmaxyx : window -> int * int

(** Move the cursor. *)
val move : int -> int -> err
val wmove : window -> int -> int -> err


(** {2 Operations on characters} *)

(** {3 Displaying characters} *)
(** Add a character at the current position, then advance the cursor. *)
val addch : chtype -> err
val waddch : window -> chtype -> err
val mvaddch : int -> int -> chtype -> err
val mvwaddch : window -> int -> int -> chtype -> err

(** [echochar ch] is equivalent to [addch ch] followed by [refresh ()]. *)
val echochar : chtype -> err
val wechochar : window -> chtype -> err

(** Add a sequence of characters at the current position. See also [addstr]. *)
val addchstr : chtype array -> err
val waddchstr : window -> chtype array -> err
val mvaddchstr : int -> int -> chtype array -> err
val mvwaddchstr : window -> int -> int -> chtype array -> err
val addchnstr : chtype array -> int -> int -> err
val waddchnstr : window -> chtype array -> int -> int -> err
val mvaddchnstr : int -> int -> chtype array -> int -> int -> err
val mvwaddchnstr : window -> int -> int -> chtype array -> int -> int -> err

(** Add a string at the current position. *)
val addstr : string -> err
val waddstr : window -> string -> err
val mvaddstr : int -> int -> string -> err
val mvwaddstr : window -> int -> int -> string -> err
val addnstr : string -> int -> int -> err
val waddnstr : window -> string -> int -> int -> err
val mvaddnstr : int -> int -> string -> int -> int -> err
val mvwaddnstr : window -> int -> int -> string -> int -> int -> err

(** Insert a character before cursor. *)
val insch : chtype -> err
val winsch : window -> chtype -> err
val mvinsch : int -> int -> chtype -> err
val mvwinsch : window -> int -> int -> chtype -> err

(** Insert a string before cursor. *)
val insstr : string -> err
val winsstr : window -> string -> err
val mvinsstr : int -> int -> string -> err
val mvwinsstr : window -> int -> int -> string -> err
val insnstr : string -> int -> int -> err
val winsnstr : window -> string -> int -> int -> err
val mvinsnstr : int -> int -> string -> int -> int -> err
val mvwinsnstr : window -> int -> int -> string -> int -> int -> err

(** Delete a character. *)
val delch : unit -> err
val wdelch : window -> err
val mvdelch : int -> int -> err
val mvwdelch : window -> int -> int -> err


(** {3 Attributes} *)
(** Attributes. *)
module A :
sig
  val normal : int
  val attributes : int
  val chartext : int
  val color : int
  val standout : int
  val underline : int
  val reverse : int
  val blink : int
  val dim : int
  val bold : int
  val altcharset : int
  val invis : int
  val protect : int
  val horizontal : int
  val left : int
  val low : int
  val right : int
  val top : int
  val vertical : int
  val combine : int list -> int
  val color_pair : int -> int
  val pair_number : int -> int
end

(** New series of highlight attributes. *)
module WA :
sig
  (** Normal display (no highlight). *)
  val normal : int
  val attributes : int
  val chartext : int
  val color : int

  (** Best highlighting mode of the terminal. *)
  val standout : int

  (** Underlining. *)
  val underline : int

  (** Reverse video. *)
  val reverse : int

  (** Blinking. *)
  val blink : int

  (** Half bright. *)
  val dim : int

  (** Extra bright or bold. *)
  val bold : int

  (** Alternate character set. *)
  val altcharset : int
  val invis : int
  val protect : int
  val horizontal : int
  val left : int
  val low : int
  val right : int
  val top : int
  val vertical : int
  val combine : int list -> int
  val color_pair : int -> int
  val pair_number : int -> int
end

(** Turn off the attributes given in argument (see the [A] module). *)
val attroff : int -> unit
val wattroff : window -> int -> unit

(** Turn on the attributes given in argument. *)
val attron : int -> unit
val wattron : window -> int -> unit

(** Set the attributes. *)
val attrset : int -> unit
val wattrset : window -> int -> unit

val standend : unit -> unit
val wstandend : window -> unit
val standout : unit -> unit
val wstandout : window -> unit

(** Turn off the attributes given in argument (see the [WA] module). *)
val attr_off : attr_t -> unit
val wattr_off : window -> attr_t -> unit
val attr_on : attr_t -> unit
val wattr_on : window -> attr_t -> unit
val attr_set : attr_t -> int -> unit
val wattr_set : window -> attr_t -> int -> unit

(** [chgat n attr color] changes the attributes of [n] characters. *)
val chgat : int -> attr_t -> int -> unit
val wchgat : window -> int -> attr_t -> int -> unit
val mvchgat : int -> int -> int -> attr_t -> int -> unit
val mvwchgat : window -> int -> int -> int -> attr_t -> int -> unit

(** Get the attributes of the caracter at current position. *)
val inch : unit -> chtype
val winch : window -> chtype
val mvinch : int -> int -> chtype
val mvwinch : window -> int -> int -> chtype

val inchstr : chtype array -> err
val winchstr : window -> chtype array -> err
val mvinchstr : int -> int -> chtype array -> err
val mvwinchstr : window -> int -> int -> chtype array -> err
val inchnstr : chtype array -> int -> int -> err
val winchnstr : window -> chtype array -> int -> int -> err
val mvinchnstr : int -> int -> chtype array -> int -> int -> err
val mvwinchnstr : window -> int -> int -> chtype array -> int -> int -> err

val instr : string -> err
val winstr : window -> string -> err
val mvinstr : int -> int -> string -> err
val mvwinstr : window -> int -> int -> string -> err
val innstr : string -> int -> int -> err
val winnstr : window -> string -> int -> int -> err
val mvinnstr : int -> int -> string -> int -> int -> err
val mvwinnstr : window -> int -> int -> string -> int -> int -> err

(** {3 Background} *)

(** Set the background of the current character. *)
val bkgdset : chtype -> unit
val wbkgdset : window -> chtype -> unit

(** Set the background of every character. *)
val bkgd : chtype -> unit
val wbkgd : window -> chtype -> unit

(** Get the current background. *)
val getbkgd : window -> chtype


(** {3 Operations on lines} *)

(** Delete a line. *)
val deleteln : unit -> err
val wdeleteln : window -> err

(** [insdelln n] inserts [n] lines above the current line if [n] is positive or
  * deletes [-n] lines if [n] is negative. *)
val insdelln : int -> err
val winsdelln : window -> int -> err

(** Insert a blank line above the current line. *)
val insertln : unit -> err
val winsertln : window -> err

(** {3 Characters input} *)
(** Read a character in a window. *)
val getch : unit -> int
val wgetch : window -> int
val mvgetch : int -> int -> int
val mvwgetch : window -> int -> int -> int
val ungetch : int -> err

(** Read a string in a window. *)
val getstr : string -> err
val wgetstr : window -> string -> err
val mvgetstr : int -> int -> string -> err
val mvwgetstr : window -> int -> int -> string -> err
val getnstr : string -> int -> int -> err
val wgetnstr : window -> string -> int -> int -> err
val mvgetnstr : int -> int -> string -> int -> int -> err
val mvwgetnstr : window -> int -> int -> string -> int -> int -> err


(** {2 Windows} *)
(** {3 Window manipulations} *)
(** [newwin l c y x] create a new window with [l] lines, [c] columns. The upper
  * left-hand corner is at ([x],[y]). *)
val newwin : int -> int -> int -> int -> window
val delwin : window -> err
val mvwin : window -> int -> int -> err
val subwin : window -> int -> int -> int -> int -> window
val derwin : window -> int -> int -> int -> int -> window
val mvderwin : window -> int -> int -> err
val dupwin : window -> window
val wsyncup : window -> unit
val syncok : window -> bool -> err
val wcursyncup : window -> unit
val wsyncdown : window -> unit
val get_acs_codes : unit -> Acs.acs
val winch_handler_on : unit -> unit
val winch_handler_off : unit -> unit
val get_size : unit -> int * int
val get_size_fd : Unix.file_descr -> int * int
val null_window : window

(** {3 Refresh control} *)
(** Refresh windows. *)
val refresh : unit -> err
val wrefresh : window -> err
val wnoutrefresh : window -> err
val doupdate : unit -> err
val redrawwin : window -> err
val wredrawln : window -> int -> int -> err
val wresize : window -> int -> int -> err
val resizeterm : int -> int -> err
val scroll : window -> err
val scrl : int -> err
val wscrl : window -> int -> err
val touchwin : window -> err
val touchline : window -> int -> int -> err
val untouchwin : window -> err
val wtouchln : window -> int -> int -> bool -> err
val is_linetouched : window -> int -> int
val is_wintouched : window -> bool

(** Clear a window. *)
val erase : unit -> unit
val werase : window -> unit
val clear : unit -> unit
val wclear : window -> unit
val clrtobot : unit -> unit
val wclrtobot : window -> unit
val clrtoeol : unit -> unit
val wclrtoeol : window -> unit

(** {3 Overlapped windows} *)
val overlay : window -> window -> err
val overwrite : window -> window -> err
val copywin : window -> window -> int -> int -> int -> int -> int -> int -> bool -> err

(** {3 Decorations} *)

(** Draw a box around the edges of a window. *)
val border : chtype -> chtype -> chtype -> chtype -> chtype -> chtype -> chtype -> chtype -> unit
val wborder : window -> chtype -> chtype -> chtype -> chtype -> chtype -> chtype -> chtype -> chtype -> unit

(** Draw a box. *)
val box : window -> chtype -> chtype -> unit

(** Draw an horizontal line. *)
val hline : chtype -> int -> unit
val whline : window -> chtype -> int -> unit
val mvhline : int -> int -> chtype -> int -> unit
val mvwhline : window -> int -> int -> chtype -> int -> unit

(** Draw a vertical line. *)
val vline : chtype -> int -> unit
val wvline : window -> chtype -> int -> unit
val mvvline : int -> int -> chtype -> int -> unit
val mvwvline : window -> int -> int -> chtype -> int -> unit


(** {2 Pads} *)
(** A pad is like a window except that it is not restricted by the screen size,
  * and is not necessarily associated with a particular part of the screen.*)

(** Create a new pad. *)
val newpad : int -> int -> window
val subpad : window -> int -> int -> int -> int -> window
val prefresh : window -> int -> int -> int -> int -> int -> int -> err
val pnoutrefresh : window -> int -> int -> int -> int -> int -> int -> err
val pechochar : window -> chtype -> err

(** {2 Colors} *)

(** Colors. *)
module Color :
sig
  val black : int
  val red : int
  val green : int
  val yellow : int
  val blue : int
  val magenta : int
  val cyan : int
  val white : int
end

val start_color : unit -> err
val use_default_colors : unit -> err
val init_pair : int -> int -> int -> err
val init_color : int -> int -> int -> int -> err
val has_colors : unit -> bool
val can_change_color : unit -> bool
val color_content : int -> int * int * int
val pair_content : int -> int * int
val colors : unit -> int
val color_pairs : unit -> int


(** {2 Input/output options} *)

(** {3 Input options} *)
(** Disable line buffering. *)
val cbreak : unit -> err

(** Similar to [cbreak] but with delay. *)
val halfdelay : int -> err

(** Enable line buffering (waits for characters until newline is typed). *)
val nocbreak : unit -> err

(** Don't echo typed characters. *)
val echo : unit -> err

(** Echo typed characters. *)
val noecho : unit -> err
val intrflush : window -> bool -> err
val keypad : window -> bool -> err
val meta : window -> bool -> err
val nodelay : window -> bool -> err
val raw : unit -> err
val noraw : unit -> err
val noqiflush : unit -> unit
val qiflush : unit -> unit
val notimeout : window -> bool -> err
val timeout : int -> unit
val wtimeout : window -> int -> unit
val typeahead : Unix.file_descr -> err
val notypeahead : unit -> err

(** {3 Output options} *)
val clearok : window -> bool -> unit
val idlok : window -> bool -> unit
val idcok : window -> bool -> unit
val immedok : window -> bool -> unit
val leaveok : window -> bool -> unit
val setscrreg : int -> int -> err
val wsetscrreg : window -> int -> int -> err
val scrollok : window -> bool -> unit
val nl : unit -> unit
val nonl : unit -> unit

(** {2 Low-level curses routines} *)
val def_prog_mode : unit -> unit
val def_shell_mode : unit -> unit
val reset_prog_mode : unit -> unit
val reset_shell_mode : unit -> unit
val resetty : unit -> unit
val savetty : unit -> unit
val getsyx : unit -> int * int
val setsyx : int -> int -> unit
val curs_set : int -> err
val napms : int -> unit
val ripoffline : bool -> unit
val get_ripoff : unit -> window * int

(** {2 Mouse} *)
val mousemask : int -> int * int


(** {2 Misc} *)

(** Ring a bell. *)
val beep : unit -> err

(** Flash the screen. *)
val flash : unit -> err

val unctrl : chtype -> string
val keyname : int -> string
val filter : unit -> unit
val use_env : bool -> unit
val putwin : window -> Unix.file_descr -> err
val getwin : Unix.file_descr -> window
val delay_output : int -> err
val flushinp : unit -> unit


(** {2 Soft-label keys} *)

(** Initialize soft labels. *)
val slk_init : int -> err
val slk_set : int -> string -> int -> err
val slk_refresh : unit -> err
val slk_noutrefresh : unit -> err
val slk_label : int -> string
val slk_clear : unit -> err
val slk_restore : unit -> err
val slk_touch : unit -> err
val slk_attron : attr_t -> err
val slk_attroff : attr_t -> err
val slk_attrset : attr_t -> err


val baudrate : unit -> int
val erasechar : unit -> char
val has_ic : unit -> bool
val has_il : unit -> bool
val killchar : unit -> char
val longname : unit -> string

(** {2 Screen manipulation} *)
(** Dump the current screen to a file. *)
val scr_dump : string -> err
val scr_restore : string -> err
val scr_init : string -> err
val scr_set : string -> err

(** {2 Terminal} *)
val termattrs : unit -> attr_t
val termname : unit -> string
val tgetent : string -> bool
val tgetflag : string -> bool
val tgetnum : string -> int
val tgetstr : string -> bool
val tgoto : string -> int -> int -> string
val setupterm : string -> Unix.file_descr -> err
val setterm : string -> err
val cur_term : unit -> terminal
val set_curterm : terminal -> terminal
val del_curterm : terminal -> err
val restartterm : string -> Unix.file_descr -> err
val putp : string -> err
val vidattr : chtype -> err
val mvcur : int -> int -> int -> int -> err
val tigetflag : string -> bool
val tigetnum : string -> int
val tigetstr : string -> string
val tputs : string -> int -> (char -> unit) -> err
val vidputs : chtype -> (char -> unit) -> err
val tparm : string -> int array -> string
val bool_terminfo_variable : int -> string * string * string
val num_terminfo_variable : int -> string * string * string
val str_terminfo_variable : int -> string * string * string
val bool_terminfo_variables : (string, string * string) Hashtbl.t
val num_terminfo_variables : (string, string * string) Hashtbl.t
val str_terminfo_variables : (string, string * string) Hashtbl.t


(** Keys. *)
module Key :
sig
  val code_yes : int
  val min : int
  val break : int
  val down : int
  val up : int
  val left : int
  val right : int
  val home : int
  val backspace : int
  val f0 : int
  val dl : int
  val il : int
  val dc : int
  val ic : int
  val eic : int
  val clear : int
  val eos : int
  val eol : int
  val sf : int
  val sr : int
  val npage : int
  val ppage : int
  val stab : int
  val ctab : int
  val catab : int
  val enter : int
  val sreset : int
  val reset : int
  val print : int
  val ll : int
  val a1 : int
  val a3 : int
  val b2 : int
  val c1 : int
  val c3 : int
  val btab : int
  val beg : int
  val cancel : int
  val close : int
  val command : int
  val copy : int
  val create : int
  val end_ : int
  val exit : int
  val find : int
  val help : int
  val mark : int
  val message : int
  val move : int
  val next : int
  val open_ : int
  val options : int
  val previous : int
  val redo : int
  val reference : int
  val refresh : int
  val replace : int
  val restart : int
  val resume : int
  val save : int
  val sbeg : int
  val scancel : int
  val scommand : int
  val scopy : int
  val screate : int
  val sdc : int
  val sdl : int
  val select : int
  val send : int
  val seol : int
  val sexit : int
  val sfind : int
  val shelp : int
  val shome : int
  val sic : int
  val sleft : int
  val smessage : int
  val smove : int
  val snext : int
  val soptions : int
  val sprevious : int
  val sprint : int
  val sredo : int
  val sreplace : int
  val sright : int
  val srsume : int
  val ssave : int
  val ssuspend : int
  val sundo : int
  val suspend : int
  val undo : int
  val mouse : int
  val resize : int
  val max : int
  val f : int -> int
end
