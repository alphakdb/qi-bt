# QS CLI Reference

All commands are run through the `qbt` alias (`q qi.q bt`).

## Discovery

```bash
qbt strats          # list all strategies
qbt runs            # list all runs
qbt info mr_1       # detail for a strategy: logic, params
qbt info my_run     # detail for a run: config, linked strategy
```

## Running a backtest

```bash
qbt run my_run          # run by name (looks in bt/runs/)
qbt run my_run.v2       # run with alternate params (v2.params)
```

**Important:** `qbt run` takes only the run name — no path, no file extension.
The engine will error if `enter_at` or `exit_at` are missing from the run config.


- Correct:   `qbt run binance_pairs_mr1`
- Incorrect: `qbt run crypto/binance_pairs_mr1`
- Incorrect: `qbt run binance_pairs_mr1.conf`

## AI commands

```bash
# Choose and configure a provider (run once, or when switching)
qbt ai use anthropic -AI_API_KEY sk-...
qbt ai use openai    -AI_API_KEY sk-...

# Switch provider without re-entering the key
qbt ai use anthropic
qbt ai use openai
```

AI config lives at:
- `bt/ai/models/anthropic.conf` / `bt/ai/models/anthropic.secrets`
- `bt/ai/models/openai.conf`    / `bt/ai/models/openai.secrets`

Note: `qbt ai review` (post-run review via CLI) may not be implemented yet — check before suggesting it.

## Data sources

| Key | Asset class | Auth |
|---|---|---|
| `qi.binance` | Crypto | None |
| `qi.kraken`  | Crypto | None |
| `qi.alpaca`  | US equities | API key required |
| `qi.massive` | Multi-asset (equities, options, forex, crypto) | API key required |
| `/path/to/hdb` | Any | Local kdb+ database |

For providers requiring auth, keys are stored in `bt/data/{provider}.secrets`.

## Universe files

Single-asset strategies use a `.txt` file — one symbol per line:
```
BTCUSDT
ETHUSDT
SOLUSDT
```

Pairs strategies use a `.csv` file with `leg1` and `leg2` columns:
```csv
leg1,leg2
BTCUSDT,ETHUSDT
BTCUSDT,SOLUSDT
```

qbt detects the format automatically from the file extension.
Universe files live in `bt/universe/`.
