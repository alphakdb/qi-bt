# QS AI Interaction Guide

When a user points you at this folder (or asks you to read `bt/ai` or similar):

Read all files in `bt/ai/context/`. Once you have read them, show the action menu below.
The user already knows what qbt is — skip any introduction and go straight to the menu.

---

## Step 1 — Action menu

Present this exactly:

```
What would you like to do?

  1  Create a strategy
  2  Clone a strategy
  3  Edit a strategy or run config
  4  View / explain a strategy or run config

Enter a number, or describe what you want in plain English.
```

If the user types plain English instead of a number, infer the action and confirm before proceeding.

**Note on "runs":** Don't lead with the concept of a run — users think in terms of strategies.
A run config is introduced naturally at the end of CREATE (step 2f below) as "wiring the strategy
to data so you can execute it." For EDIT and VIEW, ask whether they want the strategy logic or
the run config as a follow-up once you know which strategy they mean.

---

## Step 2 — Gather context (question flows)

Ask questions **one screen at a time** — do not dump all questions at once.
For every question, tell the user they can type `0` to skip / use the default.
**Never use "press Enter" for anything** — the VS Code Claude plugin does not treat a bare Enter as input. Always require the user to type something (a number, a word, or `0` to skip). This includes "press Enter to continue", "press Enter to confirm", "press Enter to skip", and any similar phrasing.
Offer numbered options wherever the answer is from a fixed set.

**Goal: ask as few questions as possible.** Lead with a single open description question.
Extract everything you can from the answer — exchange, interval, tickers, date range, approach,
rules — then only ask follow-ups for the specific details that are still missing.
Never ask for something the user already told you.

### CREATE — strategy

**1. Choose mode**

```
How would you like to build the strategy?

  1  Describe it  — tell me what you want in plain English, I'll ask only for what's missing
  2  Step by step — I'll walk you through it with guided questions
```

---

#### Mode 1 — Describe it

```
Describe your strategy — the more detail you give, the fewer follow-up questions I'll need.

Examples:
  "BTC/ETH pairs mean reversion on Binance, 1h bars, last 6 months"
  "Stat arb on Binance — SOLUSDT vs BNBUSDT, 15m bars, z-score entry at ±2,
   exit at reversion, stop if z-score exceeds ±4"
  "Long-only momentum on AAPL, MSFT, NVDA via Alpaca, daily bars, 2023–2025,
   enter when RSI crosses above 55, exit when it drops below 45"
  "JPM/GS pairs mean reversion on Alpaca, daily bars, last 2 years"
  "Mean reversion on my own HDB at /data/hdb — symbols XYZUSD and ABCUSD,
   1m bars, Jan–Mar 2025"
```

Parse the response and extract what you can:
- Exchange / data source
- Interval
- Tickers / universe
- Date range
- Strategy type (single-leg or pairs) and family (MR, momentum, stat arb)
- Entry and exit rules

**2. Follow-up — only ask about what is genuinely missing**

Combine all remaining gaps into one short screen. One line per item, no explanations.
Include interval, date range, and equity here if not yet known — params like `lookback`
cannot be calibrated without knowing the interval (30 bars on `1d` ≈ a month;
on `1m` ≈ 30 minutes). Maximum 4 items.

If **rules** are missing, ask for them and give a brief concrete example relevant to the
approach already described — one line, not a paragraph:

```
A few quick details (type 0 for any default):

  Entry/exit rules (e.g. "enter long when zscore < -2, exit when zscore > -0.5, stop at -4" — or type 0 to let me design them):
  Interval (default 1d):
  Date range (default last 2 years):
  Starting equity (e.g. 10000, 50000, 1000000 — default 10000):
```

Only show lines for things that are genuinely unknown. If the user already said
"BTC/ETH on Binance 1h bars last 6 months", do not ask about tickers, exchange, interval,
or date range — only ask about what is missing (e.g. rules, equity).

If **tickers** are missing, suggest a relevant set based on the exchange and strategy type
(see suggestions below) and let the user pick or describe their own.

**3. Name (always last)**
```
What should the strategy be called? (type 0 to let me suggest one)
```

---

#### Mode 2 — Step by step

Ask in this order, one screen at a time. Skip any question where the answer is already known.

**1. Strategy type**
```
What kind of strategy?

  1  Single-leg  (one instrument)
  2  Pairs       (spread between two correlated instruments)
```

**2. Data source**
```
What data source?

  0  Own HDB  (local kdb+ database)
  1  Binance  (crypto)
  2  Kraken   (crypto)
  3  Alpaca   (US equities — API key required)
  4  Massive  (multi-asset — API key required)
```
If Alpaca or Massive: note that an API key must be configured in `bt/data/{provider}.secrets`.
If Own HDB: ask for the HDB path and the bar table name (e.g. `AlpacaEquityB1Day`) — the
engine errors with `'no bars defined` without `bars = <TableName>` in the run config.
For any equity data source (Alpaca, Massive, equity HDB): always include market hours in the
run config — `market_open = 14:30:00` and `market_close = 21:00:00` (UTC, US equities).

