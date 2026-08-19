# Technical Design: Search Books by Title

**Jira Ticket:** KAN-1  
**Plan:** `.sdlc/plan.md`  
**Requirements:** `.sdlc/requirements.md`  
**Date:** 2026-08-19  

---

## Overview

A static, dependency-free single-page bookstore application that allows customers to search for books by title. The implementation is three files — HTML, JS, CSS — with no build step, no framework, and no server-side code. Search is performed client-side against an in-memory dataset loaded from the API on startup (with a mock fallback).

---

## Existing Architecture

The repository currently contains no application source files. The CLAUDE.md documents an established pattern used for the product release dashboard:

- **No build tooling** — files are opened directly in the browser
- **No frameworks** — vanilla HTML5, ES6 JavaScript, CSS3
- **`<template>` element pattern** — card elements are defined once in a `<template>` and cloned per data item
- **localStorage / in-memory state** — data is held in a module-level array, not a reactive store
- **Single JS file** — all logic in one `script.js`

The bookstore feature follows this exact pattern.

---

## Proposed Architecture

```
claude/bookstore/
├── index.html     ← page shell, search bar, results container, <template>
├── script.js      ← state, fetch, debounce, search, render
└── styles.css     ← layout, grid, card, empty state
```

### Module structure of `script.js`

```
MOCK_BOOKS[]          — seed data (8+ books)
allBooks[]            — populated from API or MOCK_BOOKS at load time

debounce(fn, delay)   — generic debounce utility
fetchBooks()          — fetch /api/books, fall back to MOCK_BOOKS
searchBooks(query)    — filter allBooks by title (case-insensitive)
renderResults(books)  — clear DOM, clone <template> per book, or show empty state
init()                — wire event listeners, call fetchBooks, render all books
```

---

## Component Changes

| Component | Change | Reason |
|---|---|---|
| `claude/bookstore/index.html` | Create | Page shell with search bar, results area, card template |
| `claude/bookstore/script.js` | Create | All search and rendering logic |
| `claude/bookstore/styles.css` | Create | Visual presentation |

No existing files are modified.

---

## Data Model

### Book record

```js
{
  id:       number,   // unique identifier
  title:    string,   // display title; used for search matching
  author:   string,   // display author name
  price:    string,   // formatted price string, e.g. "$12.99"
  coverUrl: string    // absolute or relative URL to cover image
}
```

### In-memory state

```js
let allBooks = []     // populated once on init; never mutated after load
```

No localStorage, no persistent client state — the list is re-fetched on each page load.

---

## API Design

### Consumed endpoint (external, not implemented here)

```
GET /api/books?search={query}
```

| Parameter | Type | Description |
|---|---|---|
| `search` | string (URL-encoded) | Title substring to filter by |

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "title": "The Hobbit",
    "author": "J.R.R. Tolkien",
    "price": "$12.99",
    "coverUrl": "https://example.com/covers/hobbit.jpg"
  }
]
```

**Error responses handled:**
- Network failure / CORS → fall back to `MOCK_BOOKS`
- 404 / 500 → fall back to `MOCK_BOOKS`

**Note:** The implementation fetches all books once (`GET /api/books` with no query param) and filters client-side. The `?search=` parameter is available for future server-side delegation.

---

## Request Flow

```
Page Load
  └─► init()
        ├─► fetchBooks()
        │     ├─► fetch("/api/books")
        │     │     ├─► [success] allBooks = response JSON
        │     │     └─► [failure] allBooks = MOCK_BOOKS
        │     └─► renderResults(allBooks)   ← shows all books initially

User types in #search-input
  └─► debounce (300ms)
        └─► searchBooks(query)
              ├─► filtered = allBooks.filter(title includes query, case-insensitive)
              └─► renderResults(filtered)

