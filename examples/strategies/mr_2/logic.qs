# mr_2: Simple Mean Reversion (Short Only)
# Mirror of mr_1. Sells the rip when price spikes above its moving average.
# Demonstrates a pure short-side strategy.
#
# Complexity: 1/4 — one indicator, one entry condition, one exit

params:
  n, risk_per_trade

indicators:
  sma = ta.sma(close, n)

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

[short]
enter:
  close > sma

exits:
  signal_exit:
    close < sma
