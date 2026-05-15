# mr_3: Mean Reversion, Both Sides, with Volatility Filter and Stops
# Extends mr_1/mr_2 with both-sided entries, a volatility filter
# (only trade when vol is above its own average), and an ATR-based stop loss.
#
# Complexity: 2/4 — two indicators, two entry conditions, stop + signal exit

params:
  n, atr_n, atr_mult, risk_per_trade

indicators:
  sma    = ta.sma(close, n)
  atr    = ta.atr(high, low, close, atr_n)
  vol_ok = atr > ta.sma(atr, n)

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

[long]
enter:
  close < sma
  vol_ok

exits:
  stop_loss:
    price: entry_price - (atr * atr_mult)

  signal_exit:
    close > sma

[short] # hash: 0x67690d5f89b131808388b6d4fd8f1ff1
enter:
  close > sma
  vol_ok

exits:
  stop_loss:
    price: entry_price + (atr * atr_mult)

  signal_exit:
    close < sma
