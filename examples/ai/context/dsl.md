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

kind: panel | spread          # optional — default is single-instrument

include:
  volatility                  # loads common/lib/volatility.qs
  myfuncs                     # loads common/lib/myfuncs.q (raw q)

params:
  n, risk_per_trade           # comma-separated or one per line
  atr_n, bb_n

state:                        # persistent rolling state (pairs/spread only)
  beta = ta.beta(leg1.close, leg2.close, lookback)

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
  time_stop:
    bars_since_entry > max_hold_bars
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

## Kind: Panel

Cross-sectional strategies operating on a universe simultaneously:

```qs
kind: panel

indicators:
  rsi_val       = ta.rsi(close, rsi_n)
  relative_rank = rank(rsi_val) / count(universe)

enter:
  relative_rank < 0.10

exits:
  laggard_exit:
    relative_rank > 0.30
```

## Kind: Spread

Pairs / spread strategies with two legs:

```qs
kind: spread

state:
  beta          = ta.beta(leg1.close, leg2.close, lookback)
  actual_spread = leg1.close - (beta * leg2.close)

indicators:
  m      = ta.sma(actual_spread, lookback)
  s      = ta.stddev(actual_spread, lookback, 1)
  zscore = (actual_spread - m) / s

enter:
  zscore < -entry_z

exits:
  target:
    zscore >= -exit_z
```
