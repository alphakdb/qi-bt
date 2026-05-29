# index_mr: Index Mean Reversion on VIX Spikes (Ernest Chan)
# Buy the S&P500 when it becomes deeply oversold — approximating Chan's VIX-spike
# strategy. When fear spikes, SPY drops to Bollinger Band extremes with an oversold RSI.
# The strategy bets on reversion to the mean once panic subsides.
#
# Complexity: 3/4 — Bollinger Bands + RSI filter, ATR stop, BB-mid take profit

params:
  bb_n, bb_sd, rsi_n, rsi_thresh, atr_n, atr_mult, risk_per_trade

indicators:
  bb  = ta.bbands(close, bb_n, bb_sd, bb_sd, 0)
  rsi = ta.rsi(close, rsi_n)
  atr = ta.atr(high, low, close, atr_n)

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

enter:
  close < bb_lower
  rsi < rsi_thresh

exits:
  stop_loss:
    price: entry_price * (1 - atr_mult * atr / entry_price)

  take_profit:
    price: bb_mid

  signal_exit:
    close > bb_upper
