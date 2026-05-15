# mr_4: Bollinger Band Mean Reversion with RSI Filter (Both Sides)
# Enters on Bollinger Band extremes, filtered by RSI to avoid catching falling knives.
# Full exit suite: fixed stop loss, mean-reversion take profit, and signal exit.
#
# Complexity: 3/4 — three indicators, two entry conditions per side, three exit types

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

  take_profit:
    price: bb_mid

  signal_exit:
    close > bb_upper

[short] # hash: 0x4fb85faaf19e8548550046957133dfbf
enter:
  close > bb_upper
  rsi > rsi_thresh

exits:
  stop_loss:
    price: entry_price * (1 + sl_pct)

  take_profit:
    price: bb_mid

  signal_exit:
    close < bb_lower
