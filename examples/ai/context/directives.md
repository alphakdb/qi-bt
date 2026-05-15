# @AI Directives

@AI directives are preprocessing instructions. They are expanded into explicit DSL
and written back into the file before compilation. The engine never sees @AI — only
the generated output.

A hash is stored alongside the directive to cache the result. The AI is only
called when the source content changes.

---

## @AI opposite

**Scope:** `[short]` block  
**Syntax:** `[short] @AI opposite`  
**Source:** The `[long]` block in the same file

Generates a `[short]` block by transforming the `[long]` block.

### Rules

**Flip directional price conditions** — comparisons involving open/high/low/close
or a zscore/spread against a level:
```
close < sma       →   close > sma
close > bb_upper  →   close < bb_lower
(zscore + z) < 0  →   (zscore + z) > 0
gap < threshold   →   gap > threshold
```

**Preserve filter and gate conditions unchanged** — conditions that are
side-neutral and make no sense to invert:
```
vol_ok            →   vol_ok        (atr > 0 is always positive)
vol_regime_low    →   vol_regime_low
atr > 0           →   atr > 0
bars_since_entry > n  →  bars_since_entry > n
```

**Flip price exit arithmetic** — stop/target levels:
```
price: entry_price * (1 - sl_stop)  →  price: entry_price * (1 + sl_stop)
price: entry_price * (1 + tp_stop)  →  price: entry_price * (1 - tp_stop)
price: entry_price - (atr14 * mult) →  price: entry_price + (atr14 * mult)
```

**Trailing stops** — flip the direction:
```
price: max_high_since_entry - (atr14 * mult)  →  price: min_low_since_entry + (atr14 * mult)
```

**Preserve unchanged:**
- `upnl_r` comparisons (already side-aware)
- `bars_since_entry` conditions (time, not direction)
- `sizing` block (unchanged)
- `params`, `indicators`, `include` sections (shared between sides)

### Output format
Return only the `[short]` block content — `enter:` and `exits:` sections.
No explanation. No commentary. Match the indentation and style of the `[long]` block exactly.

---

## @AI review

**Scope:** whole file  
**Syntax:** `@AI review`

Review the strategy for correctness issues. Return a concise bullet list only — no
preamble, no summary. Flag:

- Look-ahead bias (using future data in entry/exit conditions)
- Exits that can never trigger given the entry conditions
- Params declared in `params:` but never used in indicators/sizing/enter/exits
- Stop loss wider than take profit (poor risk/reward)
- Missing warmup consideration for long-period indicators
- Entry conditions that are always true or always false
- Sizing using `close` instead of `entry_price` (overstates fill accuracy)

---

## @AI describe

**Scope:** whole file  
**Syntax:** `@AI describe`

Summarise the strategy in 2-3 plain English sentences suitable for a non-technical
client. Cover: what triggers entry, what triggers exit, any key risk controls.
No DSL terms, no q/kdb references.

---

## @AI add [feature]

**Scope:** a section  
**Syntax:** within `exits:`, `indicators:`, etc.

Free-text instruction to add something coherent with the existing strategy.
Examples:
```
exits:
  signal_exit:
    close > sma
  @AI add a time stop of 5 bars and a trailing stop based on atr
```

The AI reads the existing section content for context and appends the requested
feature in valid DSL syntax.

---

## @AI from description

**Scope:** whole file (empty or partial)  
**Syntax:**
```
@AI from description:
  Enter long when price is two standard deviations below its 20-day mean.
  Exit when it reverts to the mean. Stop out at 1.5x ATR below entry.
```

Generates a complete `.qs` strategy file from a plain English description.
Infers appropriate `params:`, `indicators:`, `enter:`, and `exits:` sections.
Uses conservative, standard parameter names. Adds a `params:` declaration for
every value that should be tunable.

---

## Caching

Each directive stores a hash of its source content as a comment:
```
[short] @AI opposite # hash:a3f9c2b1
```

The hash covers the `[long]` block with comment lines stripped and whitespace
normalised. If the hash matches on the next run, the generated block is reused
and no API call is made.
