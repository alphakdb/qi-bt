# Built-in Variables

## Price Series (per bar)
| Name   | Description                   |
|--------|-------------------------------|
| open   | Bar open price                |
| high   | Bar high price                |
| low    | Bar low price                 |
| close  | Bar close price               |
| volume | Bar volume                    |
| vwap   | Volume-weighted average price |

## Position Variables (exits and sizing)
| Name                 | Description |
|----------------------|-------------|
| entry_price          | Actual fill price (next open + slippage). Use this in sizing, not `close` |
| bars_since_entry     | Integer bar count since entry |
| upnl                 | Unrealised PnL per unit |
| upnl_r               | Unrealised PnL in R-units (normalised to initial stop distance) |
| mfe_r                | Maximum favourable excursion in R-units |
| giveback_r           | Retracement from peak: mfe_r - upnl_r |
| max_high_since_entry | Running max of high since entry — use in long trailing stops |
| min_low_since_entry  | Running min of low since entry — use in short trailing stops |

## Run Config
| Name               | Description                      |
|--------------------|----------------------------------|
| run.initial_equity | Starting equity from run config  |

## Pairs Variables (pairs strategies only)
| Name                    | Description |
|-------------------------|-------------|
| `spread`                | Current bar spread value (leg1_close - beta * leg2_close, or as defined) |
| `max_spread_since_entry`| Running max of spread since entry — use in long trailing stops |
| `min_spread_since_entry`| Running min of spread since entry — use in short trailing stops |
| `leg1_open`             | Leg 1 bar open |
| `leg1_high`             | Leg 1 bar high |
| `leg1_low`              | Leg 1 bar low |
| `leg1_close`            | Leg 1 bar close |
| `leg2_open`             | Leg 2 bar open |
| `leg2_high`             | Leg 2 bar high |
| `leg2_low`              | Leg 2 bar low |
| `leg2_close`            | Leg 2 bar close |

## Cross-Sectional (kind: panel only)
| Name             | Description                            |
|------------------|----------------------------------------|
| rank(series)     | Cross-sectional rank across universe   |
| count(universe)  | Number of symbols in universe          |

## Special Syntax
| Syntax     | Meaning                                          |
|------------|--------------------------------------------------|
| prev close | Previous bar value of any series                 |
| I = 0      | True only on first bar of session (gap entries)  |
| not expr   | Boolean negation                                 |
