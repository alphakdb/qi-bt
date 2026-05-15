# momentum_1: Trend-Filtered RSI Momentum (Long Only)
# Enter when price is in an uptrend (above long-term SMA) and RSI has pulled back
# to an entry threshold. Ride the momentum until RSI becomes overbought or the stop is hit.
#
# Complexity: 2/4 — three indicators, two entry conditions, stop + signal exit

params:
  sma_n, rsi_n, rsi_entry, rsi_exit, atr_n, atr_mult, risk_per_trade

indicators:
  sma      = ta.sma(close, sma_n)
  rsi      = ta.rsi(close, rsi_n)
  atr      = ta.atr(high, low, close, atr_n)
  trend_up = close > sma

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

enter:
  trend_up
  rsi < rsi_entry

exits:
  stop_loss:
    price: entry_price - (atr * atr_mult)

  signal_exit:
    rsi > rsi_exit