User presses Enter / clicks #search-btn
  └─► searchBooks(#search-input.value)  ← immediate, no debounce
        └─► renderResults(filtered)
```

---

## Error Handling

| Scenario | Handling |
|---|---|
| API unavailable (network error) | `catch` block sets `allBooks = MOCK_BOOKS`; page loads silently |
| API returns non-OK status | Same `catch` block; mock fallback |
| Empty search query | `searchBooks("")` returns all books (shows full catalog) |
| No matching results | `renderResults([])` hides results grid, shows `#empty-state` message |
| Image load failure | `onerror` on `<img>` sets `src` to a placeholder image URL |

No user-visible error messages for API failure — the fallback is transparent.

---

## Authentication & Authorization

None. This is a public-facing read-only catalog page. No login, no session, no tokens required on the frontend. The `GET /api/books` endpoint is assumed to be publicly accessible.

---

## Security

| Concern | Mitigation |
|---|---|
| XSS via search input | All DOM updates use `.textContent` or `.setAttribute()` — never `innerHTML` with user input |
| Query string injection | `encodeURIComponent(query)` applied before building the API URL |
| Input length abuse | `maxlength="100"` on the `<input>` element (browser-enforced + JS guard) |
| External image URLs | Images rendered with `<img src="...">` — no `srcdoc` or `data:` URL execution risk |

No `eval`, no `innerHTML` with dynamic content, no `document.write`.

---

## Logging & Observability

This is a static frontend with no server component.

- **Console warnings only:** API fetch failure logs `console.warn("API unavailable, using mock data")` for developer visibility
- **No analytics / telemetry** in scope for this ticket
- **No error reporting service** (no Sentry, etc.)

---

## Configuration

No configuration files. All tuneable values are constants at the top of `script.js`:

```js
const DEBOUNCE_DELAY_MS = 300;
const MAX_INPUT_LENGTH  = 100;
const API_ENDPOINT      = '/api/books';
```

---

## Database Changes

None. This feature is entirely frontend. No schema changes, no migrations.

---

## Sequence Flow

```
Browser                  script.js              /api/books
   │                        │                        │
   │── DOMContentLoaded ───►│                        │
   │                        │─── fetch(API_ENDPOINT)►│
   │                        │                        │── 200 OK ──────►│
   │                        │◄── JSON array ─────────│
   │                        │  allBooks = response   │
   │                        │  renderResults(all)    │
   │◄── cards rendered ─────│                        │
   │                        │                        │
   │── input event ─────────►│                        │
   │   (debounced 300ms)    │                        │
   │                        │ searchBooks(query)     │
   │                        │ renderResults(filtered)│
   │◄── filtered cards ─────│                        │
```

---

## Design Decisions

### 1. Client-side filtering over server-side search

**Decision:** Fetch all books once on load; filter in-memory on every search.

**Rationale:** The catalog is small (demo/capstone scope). One fetch on load is simpler than a debounced API call per keystroke, avoids CORS complexity, and works even when the API is offline (mock fallback). Server-side search via `?search=` param is stubbed and easy to swap in.

### 2. `<template>` element for card cloning

**Decision:** Define the book card DOM structure once in a `<template id="book-card-template">` and clone it per result.

**Rationale:** Consistent with the established repo pattern (used in the release dashboard). Avoids string-based HTML generation; safer against XSS; easier to maintain layout.

### 3. Mock data fallback (not a loading spinner / error state)

**Decision:** Silently fall back to `MOCK_BOOKS` on API failure rather than showing an error.

**Rationale:** The API endpoint does not exist yet. The user experience must work end-to-end during development. A visible error state would block demonstration of the feature's core functionality.

### 4. "Add to Cart" button is UI-only

**Decision:** The "Add to Cart" button renders but has no click handler.

**Rationale:** OQ-01 is unresolved — cart functionality is explicitly out of scope per the requirements assumptions. The button satisfies AC-2 (it is present) without implementing undefined behavior.

---

## Alternatives Considered

| Alternative | Rejected Because |
|---|---|
| Debounce every keystroke as a live API call | API doesn't exist yet; adds network latency per keystroke unnecessarily |
| React / Vue component | Violates "no framework, no build step" project constraint |
| localStorage caching of results | Unnecessary complexity; catalog is loaded fresh per session |
| Server-side rendered results | No server in scope; static file only |

---

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| API endpoint returns different field names | Medium | Field mapping layer in `fetchBooks()` can normalize the response |
| Cover image URLs are broken/missing | Low | `onerror` fallback to placeholder |
| Large catalog degrades rendering performance | Low | Not in scope for capstone; pagination can be added later |

---

## Open Questions

Carried forward from requirements:

| ID | Question |
|---|---|
| OQ-01 | Is "Add to Cart" button functional? *(Assumed UI-only for this ticket)* |
| OQ-02 | Should search match author name too? *(Assumed title-only per ticket description)* |
| OQ-03 | Maximum results to display? *(No cap implemented; all matches shown)* |
| OQ-04 | Clearing search — show all books or empty? *(Assumed: show all books when input is empty)* |

---

## Acceptance Criteria Mapping

| AC | Satisfied By |
|---|---|
| AC-1: Results filter to matching titles | `searchBooks()` — `title.toLowerCase().includes(query.toLowerCase())` |
| AC-2: Cards show cover, title, author, price, button | `renderResults()` — clones `<template>` with all five fields |
| AC-3: Empty state message | `renderResults([])` — shows `#empty-state`, hides grid |
| AC-4: Case-insensitive search | `.toLowerCase()` on both sides of `includes()` |
| AC-5: Input max 100 chars | `maxlength="100"` on `<input>` + `MAX_INPUT_LENGTH` constant |
| AC-6: 300ms debounce | `debounce(searchBooks, DEBOUNCE_DELAY_MS)` on `input` event |
