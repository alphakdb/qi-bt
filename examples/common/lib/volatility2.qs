# Reusable volatility regime indicators.
# Include this in any strategy that needs a vol filter.
#
# Provides:
#   atr14          - raw ATR(14)
#   vol_regime_high - true when current vol is elevated vs its 50-bar average
#   vol_regime_low  - true when vol is suppressed (e.g. avoid mean-reversion entries)

indicators:
  atr15           = ta.atr(high, low, close, 15)
  vol_regime_high = atr15 > ta.sma(atr15, 100)
