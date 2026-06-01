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

### CREATE — strategy

Ask in this order. Stop early if the user gives you enough to proceed.

**1. Strategy type**
```
What kind of strategy?

  1  Single-leg  (one instrument — long, short, or both sides)
  2  Pairs       (spread between two correlated instruments)
```

**2. Data source**
```
What data source?

  0  Own HDB  (local kdb+ database — I'll ask for the path)
  1  Binance  (crypto — no API key needed)
  2  Kraken   (crypto — no API key needed)
  3  Alpaca   (US equities — API key required)
  4  Massive  (multi-asset: equities, options, forex, crypto — API key required)

(Type 0 for Own HDB, or just name the exchange/provider in plain English.)
```
If the user picks Alpaca or Massive, note that an API key will need to be configured in
`bt/data/{provider}.secrets` before the run will work. Always use the internal key in the
run config (`qi.binance`, `qi.kraken`, `qi.alpaca`, `qi.massive`) even though the menu shows
friendly names.

**3. Strategy family**
```
What is the broad approach?

  1  Mean reversion   — fade moves away from an average
  2  Momentum / trend — ride moves in the prevailing direction
  3  Statistical arb  — pairs / spread / cointegration
  4  Other / I'll describe it
```
(If user picks 3, set type = Pairs automatically.)

**4. Free-form description**
```
Describe what the strategy should do in plain English.
Include any indicators, entry triggers, or exit rules you have in mind.
The more detail the better — I'll fill in the gaps.

(Type 0 to skip and let me suggest something based on your choices above.)
```

**5. Universe**

Tailor this question to the data source and strategy type already chosen:

- **Binance / Kraken, single-leg** — suggest: `BTCUSDT, ETHUSDT, SOLUSDT, BNBUSDT, XRPUSDT`
  (Kraken uses `USD` suffix instead of `USDT`, e.g. `BTCUSD`)
- **Binance / Kraken, pairs** — suggest: `BTCUSDT/ETHUSDT, BTCUSDT/SOLUSDT, ETHUSDT/SOLUSDT, BTCUSDT/BNBUSDT, ETHUSDT/BNBUSDT`
- **Alpaca, single-leg** — suggest: `AAPL, MSFT, NVDA, AMZN, GOOGL`
- **Alpaca, pairs** — suggest: `AAPL/MSFT, JPM/GS, XOM/CVX, KO/PEP, AAPL/GOOGL`
- **Massive** — multi-asset; ask the user what asset class they want before suggesting tickers
- **Own HDB** — no suggestions; ask the user what symbols are in their database

Present the suggestions as numbered options so the user can pick one or describe their own:
```
What instruments should it trade?

  1  [suggested set from above]
  2  Let me describe my own

(Type 0 to skip and use the suggestion above.)
```

For **single-leg** strategies, the universe file is a `.txt` file with one symbol per line.
For **pairs** strategies, it is a `.csv` file with `leg1` and `leg2` columns — one pair per row:
```csv
leg1,leg2
BTCUSDT,ETHUSDT
```
qbt detects the format automatically. Universe files live in `bt/universe/`.
If the user names specific instruments, offer to create the universe file for them.

**6. Name**
```
What should the strategy be called?
This becomes the folder name under bt/strategies/.

(Type 0 and I'll suggest one based on the description.)
```

After generating the strategy files, always offer to create a run config:

```
Strategy files are ready. Would you like to set up a run so you can backtest it?
I'll need a date range, interval, and starting equity — most things have sensible defaults.

  1  Yes, set up a run now
  2  No, I'll do that later
```

**Run config questions (if yes):**

1. Interval — `1m`, `5m`, `1h`, `1d` etc. (default: `1d`)
2. Date range — start and end (default: last 2 years)
3. Starting equity (default: `10000`)
4. Fees + slippage (default: `10bps` fees, `5bps` slip)
5. Risk limits — max drawdown, timeout bars (can skip)

The run name defaults to `{data_source}_{strategy_name}` (e.g. `binance_pairs_mr1`).

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
- `params:` — list every tunable value; no magic numbers in expressions
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
- Warmup: `auto`

### v1.params

Include every param declared in `params:` plus execution defaults:
```
warmup     = auto
enter_at   = next_open
enter_slip = 5bps
exit_at    = next_open
exit_slip  = 5bps
```
Choose sensible numeric defaults and comment on anything non-obvious.

### run config (.conf)

Follow the structure in `dsl.md` (Context / Timeline / Execution / Economics / Risk sections).
Default timeline: last 2 years at daily bars unless the user specified otherwise.

**`enter_at` and `exit_at` are mandatory** — the engine will error without them.
Always include an Execution section even if the user didn't ask about it:

```conf
# --- Execution ---
enter_at   = next_open
enter_slip = 5bps
exit_at    = next_open
exit_slip  = 5bps
```

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
- **Offer concrete options.** Numbered lists are easier than blank text boxes.
- **Skip gracefully.** Every question is optional — use sensible defaults and move on.
- **Stay in the DSL.** All generated code must be valid QS syntax per `dsl.md` and `ta.md`.
- **Pairs awareness.** If the strategy is pairs, reference `leg1_*` / `leg2_*` columns,
  use `spread`-based stops and trails, and avoid single-leg builtins like `max_high_since_entry`.
- **One file at a time.** When editing, show the diff rather than the whole file where possible.
- **Reference the examples.** `examples/strategies/` contains working reference implementations
  at increasing complexity — use them as a sanity check before finalising output.
