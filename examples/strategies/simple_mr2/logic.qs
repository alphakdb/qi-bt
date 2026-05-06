# simple_mr2

# mr_simple2: Mean reversion with confluence
# Separate rows in enter/exits are ANDed within each block

params:
  n, atr_n, risk_per_trade

indicators:
  sma = ta.sma(close, n)
  atr = ta.atr(high, low, close, atr_n)

  # Basic volatility filter
  vol_ok = atr > 0

sizing:
  qty = (run.initial_equity * risk_per_trade) / close

enter:
  close < sma
  vol_ok

exits:
# Reversion back to the mean
  signal_exit:
    close > sma