**3. Strategy family**
```
What is the broad approach?

  1  Mean reversion
  2  Momentum / trend
  3  Statistical arb  (pairs / spread / cointegration)
  4  Other — I'll describe it
```
(If user picks 3, set type = Pairs automatically.)

**4. Description**
```
Describe what the strategy should do — entry/exit rules, indicators, risk controls.

(Type 0 to let me design something based on your choices above.)
```

**5. Remaining details** — collect in one block, only for what is still missing:
```
A few quick details (type 0 for any default):

  Tickers:
  Interval (default 1d):
  Date range (default last 2 years):
  Starting equity (e.g. 10000, 50000, 1000000 — default 10000):
```

**6. Name (always last)**
```
What should the strategy be called? (type 0 to let me suggest one)
```

---

### Universe suggestions

Tailor to the data source and strategy type already known:

- **Binance / Kraken, single-leg** — suggest: `BTCUSDT, ETHUSDT, SOLUSDT, BNBUSDT, XRPUSDT`
  (Kraken uses `USD` suffix, e.g. `BTCUSD`)
- **Binance / Kraken, pairs** — suggest: `BTCUSDT/ETHUSDT, BTCUSDT/SOLUSDT, ETHUSDT/SOLUSDT, BTCUSDT/BNBUSDT, ETHUSDT/BNBUSDT`
- **Alpaca, single-leg** — suggest: `AAPL, MSFT, NVDA, AMZN, GOOGL`
- **Alpaca, pairs** — suggest: `AAPL/MSFT, JPM/GS, XOM/CVX, KO/PEP, AAPL/GOOGL`
- **Massive** — multi-asset; ask the user what asset class they want before suggesting tickers
- **Own HDB** — no suggestions; ask the user what symbols are in their database.
  Also ask for the bar table name — the engine cannot infer it from `interval` alone and will
  error with `'no bars defined` without it. The table name lives inside a date partition of the
  HDB (e.g. `AlpacaEquityB1Day`, `Bar1d`, `daily`). Add `bars = <TableName>` to the run config.

For **single-leg** strategies, the universe file is a `.txt` file with one symbol per line.
For **pairs** strategies, it is a `.csv` file with `leg1` and `leg2` columns — one pair per row:
```csv
leg1,leg2
BTCUSDT,ETHUSDT
```
qbt detects the format automatically. Universe files live in `bt/universe/`.
If the user names specific instruments, offer to create the universe file for them.

---

### Run config offer (after strategy files are confirmed)

Because interval, date range, and equity are gathered during CREATE (step 3 above), the run
config offer is usually just a confirmation:

```
Strategy files are ready. Want me to create a run config too?
I have everything I need — it'll use {interval} bars, {start} to {end}, ${equity} equity.

  1  Yes, create the run
  2  No, I'll do that later
```

Only ask additional run config questions if genuinely unknown:

1. Fees + slippage (default: `10bps` fees, `5bps` slip)
2. Risk limits — max drawdown, timeout bars (can skip)

The run name defaults to `{data_source}_{strategy_name}` (e.g. `binance_pairs_mr1`).

If Alpaca or Massive is the data source, note that an API key must be configured in
`bt/data/{provider}.secrets` before the run will work.

---

### CLONE

Ask:
1. Which strategy to clone (list available with `qbt strats`)
2. What the clone should be named
3. What should be different (optional — can edit after)
4. Do you also want to clone an existing run config for it? (optional)

If the source strategy contains `[short] @AI opposite`, expand it into an explicit `[short]`
block in the clone — do not copy the directive. Apply the transformation rules from
`directives.md` yourself.

---

### EDIT

Ask:
1. Which strategy? (list available with `qbt strats`)
2. What part do you want to edit?
   ```
     1  Strategy logic (logic.qs)
     2  Parameters (v1.params or other variant)
     3  Run config (.conf)
   ```
3. What should change? (free text)

Then apply the change using the correct DSL syntax. Always write both `[long]` and `[short]`
blocks explicitly — never emit `@AI opposite` in any file you generate. That directive is a
convenience for users editing files by hand; when written into a file it triggers an engine
API call that the user may not have configured.

---

### VIEW / EXPLAIN

Read the requested file(s) and give a plain-English summary covering:
- What the strategy does and why
- Entry conditions
- Exit conditions and risk controls
- Any parameters the user is likely to want to tune

Use `@AI describe` framing — suitable for a non-technical reader.

---

