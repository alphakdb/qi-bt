kind: panel

params:
  rsi_n, top_n

indicators:
  rsi_val       = ta.rsi(close, rsi_n)
  relative_rank = rank(rsi_val) / count(universe)

enter:
  relative_rank < 0.10

exits:
  laggard_exit:
    relative_rank > 0.30

execution:
  rebalance: weekly
  mode: weight_to_target
  target_weight: 1.0 / params.top_n
