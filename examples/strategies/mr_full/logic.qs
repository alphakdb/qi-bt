# mr_full: Mean reversion with RSI filter, fixed SL/TP, signal exit, time stop
# Based on simple_mr1b: SMA entry + RSI gate + fixed % stop_loss + fixed % take_profit

params:
  n, rsi_n, rsi_thresh, threshold, sl_stop, tp_stop, risk_per_trade, hold_bars

indicators:
  sma = ta.sma(close, n)
  rsi = ta.rsi(close, rsi_n)

sizing:
  # entry_price is the actual fill price (next open + slippage), not signal-bar close;
  # this matches VBT size_type="value" and avoids overshoot on volatile opens
  qty = (run.initial_equity * risk_per_trade) / entry_price

enter:
  close < sma * (1 - threshold)
  rsi < rsi_thresh

exits:
  stop_loss:
    price: entry_price * (1 - sl_stop)

  take_profit:
    price: entry_price * (1 + tp_stop)

  signal_exit:
    close > sma
