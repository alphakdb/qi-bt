# mr_4: Bollinger Band Mean Reversion with RSI Filter (Both Sides)
# Enters on Bollinger Band extremes, filtered by RSI to avoid catching falling knives.
# Exits on full band-to-band reversion (signal exit) or stop loss.
#
# Complexity: 3/4 — three indicators, two entry conditions per side, stop + signal exit

params:
  bb_n, bb_sd, rsi_n, rsi_thresh, rsi_thresh_short, atr_n, sl_pct, risk_per_trade

indicators:
  bb  = ta.bbands(close, bb_n, bb_sd, bb_sd, 0)
  rsi = ta.rsi(close, rsi_n)
  atr = ta.atr(high, low, close, atr_n)

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

[long]
enter:
  close < bb_lower
  rsi < rsi_thresh

exits:
  stop_loss:
    price: entry_price * (1 - sl_pct)

  signal_exit:
    close > bb_upper

[short] # hash: 0x0ff9857f526e2e4e64d2e791bc517203
enter:
  close > bb_upper
  rsi > rsi_thresh_short

exits:
  stop_loss:
    price: entry_price * (1 + sl_pct)

  signal_exit:
    close < bb_lower
