# ewa_ewc_pairs: International Commodity Currency Pairs (Ernest Chan)
# EWA (Australia) and EWC (Canada) are both commodity-driven economies with high
# historical cointegration. Classic example from Chan's "Algorithmic Trading" Ch.2.
# Enter when beta-adjusted spread deviates beyond entry_z std devs; exit on reversion.
#
# Complexity: 2/4 — beta-adjusted spread, z-score entry/exit, ATR stop loss

params:
  lookback, entry_z, exit_z, atr_n, atr_mult, trail_mult, risk_per_trade

indicators:
  beta   = ta.beta(leg1_close, leg2_close, lookback)
  spread = leg1_close - (beta * leg2_close)
  m      = ta.sma(spread, lookback)
  s      = ta.stddev(spread, lookback, 1)
  zscore = (spread - m) / s
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
    spread: max_spread_since_entry - (s * trail_mult)

  signal_exit:
    zscore >= -exit_z

[short] # hash: 0x996645545a4c4da9200f82df407e6730
enter:
  zscore > entry_z

exits:
  stop_loss:
    price: entry_price + (atr * atr_mult)

  trailing_stop:
    spread: min_spread_since_entry + (s * trail_mult)

  signal_exit:
    zscore <= exit_z
