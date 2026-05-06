# mr_simple1: The "Oscillator"
# A pure signal-in, signal-out strategy.

params:
  n, risk_per_trade

indicators:
  sma = ta.sma(close, n)

sizing:
  qty = (run.initial_equity * risk_per_trade) / close

enter:
  close < sma

exits:
  signal_exit:
    close > sma