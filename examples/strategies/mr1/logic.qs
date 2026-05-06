include:
  volatility

params:
  bb_n, bb_sd, atr_n, atr_mult

indicators:
  bb  = ta.bbands(close, bb_n, bb_sd, bb_sd, 0)
  vol = ta.atr(high, low, close, atr_n)

enter:
  close < bb_lower
  vol_high
  
exits:
  # --- PRICE TARGET EXITS (Evaluated against High/Low) ---
  
  # Volatility-based Trailing Stop: Ratchets up, never down
  trailing_stop:
    price: max_high_since_entry - (vol * atr_mult)

  # Profit Target: Exit when price touches the mean
  take_profit:
    price: bb_mid

  # --- SIGNAL EXITS (Evaluated at the Close) ---

  # Momentum Exit: Close is stretched too far
  signal_exit:
    close > bb_upper

  # Time/Performance Decay: Exit if trade stagnates
  #stale_exit:
   # bars_since_entry > 30
   # upnl_r <= 0.5