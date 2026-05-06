# Opening Gap Mean Reversion (Long Only, Intraday)
# Based on Ernest Chan "Algorithmic Trading" Chapter 6
# Stocks that gap down at the open tend to revert intraday
# Enter long at open when gap is statistically extreme, exit intraday

include:
  volatility

params:
  lookback, entry_z, exit_z, atr_mult, gap_threshold, bb_n

indicators:
  prev_close = prev close
  gap       = (open - prev_close) / prev_close
  ma_gap    = ta.sma(gap, lookback)
  sd_gap    = ta.stddev(gap, lookback, 1.0)
  zscore    = (gap - ma_gap) / sd_gap
  vwap_ind  = ta.wclprice(high, low, close)

enter:
  I = 0
  (zscore + entry_z) < 0
  (gap + gap_threshold) < 0
  vol_regime_low

exits:
  signal_exit:
    close > vwap_ind

  stop_loss:
    price: entry_price - (atr14 * atr_mult)

  time_stop:
    bars_since_entry > max_hold_bars