## Step 3 — Generate files

Once you have enough information, generate the following as appropriate.

### logic.qs

Follow the structure in `dsl.md` exactly.

- Header comment: name, one-line description, complexity rating (1–4)
- `params:` — list every tunable value referenced in the logic; no magic numbers in expressions;
  **do not include execution params** (warmup, enter_at, enter_slip, exit_at, exit_slip) —
  those belong in the run config and params file only stores values used in logic.qs
- `indicators:` — derived series only; keep it readable
- `sizing:` — default to `qty = (run.initial_equity * risk_per_trade) / entry_price`
- `enter:` / `exits:` — one condition per line; AND logic is implicit across lines
- For two-sided strategies: write both `[long]` and `[short]` blocks explicitly.
  Never emit `@AI opposite` — it triggers an engine API call the user may not have configured.
  Apply the same transformations yourself (flip price comparisons, flip stop arithmetic,
  flip trail direction — see `directives.md` for the full rules).

Good defaults when the user hasn't specified:
- Stop loss: ATR-based (`price: entry_price - (atr * atr_mult)`)
- Pairs stop: spread-based (`spread: entry_price - (s * sl_mult)`)
- Sizing: fixed fractional (`risk_per_trade = 0.02`)

### v1.params

Include **only** the params declared in `params:` in the logic file — values that are
referenced in indicators, sizing, enter, or exits. Do not include execution settings.

**Calibrate numeric defaults to the interval.** A lookback of 20 means 20 bars — that is
20 days on `1d`, 20 hours on `1h`, 20 minutes on `1m`. Pick values that make economic sense
for the timeframe. Examples:
- `1d` bars: `lookback = 20` (≈ 1 month), `atr_n = 14`
- `1h` bars: `lookback = 48` (≈ 2 days), `atr_n = 24`
- `1m` bars: `lookback = 60` (≈ 1 hour), `atr_n = 30`

```
n              = 20
risk_per_trade = 0.01
atr_n          = 14
```

### run config (.conf)

Follow the structure in `dsl.md` (Context / Timeline / Execution / Economics / Risk sections).
Default timeline: last 2 years at daily bars unless the user specified otherwise.

**`enter_at` and `exit_at` are mandatory** — the engine will error without them.
Always include an Execution section even if the user didn't ask about it:

```conf
# --- Execution ---
warmup     = auto
enter_at   = next_open
enter_slip = 5bps
exit_at    = next_open
exit_slip  = 5bps
```

For **equity strategies** (Alpaca, Massive, or any HDB with equity data), always include
market hours in UTC — failure to do so means the engine will process bars outside market hours:

```conf
market_open  = 14:30:00
market_close = 21:00:00
```

`interval` is the correct field name for the bar size (not `period`).
`next_open` is the correct default for most strategies (signal fires at close, fills at next bar's open).
See the reference run files in `examples/runs/` for complete working examples.

---

## Step 4 — Confirm before writing

Before creating or modifying any file, show the user what you're about to write and ask:

```
Here's what I'm going to create:

  bt/strategies/my_strat/logic.qs   — strategy logic
  bt/strategies/my_strat/v1.params  — default parameters
  bt/runs/my_run.conf               — run config

Shall I go ahead? You can also ask me to change anything first.
```

Only write files after explicit confirmation.

---

## Useful CLI commands to share with the user

When the user needs to discover what already exists, suggest:

```bash
qbt strats          # list all strategies
qbt runs            # list all runs
qbt info my_strat   # show logic + params for a strategy
qbt info my_run     # show config for a run
qbt run my_run      # execute a run
qbt ai review my_run  # AI review of a completed run (check if implemented)
```

See `cli.md` for the full reference.

---

## General principles

- **Ask, don't assume.** One unclear answer is worth a follow-up question.
- **Minimise questions.** Extract everything possible from what the user already said.
  Only ask about genuine gaps. Never ask for something already provided.
- **Offer concrete options.** Numbered lists are easier than blank text boxes.
- **Skip gracefully.** Every question is optional — use sensible defaults and move on.
- **Stay in the DSL.** All generated code must be valid QS syntax per `dsl.md` and `ta.md`.
- **Pairs awareness.** If the strategy is pairs, reference `leg1_*` / `leg2_*` columns,
  use `spread`-based stops and trails, and avoid single-leg builtins like `max_high_since_entry`.
- **One file at a time.** When editing, show the diff rather than the whole file where possible.
- **Reference the examples.** `examples/strategies/` contains working reference implementations
  at increasing complexity — use them as a sanity check before finalising output.
- **params vs run config.** `v1.params` contains only values referenced in `logic.qs`.
  Execution settings (warmup, enter_at, enter_slip, exit_at, exit_slip) always go in the run
  config `.conf` file, never in `.params`.
