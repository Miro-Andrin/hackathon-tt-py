# Explanation of the submission

## Solution

This project implements a Python FastAPI version of the Ghostfolio portfolio API. It uses a "Wrapper/Implementation" architecture:
- **Wrapper Layer**: Handles HTTP routing, authentication, and in-memory state management. (Immutable)
- **Implementation Layer**: Contains the core ROAI (Return on Average Investment) calculation logic. (Target for translation)

## Coding Approach

The team is migrating the financial calculation logic from the original Ghostfolio TypeScript codebase (`projects/ghostfolio/apps/api/src/app/portfolio/calculator/roai/portfolio-calculator.ts`) into the Python implementation at `translations/ghostfolio_pytx/app/implementation/portfolio/calculator/roai/portfolio_calculator.py`.

---

## 🤖 Agent Instructions

### How to Run Tests
To verify the current implementation against the integration test suite, run:
```bash
make spinup-and-test-ghostfolio_pytx_example
```
*Note: Ensure `uv` is installed and in your PATH.*

### Validation Mandate
**Rerun the tests after every major code change.** A change is only considered an improvement if it increases the number of passing tests or fixes a specific logic bug without regressing existing passes.

## 📊 Progress Tally

| Category | Count |
| :--- | :--- |
| **Total Tests** | 135 |
| **Passed ✅** | 48 |
| **Failed ❌** | 87 |

*Last updated: 2026-04-14*
