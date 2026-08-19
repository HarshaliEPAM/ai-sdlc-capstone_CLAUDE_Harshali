# Implementation Plan: Search Books by Title

**Jira Ticket:** KAN-1  
**Requirements:** `.sdlc/requirements.md`  
**Date:** 2026-08-19  

---

## Architecture Overview

The application is a dependency-free, static single-page app — no framework, no build step, no package manager. It follows the same pattern as described in CLAUDE.md:

```
claude/bookstore/
  index.html   — page structure, search bar, results container, book card template
  script.js    — search logic, debounce, API/mock data, DOM rendering
  styles.css   — layout, book cards, search bar, empty state
```

**Data flow:**
1. On load, `fetchBooks()` is called — fetches from `GET /api/books` or falls back to mock data
2. User types in the search bar → 300ms debounce fires → `searchBooks(query)` called
3. `searchBooks()` filters the in-memory book list by title (case-insensitive substring match)
4. `renderResults(books)` updates the DOM — shows cards or empty state message

**API assumption:** Since `GET /api/books?search={query}` may not be available, the implementation will use a local mock dataset and perform client-side filtering, with the API call stubbed and ready to swap in.

---

## Implementation Tasks

---

### TASK-001 — Project Directory Setup

**Description:**  
Create the `claude/bookstore/` directory and empty scaffold files.

**Affected files:**
- `claude/bookstore/index.html` (create)
- `claude/bookstore/script.js` (create)
- `claude/bookstore/styles.css` (create)

**Dependencies:** None

**Expected result:**  
Directory and three empty files exist.

**Acceptance criteria:**  
Opening `claude/bookstore/index.html` in a browser shows a blank page with no console errors.

---

### TASK-002 — HTML Structure (`index.html`)

**Description:**  
Build the page structure: a header with the app title, a search bar section (text input + search icon button), a results container `<div id="results">`, a `<template>` element for the book card, and an empty-state `<div id="empty-state">` (hidden by default).

**Affected files:**
- `claude/bookstore/index.html`

**Dependencies:** TASK-001

**Expected result:**  
Page renders with a visible search input at the top and an empty results area below.

**Key HTML elements:**
```
<input type="text" id="search-input" maxlength="100" placeholder="Search by title..." />
<button id="search-btn" aria-label="Search">🔍</button>
<div id="results"></div>
<div id="empty-state" hidden>No books found matching your search. Try looking up another title!</div>
<template id="book-card-template">
  <!-- img, title, author, price, Add to Cart button -->
</template>
```

**Acceptance criteria:**  
- Search input visible at top of page  
- `maxlength="100"` enforced by the browser (AC-5)  
- Results and empty-state containers present in DOM  

---

### TASK-003 — Mock Book Data

**Description:**  
Define a `MOCK_BOOKS` array in `script.js` with at least 8 sample books. Each entry must contain: `id`, `title`, `author`, `price`, `coverUrl`.

**Affected files:**
- `claude/bookstore/script.js`

**Dependencies:** TASK-001

**Expected result:**  
`MOCK_BOOKS` is a populated array accessible to all functions in the module.

**Sample shape:**
```js
{ id: 1, title: "The Hobbit", author: "J.R.R. Tolkien", price: "$12.99", coverUrl: "https://via.placeholder.com/120x180?text=The+Hobbit" }
```

**Acceptance criteria:**  
Array contains at least 8 books with varied titles to enable meaningful search testing.

---

### TASK-004 — API Fetch with Mock Fallback

**Description:**  
Implement `fetchBooks()` in `script.js`. It attempts `GET /api/books`, catches any network/404 error, and falls back to returning `MOCK_BOOKS`. The returned data is stored in a module-level `allBooks` array.

**Affected files:**
- `claude/bookstore/script.js`

**Dependencies:** TASK-003

**Expected result:**  
`allBooks` is populated on page load, ready for client-side search.

**Acceptance criteria:**  
- Page loads books without console errors  
- If the API is unavailable, mock data is used transparently  

---

### TASK-005 — Debounced Search Logic

**Description:**  
Implement `debounce(fn, delay)` utility and `searchBooks(query)` in `script.js`.

