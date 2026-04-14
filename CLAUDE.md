# Task: Create an Implementation Plan for a TypeScript-to-Python Translation Tool

## Your Goal
Produce a detailed, actionable implementation plan for improving `tt` — a TypeScript-to-Python
translator — so it can translate `RoaiPortfolioCalculator` from Ghostfolio into working Python.

## Context (read this, don't re-derive it)
- The challenge is to build a deterministic (no-LLM) TS→Python translator in Python
- The translator outputs to `translations/ghostfolio_pytx/app/implementation/`
- The abstract interface the translated code must satisfy is at:
  `translations/ghostfolio_pytx_example/app/wrapper/portfolio/calculator/portfolio_calculator.py`
- The primary TypeScript source to translate is the ROAI calculator under:
  `projects/ghostfolio/libs/portfolio/src/lib/calculator/roai/`
- The existing (minimal) translator lives in `tt/tt/`
- Tests live in `projecttests/ghostfolio_api/`

## How to Explore — Context Budget Rules
**You have a limited context window. Follow these rules strictly:**

1. **Do NOT read TypeScript source files in full.** Instead:
   - Use `glob` to map the file tree under `projects/ghostfolio/libs/portfolio/src/lib/calculator/roai/`
   - Read only the top ~50 lines of each TS file to understand structure (class names, method signatures, imports)
   - Use `grep` to find specific patterns (e.g. `public get`, `private`, `interface`, `type `) rather than reading whole files

2. **Read these files in full** (they are small and critical):
   - `tt/tt/translator.py`
   - `tt/tt/runner.py`
   - `tt/tt/cli.py`
   - `translations/ghostfolio_pytx_example/app/wrapper/portfolio/calculator/portfolio_calculator.py`
   - `translations/ghostfolio_pytx_example/app/implementation/portfolio/calculator/roai/portfolio_calculator.py`

3. **Skim, don't read** (first 30 lines only):
   - `translations/ghostfolio_pytx_example/app/wrapper/portfolio/portfolio_service.py`
   - One or two test files from `projecttests/ghostfolio_api/` to understand what's being asserted

4. **Do not read** the Ghostfolio app, UI, or API source outside of `libs/portfolio/`.

## What the Plan Must Cover
Structure your plan around these questions:

1. **Translation pipeline design** — What are the ordered transformation passes needed?
   (e.g. imports → class structure → method signatures → type annotations → control flow → expressions)

2. **TypeScript constructs to handle** — What TS patterns appear in the ROAI calculator that need
   mapping? (interfaces, generics, optional chaining, async/await, enums, destructuring, etc.)
   Base this on your grep/skim findings, not assumptions.

3. **Python output shape** — What must the generated Python look like to satisfy the abstract
   interface and pass the tests?

4. **Incremental milestones** — Break the work into 3–5 concrete steps ordered by test-pass impact.
   Which step is likely to unlock the most failing tests first?

5. **Risks and open questions** — What TS constructs are hardest to translate deterministically?
   What shortcuts or approximations are acceptable given the 2-hour competition window?

## Output Format
Return a structured markdown plan with:
- A one-paragraph strategy summary
- Numbered implementation steps, each with: goal, files to create/modify, and expected test impact
- A short risk section
- No code — this is a plan only
