# Test Report: Search Books by Title

**Jira Ticket:** KAN-1  
**Date:** 2026-08-19  
**Status:** PASS  

---

## Test Summary

| Metric | Value |
|---|---|
| Total scenarios | 12 |
| Passed | 12 |
| Failed | 0 |
| Skipped | 0 |
| Duration | 10.4s |

---

## Command Log

```
# Step 1 — Generate BDD test files from feature files
node_modules/.bin/bddgen

# Step 2 — Run Playwright BDD test suite
npm test
# (runs: playwright test)

# Output
Running 12 tests using 1 worker
12 passed (10.4s)
```

---

## Test Files

| File | Purpose |
|---|---|
| `tests/manual/features/search-books.feature` | Gherkin scenarios (9 scenarios, 4 case-insensitivity examples) |
| `tests/automation/step-definitions/search-books.steps.js` | Step definitions |
| `tests/automation/support/fixtures.js` | Custom `bookstorePage` fixture |
| `tests/automation/support/page-objects/bookstore.page.js` | `BookstorePage` page object |
| `playwright.config.js` | Playwright + BDD config, static `serve` webServer |

---

## Scenario Results

| # | Scenario | Tags | Result |
|---|---|---|---|
| 1 | Page loads and displays all books | @REQ-FR01 @REQ-FR04 | PASS |
| 2 | Search filters results by title | @REQ-FR02 @REQ-FR04 @AC-1 | PASS |
| 3 | Each book card shows all required fields | @REQ-FR04 @AC-2 | PASS |
| 4 | Empty state is shown when no books match | @REQ-FR05 @AC-3 | PASS |
| 5 | Search is case-insensitive (Example #1: "the hobbit") | @REQ-FR06 @AC-4 | PASS |
| 6 | Search is case-insensitive (Example #2: "THE HOBBIT") | @REQ-FR06 @AC-4 | PASS |
| 7 | Search is case-insensitive (Example #3: "The Hobbit") | @REQ-FR06 @AC-4 | PASS |
| 8 | Search is case-insensitive (Example #4: "tHe hObBiT") | @REQ-FR06 @AC-4 | PASS |
| 9 | Search input enforces 100 character maximum | @REQ-FR07 @AC-5 | PASS |
| 10 | Pressing Enter triggers search immediately | @REQ-FR03 @AC-6 | PASS |
| 11 | Clicking the search button triggers search | @REQ-FR03 | PASS |
| 12 | Clearing the search input restores all books | @REQ-FR02 | PASS |

---

## Traceability Matrix

```
FR-01 — Search input displayed at top
  AC-5 (input visible)
    tests/manual/features/search-books.feature
      Scenario 1: Page loads and displays all books

FR-02 — Real-time filtering with 300ms debounce
  AC-1 (filter by title)
    Scenario 2: Search filters results by title
  AC-6 (debounce / Enter trigger)
    Scenario 10: Pressing Enter triggers search immediately
    Scenario 12: Clearing the search input restores all books

FR-03 — Trigger search on Enter / button click
  Scenario 10: Pressing Enter triggers search immediately
  Scenario 11: Clicking the search button triggers search

FR-04 — Display cover, title, author, price, Add to Cart
  AC-2 (all card fields present)
    Scenario 3: Each book card shows all required fields
    Scenario 1: Page loads and displays all books

FR-05 — Empty state message
  AC-3 (no-results message)
    Scenario 4: Empty state is shown when no books match

FR-06 — Case-insensitive search
  AC-4 (case-insensitivity)
    Scenarios 5–8: Search is case-insensitive (4 examples)

FR-07 — Max 100 character input
  AC-5 (character limit)
    Scenario 9: Search input enforces 100 character maximum
```

---

## Failure Details

None. All 12 scenarios passed.

---

## Manual-Only Scenarios

None required. All acceptance criteria are covered by automated Playwright BDD tests.

---

## Environment Notes

- **Webserver:** `node node_modules/serve/build/main.js -l 3001 .` (static file server)
- **Browser:** Chromium (headless)
- **API:** Mock data fallback used (no live backend)
- **Node version:** v24.15.0
- **playwright:** 1.62.1
- **playwright-bdd:** 9.2.0