- `debounce` returns a function that delays execution by `delay`ms, resetting the timer on each call (BR-04).
- `searchBooks(query)` filters `allBooks` where `title.toLowerCase().includes(query.toLowerCase())` (BR-01, BR-02).
- Attach a debounced (300ms) `input` event listener to `#search-input`.
- Attach a `click` listener to `#search-btn` that calls `searchBooks` immediately with the current input value (FR-03).
- Attach a `keydown` listener for Enter key on `#search-input` (FR-03).

**Affected files:**
- `claude/bookstore/script.js`

**Dependencies:** TASK-004

**Expected result:**  
Typing in the search bar triggers filtered results after 300ms pause; Enter/button triggers immediately.

**Acceptance criteria:**  
- AC-1: Results filter to titles containing the term  
- AC-4: Case-insensitive ("the hobbit" = "THE HOBBIT")  
- AC-6: API/filter only called 300ms after typing stops  

---

### TASK-006 — DOM Rendering (`renderResults`)

**Description:**  
Implement `renderResults(books)` in `script.js`. It:
1. Clears `#results`
2. If `books.length === 0`, shows `#empty-state` and hides `#results`
3. Otherwise, hides `#empty-state`, clones the `#book-card-template` for each book, populates fields (cover img, title, author, price, "Add to Cart" button), and appends to `#results`

**Affected files:**
- `claude/bookstore/script.js`

**Dependencies:** TASK-005, TASK-002

**Expected result:**  
Search results render as styled cards; empty state message appears when no match found.

**Acceptance criteria:**  
- AC-2: Each card shows cover image, title, author, price, "Add to Cart" button  
- AC-3: Empty state message shown for no-match searches  

---

### TASK-007 — CSS Styling (`styles.css`)

**Description:**  
Style the page with a clean, readable layout:
- Page: max-width container, centered
- Search bar: full-width input + icon button side by side
- Results grid: responsive CSS grid of book cards
- Book card: cover image, title (bold), author (muted), price, "Add to Cart" button
- Empty state: centered, muted text, clearly visible

**Affected files:**
- `claude/bookstore/styles.css`

**Dependencies:** TASK-002

**Expected result:**  
Page is visually clean and usable across common screen widths.

**Acceptance criteria:**  
- NFR-03: Empty state message is clearly visible  
- NFR-04: Consistent card layout for all results  
- Book cards display without overlap or overflow  

---

### TASK-008 — Input Security: Query Encoding

**Description:**  
In the `fetchBooks(query)` function, encode the search query before appending it to the API URL using `encodeURIComponent(query)` to handle special characters (R-03 mitigation).

**Affected files:**
- `claude/bookstore/script.js`

**Dependencies:** TASK-004

**Expected result:**  
Search queries with `&`, `=`, `#`, spaces etc. do not break the API call URL.

**Acceptance criteria:**  
- Searching for `"C++ & Java"` does not produce a malformed URL  

---

## Implementation Order

```
TASK-001 → TASK-002 → TASK-003 → TASK-004 → TASK-005 → TASK-006 → TASK-007 → TASK-008
```

Tasks 002 and 003 can be done in parallel after TASK-001.  
TASK-008 is a patch on TASK-004 and can be applied alongside TASK-005.

---

## Files to Create

| File | Purpose |
|---|---|
| `claude/bookstore/index.html` | Page structure, search bar, results container, card template |
| `claude/bookstore/script.js` | All logic: fetch, debounce, search, render |
| `claude/bookstore/styles.css` | Visual styling |

---

## Files NOT Modified

- No existing files are changed
- No configuration files modified
- No dependencies added

---

## API Changes

None — the `GET /api/books?search={query}` endpoint is consumed but not implemented here. A mock fallback handles its absence.

---

## Database Changes

None — this is a purely frontend feature. Data is fetched from the API or loaded from in-memory mock.

---

## Testing Considerations

| Test | Coverage |
|---|---|
| Search with matching term | AC-1 |
| Search with no matching term | AC-3 |
| Search case-insensitivity | AC-4 |
| Input blocked at 100 characters | AC-5 |
| Rapid typing triggers only one search call | AC-6 |
| Card fields all present in results | AC-2 |
| Special characters in search input | R-03 |

Tests to be handled in the TESTING stage using Playwright BDD.

---

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| API not available | Mock data fallback in TASK-004 |
| Special characters in query | `encodeURIComponent` in TASK-008 |
| Inconsistent card layout | CSS grid + fixed card dimensions in TASK-007 |
