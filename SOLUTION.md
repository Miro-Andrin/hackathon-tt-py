# Solution — Team ai-ai

## Solution

### What `tt` does

`tt` is a TypeScript-to-Python translation tool that converts the `RoaiPortfolioCalculator` from the Ghostfolio wealth-management codebase into a working Python implementation.

The translator uses a **two-layer architecture**:

1. **Tree-sitter AST parsing** — `tt` parses the TypeScript source using `tree-sitter` + `tree-sitter-typescript` to walk the concrete syntax tree and emit semantically correct Python. This is more robust than regex substitution because it understands the structure of the code (method boundaries, expression types, block nesting) rather than operating on raw text.

2. **Scaffold + implementation split** — The output project is assembled by:
   - Copying the immutable wrapper layer from `translations/ghostfolio_pytx_example/` (FastAPI routes, service delegation, abstract interface)
   - Generating `app/implementation/portfolio/calculator/roai/portfolio_calculator.py` via the AST translator

### Key translation mappings

| TypeScript construct | Python output |
|---|---|
| `new Big(x)` | `Decimal(x)` |
| `a.plus(b)`, `.minus()`, `.times()`, `.div()` | `a + b`, `-`, `*`, `/` |
| `a.eq(0)`, `.gt()`, `.gte()` | `a == Decimal(0)`, `>`, `>=` |
| `a.toNumber()` | `float(a)` |
| `format(date, DATE_FORMAT)` | `date.strftime('%Y-%m-%d')` |
| `differenceInDays(a, b)` | `(a - b).days` |
| `addMilliseconds(d, n)` | `d + timedelta(milliseconds=n)` |
| `cloneDeep(x)` | `copy.deepcopy(x)` |
| `sortBy(arr, fn)` | `sorted(arr, key=fn)` |
| `getFactor(type)` | Inline helper: 1/−1/0 for BUY/SELL/other |
| `null ?? fallback` | `x if x is not None else fallback` |
| `a?.b` | `(a or {}).get('b')` |
| TypeScript type annotations | Stripped |
| `import` statements | Replaced with Python stdlib imports |

### What the translated code implements

The translator produces a `RoaiPortfolioCalculator` class implementing the abstract interface:

- `get_performance()` — chart history + aggregate performance metrics using `getSymbolMetrics` per symbol
- `get_investments(group_by)` — cumulative investment timeline, optionally grouped by month/year
- `get_holdings()` — current open positions with quantity, average price, market value
- `get_details(base_currency)` — full account/holdings/summary breakdown
- `get_dividends(group_by)` — dividend history grouped by date
- `evaluate_report()` — xRay rule evaluation stubs

The core financial logic is a faithful translation of `getSymbolMetrics()` from the TypeScript ROAI calculator, which computes time-weighted performance, cost-basis tracking, gross/net performance with and without currency effects, and per-date chart history.

---

## Coding approach

### How we arrived at the solution

1. **Explored the codebase** — read the full TypeScript `RoaiPortfolioCalculator` (1010 lines), the abstract Python interface, the example scaffold, and the API test suite to understand exactly what values the tests assert on.

2. **Identified the gap** — the scaffold alone passes ~48 tests by hardcoding stub responses. The remaining ~87 tests require the actual `getSymbolMetrics` financial calculation to work correctly.

3. **Chose tree-sitter** over regex because the TypeScript source uses complex patterns (Big.js method chaining, destructured parameters, optional chaining, generics) that are ambiguous to parse with regex but straightforward with an AST visitor.

4. **Built iteratively** — the translation pipeline is:
   ```
   tt translate → FastAPI server → pytest → fix translator → repeat
   ```
   Running `make translate-and-test-ghostfolio_pytx` after each change gives immediate feedback on which tests pass and what values are wrong.

5. **Prioritised correctness over completeness** — focused on getting the core calculation loop right (BUY/SELL investment tracking, time-weighted averaging, fee deduction) before tackling edge cases like currency effects or the date-range performance map.
