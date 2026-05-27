# pairs_crypto_mr1: Z-Score Mean Reversion on Crypto Pairs (Both Sides)
# Trades the beta-adjusted spread between two correlated assets.
# Enter when spread stretches beyond entry_z standard deviations; exit on reversion.
#
# Complexity: 2/4 — beta-adjusted spread, z-score entry/exit, ATR stop, spread trailing stop

params:
  lookback, entry_z, exit_z, atr_n, atr_mult, trail_mult, risk_per_trade

indicators:
  beta   = ta.beta(leg1_close, leg2_close, lookback)
  spread = leg1_close - (beta * leg2_close)
  sma1   = lookback mavg spread
  dev1   = mdev(lookback, spread)
  zscore = (spread - sma1) / dev1
  atr    = ta.atr(leg1_high, leg1_low, leg1_close, atr_n)

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

[long]
enter:
  zscore < -entry_z

exits:
  stop_loss:
    price: entry_price - (atr * atr_mult)

  trailing_stop:
    spread: max_spread_since_entry - (dev1 * trail_mult)

  signal_exit:
    zscore >= -exit_z

[short] # hash: 0xabad6cf35ee3cce6638d9ad256549286
enter:
  zscore > entry_z

exits:
  stop_loss:
    price: entry_price + (atr * atr_mult)

  trailing_stop:
    spread: min_spread_since_entry + (dev1 * trail_mult)

  signal_exit:
    zscore <= exit_z
