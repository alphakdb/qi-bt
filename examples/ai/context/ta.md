# Technical Analysis Functions (ta.*)

All functions are called as `ta.func(args)` in the DSL.
The `ta.*` namespace wraps TA-Lib via qi-ta.

Functions returning a single series: return a float vector aligned to input.
Functions returning multiple outputs (bbands, macd, stoch etc): return a table —
access columns via promotion (see dsl.md) or dot notation.

---

## Overlap / Trend

| Function | Args | Description |
|---|---|---|
| `sma` | series, n | Simple moving average |
| `ema` | series, n | Exponential moving average |
| `dema` | series, n | Double EMA |
| `tema` | series, n | Triple EMA |
| `wma` | series, n | Weighted moving average |
| `trima` | series, n | Triangular moving average |
| `kama` | series, n | Kaufman adaptive MA |
| `t3` | series, n, vfactor | Triple exponential MA (T3) |
| `ma` | series, n, type | Generic MA (type selectable) |
| `midpoint` | series, n | Midpoint over period |
| `midprice` | high, low, n | Midpoint price over period |
| `sar` | high, low, accel, max | Parabolic SAR |
| `mama` | series, fast, slow | MESA adaptive MA |
| `ht_trendline` | series | Hilbert transform trendline |
| `bbands` | close, n, sd_up, sd_dn, type | Bollinger Bands → `upper` `mid` `lower` |

## Momentum

| Function | Args | Description |
|---|---|---|
| `rsi` | series, n | Relative Strength Index (0–100) |
| `mom` | series, n | Momentum |
| `roc` | series, n | Rate of change |
| `cmo` | series, n | Chande Momentum Oscillator |
| `trix` | series, n | 1-day ROC of triple-smoothed EMA |
| `apo` | series, fast, slow, type | Absolute Price Oscillator |
| `ppo` | series, fast, slow, type | Percentage Price Oscillator |
| `macd` | series, fast, slow, signal | MACD → `macd` `signal` `hist` |
| `macdfix` | series, signal | MACD fixed 12/26 → `macd` `signal` `hist` |
| `adx` | high, low, close, n | Average Directional Index |
| `adxr` | high, low, close, n | ADX Rating |
| `dx` | high, low, close, n | Directional Movement Index |
| `aroon` | high, low, n | Aroon → `aroon_down` `aroon_up` |
| `aroonosc` | high, low, n | Aroon Oscillator |
| `cci` | high, low, close, n | Commodity Channel Index |
| `willr` | high, low, close, n | Williams %R |
| `minus_di` | high, low, close, n | Minus Directional Indicator |
| `plus_di` | high, low, close, n | Plus Directional Indicator |
| `minus_dm` | high, low, n | Minus Directional Movement |
| `plus_dm` | high, low, n | Plus Directional Movement |
| `stoch` | high, low, close, fk, sk, sk_type, sd, sd_type | Stochastic → `slowk` `slowd` |
| `stochf` | high, low, close, fk, fd, fd_type | Stochastic Fast → `fastk` `fastd` |
| `stochrsi` | series, n, fk, fd, fd_type | Stochastic RSI → `fastk` `fastd` |
| `ultosc` | high, low, close, p1, p2, p3 | Ultimate Oscillator |
| `mfi` | high, low, close, volume, n | Money Flow Index |
| `bop` | open, high, low, close | Balance of Power |

## Volatility

| Function | Args | Description |
|---|---|---|
| `atr` | high, low, close, n | Average True Range |
| `natr` | high, low, close, n | Normalised ATR (% of close) |
| `trange` | high, low, close | True Range |

## Statistics

| Function | Args | Description |
|---|---|---|
| `stddev` | series, n, ddof | Standard deviation (ddof=1 sample, 0 population) |
| `var` | series, n, ddof | Variance |
| `beta` | series_y, series_x, n | Rolling beta |
| `correl` | series_y, series_x, n | Pearson correlation |
| `linearreg` | series, n | Linear regression value |
| `linearreg_slope` | series, n | Linear regression slope |
| `linearreg_intercept` | series, n | Linear regression intercept |
| `linearreg_angle` | series, n | Linear regression angle |
| `tsf` | series, n | Time Series Forecast |

## Volume

| Function | Args | Description |
|---|---|---|
| `obv` | close, volume | On Balance Volume |
| `ad` | high, low, close, volume | Chaikin A/D Line |
| `adosc` | high, low, close, volume, fast, slow | Chaikin A/D Oscillator |

## Price Transform

| Function | Args | Description |
|---|---|---|
| `avgprice` | open, high, low, close | Average price (OHLC mean) |
| `medprice` | high, low | Median price |
| `typprice` | high, low, close | Typical price |
| `wclprice` | high, low, close | Weighted close price |

## Cycle

| Function | Args | Description |
|---|---|---|
| `ht_dcperiod` | series | Hilbert — dominant cycle period |
| `ht_dcphase` | series | Hilbert — dominant cycle phase |
| `ht_phasor` | series | Hilbert — phasor components |
| `ht_sine` | series | Hilbert — SineWave |

## Candlestick Patterns

All take `open, high, low, close`. Return `100` (bullish), `-100` (bearish), `0` (none).
Functions with a `penetration` parameter take a 5th float argument.

| Function | Pattern |
|---|---|
| `cdl.doji` | Doji |
| `cdl.hammer` | Hammer |
| `cdl.hangingman` | Hanging Man |
| `cdl.engulfing` | Engulfing |
| `cdl.harami` | Harami |
| `cdl.haramicross` | Harami Cross |
| `cdl.shootingstar` | Shooting Star |
| `cdl.invertedhammer` | Inverted Hammer |
| `cdl.morningstar` | Morning Star (penetration) |
| `cdl.eveningstar` | Evening Star (penetration) |
| `cdl.3whitesoldiers` | Three White Soldiers |
| `cdl.3blackcrows` | Three Black Crows |
| `cdl.marubozu` | Marubozu |
| `cdl.spinningtop` | Spinning Top |
| `cdl.dojistar` | Doji Star |
| `cdl.dragonflydoji` | Dragonfly Doji |
| `cdl.gravestonedoji` | Gravestone Doji |
| `cdl.longleggeddoji` | Long-Legged Doji |
