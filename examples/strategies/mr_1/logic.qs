# mr_1: Simple Mean Reversion (Long Only)
# The simplest possible mean-reversion strategy.
# Enter long when price dips below its moving average; exit when it reverts.
#
# Complexity: 1/4 — one indicator, one entry condition, one exit

params:
  n, risk_per_trade

indicators:
  sma = ta.sma(close, n)

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

enter:
  close < sma

exits:
  signal_exit:
    close > sma
