# QS DSL Reference

## Overview
.qs files define trading strategies for the qbt backtesting framework.
They are translated into q/kdb+ and run against historical bar data.
A strategy defines signals only — data, execution, and simulation settings
live in the run (.conf) file, not in the logic file.

## File Layout

```
bt/
  strategies/
    mystrat/
      logic.qs       # the strategy (this file)
      v1.params      # default parameters
      v2.params      # alternate parameter set
  runs/
    mybinance.conf   # wires strategy to data + execution
  common/
    lib/             # shared .qs and .q include files
    settings/
      promote.txt    # functions whose output gets column-promoted
  universe/
    myuniverse.txt   # list of symbols, one per line
```

## File Structure

Sections appear in order. `enter` and `exits` are required; all others optional.

```qs
# strategy name / description comment

include:
  volatility                  # loads common/lib/volatility.qs
  myfuncs                     # loads common/lib/myfuncs.q (raw q)

params:
  n, risk_per_trade           # comma-separated or one per line
  atr_n, bb_n

indicators:
  sma    = ta.sma(close, n)
  atr    = ta.atr(high, low, close, atr_n)
  vol_ok = atr > 0

sizing:
  qty = (run.initial_equity * risk_per_trade) / entry_price

[long]                        # side block — omit for long-only strategies
enter:
  close < sma
  vol_ok                      # multiple lines are ANDed
  # can also comma-separate on one line:
  # close < sma, vol_ok

exits:
  signal_exit:
    close > sma
  stop_loss:
    price: entry_price * (1 - sl_stop)
  take_profit:
    price: entry_price * (1 + tp_stop)
  trailing_stop:
    price: max_high_since_entry - (atr * atr_mult)
  pnl_stop:
    upnl_r <= -max_loss_r
  stale_exit:
    bars_since_entry > 30
    upnl_r <= 0.5

[short] @AI opposite          # or explicit [short] block below
```

## Side Blocks

`[long]` and `[short]` wrap `enter` and `exits` for two-sided strategies.
Without side blocks the strategy is implicitly long-only.

`[short] @AI opposite` on a single line is an AI preprocessing directive.
See directives.md. Everything else is explicit DSL.

## Exit Types

| Type | Triggered by | Evaluated against |
|---|---|---|
| `signal_exit` | indicator / price condition | close each bar |
| `stop_loss` | `price:` level | high/low intrabar |
| `take_profit` | `price:` level | high/low intrabar |
| `trailing_stop` | `price:` level (ratchets) | high/low intrabar |
| `pnl_stop` | `upnl_r` threshold | close each bar |
| `pnl_trailing` | MFE drawdown | close each bar |
| `time_stop` | `bars_since_entry` count | close each bar |
| `stale_exit` | composite condition | close each bar |

First triggered exit closes the position.

## Expression Syntax

- Params by name: `n`, `atr_mult`, `risk_per_trade`
- `run.initial_equity` — starting equity from run config
- `ta.func(args)` — technical indicators (see ta.md)
- `not expr` — boolean negation
- `prev close` — previous bar value of any series
- `I = 0` — true only on first bar of session (gap/open strategies)
- Standard: `+`, `-`, `*`, `/`, `<`, `>`, `<=`, `>=`, `=`

## Column Promotion

Functions returning multi-column tables (e.g. `ta.bbands`) can have their
columns promoted to top-level columns by listing the function in
`common/settings/promote.txt` (using the q `.ta.` prefix).

```qs
indicators:
  bb = ta.bbands(close, n, 2.0, 2.0, 0)
  # with .ta.bbands in promote.txt, this exposes:
  # bb_upper, bb_mid, bb_lower
```

## To Indicate or Not

Indicators can be defined in the `indicators` section or inline in `enter`/`exits`:

```qs
# as indicator (appears as column in results):
indicators:
  vol_ok = atr > 0
enter:
  vol_ok

# inline (no column, leaner output):
enter:
  ta.atr(high, low, close, atr_n) > 0
```

Use indicators when: the value is reused across multiple conditions, or you want
it visible in the result table for debugging.

## Params Files

Default is `v1.params`. Alternate sets are named `v2.params`, `v3.params` etc.
Run with a specific set: `qbt run myrun.v2` or set `strategy = mystrat.v2` in run file.

```params
n              = 20
risk_per_trade = 0.01
atr_n          = 14
warmup         = auto
```

## Pairs Strategies

A strategy that references `leg1_[col]` or `leg2_[col]` is automatically treated as a pairs strategy. The columns map to the legs defined in the universe CSV:

```csv
leg1,leg2
BTCUSDT,ETHUSDT
```

See `universe/pairs_crypto.csv` for an example. Any HLOC column is accessible as `leg1_close`, `leg2_high`, `leg1_low` etc.:

```qs
indicators:
  beta   = ta.beta(leg1_close, leg2_close, lookback)
  spread = leg1_close - (beta * leg2_close)
  m      = ta.sma(spread, lookback)
  s      = ta.stddev(spread, lookback, 1)
  zscore = (spread - m) / s

enter:
  zscore < -entry_z

exits:
  signal_exit:
    zscore >= -exit_z
```
