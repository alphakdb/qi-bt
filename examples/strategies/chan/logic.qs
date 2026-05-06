# Z-Score Mean Reversion
# Based on Ernest Chan "Algorithmic Trading: Winning Strategies and Their Rationale"
# Enter long when price is statistically cheap vs its rolling mean (z < -entry_z)
# Exit when price reverts toward mean (z > -exit_z)

include:
  volatility

params:
  lookback, entry_z, exit_z, atr_mult, max_hold_bars

indicators:
  ma        = ta.sma(close, lookback)
  sd        = ta.stddev(close, lookback, 1.0)
  zscore    = (close - ma) / sd

enter:
  (zscore + entry_z) < 0
  vol_regime_low

exits:
  signal_exit:
    (zscore + exit_z) > 0

  stop_loss:
    price: entry_price - (atr14 * atr_mult)

  time_stop:
    bars_since_entry > max_hold_bars

execution:
  rebalance: daily
  mode: weight_to_target
  target_weight: 1.0
