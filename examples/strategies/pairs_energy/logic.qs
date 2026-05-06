kind: spread

include:
  volatility

params:
  lookback, entry_z, exit_z, max_loss_r

state:
  beta          = ta.beta(leg1.close, leg2.close, lookback)
  actual_spread = leg1.close - (beta * leg2.close)

indicators:
  m      = ta.sma(actual_spread, lookback)
  s      = ta.stddev(actual_spread, lookback, 1)
  zscore = (actual_spread - m) / s

enter:
  zscore < -entry_z
  vol_regime_low

exits:
  target:
    zscore >= -exit_z

  pnl_stop:
    upnl_r <= -max_loss_r

execution:
  type: multi_leg
  weights: [1, -beta]
