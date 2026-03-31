open Curses

let () =
  (* NOTE: this setlocale() is needed for UTF-8 to work at all *)
  let _ = setlocale lC_ALL "" in
  let w = initscr () in
  assert (start_color ());
  assert (cbreak ());
  assert (noecho ());
  assert (keypad w true);
  assert (use_default_colors ());

  (* Color pairs *)
  assert (init_pair 1 Color.green Color.black);
  assert (init_pair 2 Color.red Color.black);
  assert (init_pair 3 Color.yellow Color.black);
  assert (init_pair 4 Color.cyan Color.black);
  assert (init_pair 5 Color.white Color.blue);
  assert (init_pair 6 Color.magenta Color.black);

  let rows, cols = getmaxyx w in

  (* Title bar *)
  attron (A.color_pair 5 lor A.bold);
  ignore (mvaddstr 0 0 (String.make cols ' '));
  ignore (mvaddstr 0 1
    "⚡ 株式取引所 — 🏦 Tokyo Stock Exchange Terminal v2.0");
  attroff (A.color_pair 5 lor A.bold);

  (* Market status *)
  attron (A.color_pair 1 lor A.bold);
  assert (mvaddstr 2 1
    "🟢 Market: OPEN (開場中)    🕐 09:42:17 JST    📈 日経平均: 39,847.52 (+1.23%)");
  attroff (A.color_pair 1 lor A.bold);

  (* Separator *)
  attron (A.color_pair 3);
  assert (mvaddstr 3 0 (String.make (min cols 120) '-'));
  attroff (A.color_pair 3);

  (* Column headers *)
  attron (A.color_pair 3 lor A.bold);
  assert (mvaddstr 4 1
    "Ticker       Name              Price       Change      Volume       Signal");
  attroff (A.color_pair 3 lor A.bold);

  (* Stock data: code, name, price, change, volume, signal, color_pair *)
  let stocks = [
    ("🎮 7974", "Nintendo",         "8,247",  "+3.42%", "1.2M", "🔥🚀💹 Surging", 1);
    ("🚗 7203", "Toyota Motor",     "2,891",  "+1.87%", "3.4M", "📈⬆️  Strong", 1);
    ("📱 6758", "Sony Group",       "13,450", "+0.52%", "890K", "↗️  Stable", 1);
    ("💰 8306", "Mitsubishi UFJ",   "1,234",  "-0.89%", "5.1M", "📉⬇️  Weak", 2);
    ("🍺 2502", "Asahi Group",      "5,678",  "-2.31%", "2.7M", "💥⚠️  Dropping", 2);
    ("💊 4502", "Takeda Pharma",    "4,123",  "+0.11%", "1.8M", "➡️  Flat", 4);
    ("🛤️ 9020",  "JR East",         "7,892",  "+0.73%", "670K", "🐂⬆️  Recovery", 1);
    ("🏗️ 6501",  "Hitachi",         "9,567",  "-1.45%", "1.5M", "🐻⚠️  Caution", 2);
    ("🔌 6702", "Fujitsu",          "19,230", "+4.17%", "4.2M", "🌋💎💰 Exploding", 1);
    ("🎵 4755", "Rakuten Group",    "765",    "-3.78%", "8.9M", "💀🆘📉 Crashing", 2);
  ] in

  List.iteri (fun i (code, name, price, change, vol, signal, color) ->
    let y = 5 + i in
    if y < rows - 6 then begin
      attron (A.color_pair 4);
      assert (mvaddstr y 1 code);
      attroff (A.color_pair 4);
      assert (mvaddstr y 12 name);
      attron (A.color_pair color lor A.bold);
      assert (mvaddstr y 30 price);
      assert (mvaddstr y 42 change);
      attroff (A.color_pair color lor A.bold);
      assert (mvaddstr y 54 vol);
      attron (A.color_pair color);
      assert (mvaddstr y 65 signal);
      attroff (A.color_pair color);
    end
  ) stocks;

  (* Separator *)
  let sep_y = 16 in
  attron (A.color_pair 3);
  assert (mvaddstr sep_y 0 (String.make (min cols 120) '-'));
  attroff (A.color_pair 3);

  (* News ticker *)
  attron (A.color_pair 6 lor A.bold);
  assert (mvaddstr (sep_y + 1) 1 "📢 Breaking News (ニュース速報):");
  attroff (A.color_pair 6 lor A.bold);

  attron (A.color_pair 4);
  assert (mvaddstr (sep_y + 2) 1
    "🔴 BOJ holds interest rates steady at policy meeting 💴💴💴");
  assert (mvaddstr (sep_y + 3) 1
    "🟡 FX: 1 USD = 149.82 JPY (prev day -0.43) 💱🇯🇵🇺🇸");
  assert (mvaddstr (sep_y + 4) 1
    "🟢 Capital flowing into 半導体 sector on AI demand 🤖💻📈✨🌟  [あ=OK]");
  attroff (A.color_pair 4);

  (* Portfolio summary *)
  let port_y = sep_y + 6 in
  attron (A.color_pair 3 lor A.bold);
  assert (mvaddstr port_y 1 "💼 Portfolio Summary");
  attroff (A.color_pair 3 lor A.bold);

  attron (A.color_pair 1 lor A.bold);
  assert (mvaddstr (port_y + 1) 1
    "💰 Total Value: ¥12,847,392  📈 Daily P&L: +¥234,567 (+1.86%) 🎉🎊💹");
  attroff (A.color_pair 1 lor A.bold);

  attron (A.color_pair 4);
  assert (mvaddstr (port_y + 2) 1
    "📊 Holdings: 10  🏆 Win Rate: 73.2%  ⚡ Fees: ¥42,891  🎯 Target: ¥15,000,000");
  attroff (A.color_pair 4);

  (* Alert bar *)
  if rows > port_y + 5 then begin
    attron (A.color_pair 2 lor A.bold lor A.blink);
    assert (mvaddstr (port_y + 4) 1
      "🚨🚨🚨 ALERT: Rakuten (4755) broke stop-loss ⚠️⚠️  Sell recommended 🆘🆘🆘");
    attroff (A.color_pair 2 lor A.bold lor A.blink);
  end;

  (* Status bar *)
  attron (A.color_pair 5);
  ignore (mvaddstr (rows - 1) 0 (String.make (cols - 1) ' '));
  ignore (mvaddstr (rows - 1) 1
    "🔑 q:Quit  🔄 r:Refresh  🔍 s:Search  📋 p:Portfolio  ⚡ Live updating...");
  attroff (A.color_pair 5);

  assert (refresh ());
  let _ = getch () in
  endwin ()
