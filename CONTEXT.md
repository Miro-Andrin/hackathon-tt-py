# Hackathon Context — Team ai-ai

## What this is
Hackathon task: build `tt`, a TypeScript→Python translation tool that translates `RoaiPortfolioCalculator` from Ghostfolio (wealth management app) into Python. No LLMs allowed for translation itself. Scored by API test pass rate (85%) + code quality (15%).

## Current state
- **Branch:** `kb` (pushed to `github.com/Miro-Andrin/hackathon-tt-py`)
- **Score on leaderboard:** 55.12 overall (27.4% tests, 82.8% code quality, grade B)
- **Team name:** `ai-ai`
- **All rule checks:** passing

## What `tt translate` does today
1. Copies scaffold from `translations/ghostfolio_pytx_example/` (FastAPI wrapper, immutable)
2. Runs a **minimal regex-based** translator (`tt/tt/translator.py`) — only extracts `getPerformanceCalculationType()`, everything else is the zero-stub
3. Output → `translations/ghostfolio_pytx/app/implementation/portfolio/calculator/roai/portfolio_calculator.py`

## The real work that needs doing
**Rewrite `tt/tt/translator.py`** to use tree-sitter (already added as dependency in `tt/pyproject.toml`) to properly translate the TypeScript ROAI calculator into working Python.

### Source to translate
`projects/ghostfolio/apps/api/src/app/portfolio/calculator/roai/portfolio-calculator.ts` (1010 lines)

Two methods to translate:
- `calculateOverallPerformance(positions)` — simple aggregation loop (~95 lines, LOW complexity)
- `getSymbolMetrics({chartDateMap, dataSource, symbol, start, end, exchangeRates, marketSymbolMap})` — core financial math (~878 lines, HIGH complexity)

### Output must implement (abstract interface)
`translations/ghostfolio_pytx_example/app/wrapper/portfolio/calculator/portfolio_calculator.py`
- `get_performance() -> dict`
- `get_investments(group_by) -> dict`
- `get_holdings() -> dict`
- `get_details(base_currency) -> dict`
- `get_dividends(group_by) -> dict`
- `evaluate_report() -> dict`

### Key TypeScript→Python mappings
| TypeScript | Python |
|---|---|
| `new Big(x)` | `Decimal(x)` |
| `a.plus(b)` / `.minus()` / `.times()` / `.div()` | `a + b` / `-` / `*` / `/` |
| `a.eq(0)` / `.gt()` / `.gte()` / `.lt()` | `== Decimal(0)` / `>` / `>=` / `<` |
| `a.toNumber()` | `float(a)` |
| `format(date, DATE_FORMAT)` | `d.strftime('%Y-%m-%d')` |
| `differenceInDays(a, b)` | `(a - b).days` |
| `addMilliseconds(d, n)` | `d + timedelta(milliseconds=n)` |
| `cloneDeep(x)` | `copy.deepcopy(x)` |
| `sortBy(arr, fn)` | `sorted(arr, key=fn)` |
| `getFactor(type)` | `1 if type=='BUY' else -1 if type=='SELL' else 0` |
| `a ?? b` | `a if a is not None else b` |
| `a?.b` | `(a or {}).get('b')` |
| `new Map()` | `{}` |
| Type annotations, imports, `}` | Strip |

### CurrentRateService (injected, use for price lookups)
```python
self.current_rate_service.get_price(symbol, date_str)       # exact date
self.current_rate_service.get_latest_price(symbol)           # most recent
self.current_rate_service.get_nearest_price(symbol, date_str) # closest prior
self.current_rate_service.all_dates_in_range(start, end)     # set of date strings
```

Activities format (list of dicts):
```python
{"date": "2021-12-12", "symbol": "BTCUSD", "type": "BUY", "quantity": 1,
 "unitPrice": 44558.42, "fee": 4.46, "currency": "USD", "dataSource": "YAHOO"}
```

## How to iterate
```bash
# Translate + run full test suite:
make translate-and-test-ghostfolio_pytx

# Re-test without re-translating:
make spinup-and-test-ghostfolio_pytx

# Full eval + score:
make evaluate_tt_ghostfolio

# Publish to leaderboard (needs TEAM_NAME exported):
export TEAM_NAME=ai-ai && make publish_results
```
`.env` already has `TEAM_NAME`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`.

## File map
| File | Purpose |
|---|---|
| `tt/tt/translator.py` | **Rewrite this** — currently regex stub |
| `tt/tt/cli.py` | Entry point — calls scaffold setup then `run_translation()` |
| `tt/pyproject.toml` | Has `tree-sitter>=0.23`, `tree-sitter-typescript>=0.23` |
| `projects/ghostfolio/apps/api/src/app/portfolio/calculator/roai/portfolio-calculator.ts` | TypeScript source (read-only) |
| `translations/ghostfolio_pytx_example/app/implementation/portfolio/calculator/roai/portfolio_calculator.py` | Zero-stub reference (read-only) |
| `translations/ghostfolio_pytx/` | Generated output (deleted and recreated on each `tt translate`) |
| `projecttests/ghostfolio_api/` | Test suite (13 files, ~135 tests) |
| `projecttests/ghostfolio_api/mock_prices.py` | Market prices to seed (BTCUSD, MSFT, NOVN.SW, etc.) |

## Rules (critical)
- No LLMs in `tt/` for translation
- No hard-coded project-specific logic in `tt/` core
- Only generate files inside `app/implementation/` — wrapper is immutable
- `make detect_rule_breaches` to verify compliance
