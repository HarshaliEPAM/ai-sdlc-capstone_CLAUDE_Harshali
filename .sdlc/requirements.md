# Requirements: Search Books by Title

**Jira Ticket:** KAN-1  
**Type:** Feature  
**Priority:** Medium  
**Status:** Idea (To Do)  
**Date:** 2026-08-19  

---

## 1. Business Objective

Enable bookstore customers to quickly find specific books by searching titles, eliminating the need to scroll through the full catalog.

---

## 2. Users and Actors

| Actor | Description |
|---|---|
| Bookstore Customer | Any visitor on the bookstore homepage who wants to find a book by title |

---

## 3. Functional Requirements

| ID | Requirement |
|---|---|
| FR-01 | The system shall display a text search input field at the top of the homepage |
| FR-02 | The system shall filter the book catalog in real-time as the user types, with a 300ms debounce |
| FR-03 | The system shall also trigger a search when the user presses Enter or clicks a search icon |
| FR-04 | The system shall display matching books showing: cover image, title, author name, price, and an "Add to Cart" button |
| FR-05 | The system shall display the message "No books found matching your search. Try looking up another title!" when no results match |
| FR-06 | The search shall be case-insensitive (e.g., "the hobbit" and "THE HOBBIT" return the same results) |
| FR-07 | The search input field shall accept a maximum of 100 characters |
| FR-08 | The system shall call GET /api/books?search={query} to retrieve matching results |

---

## 4. Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-01 | Search results must update within 300ms of the debounce delay completing |
| NFR-02 | The search input must be accessible via keyboard (Enter key triggers search) |
| NFR-03 | The empty state message must be user-friendly and clearly visible |
| NFR-04 | The UI must display consistent book card layout for all search results |

---

## 5. Business Rules

| ID | Rule |
|---|---|
| BR-01 | Search matches books whose **title contains** the search term (substring match, not exact) |
| BR-02 | Search is case-insensitive |
| BR-03 | Search input is limited to 100 characters |
| BR-04 | A 300ms debounce must be applied to prevent excessive API calls on every keystroke |

---

## 6. Dependencies

| ID | Dependency |
|---|---|
| DEP-01 | Backend API endpoint: `GET /api/books?search={query}` must exist and support title-based filtering |
| DEP-02 | Book data must include: cover image URL, title, author name, and price |

---

## 7. Assumptions

- The bookstore homepage already exists and has a defined layout
- The `GET /api/books?search={query}` API endpoint is implemented and available
- Book cover images are served via URL and can be displayed in an `<img>` tag
- The "Add to Cart" button behavior (cart functionality) is out of scope for this ticket

---

## 8. Risks

| ID | Risk | Mitigation |
|---|---|---|
| R-01 | API endpoint not yet available | Mock data can be used during frontend development |
| R-02 | Large result sets could degrade UI performance | Limit displayed results or paginate the response |
| R-03 | Special characters in search input could break the query string | Encode the search term before appending to the API URL |

---

## 9. Acceptance Criteria

### AC-1: Standard Search Execution

```
Given the user is on the bookstore homepage
When they type a search term in the search bar (e.g., "Harry Potter")
Then the catalog should filter and display only the books whose titles contain that term
```

### AC-2: Clear Search Results

```
Given search results are displayed
Then each result must show:
  - Book Cover Image
  - Book Title
  - Author Name
  - Price
  - "Add to Cart" button
```

### AC-3: Empty State Handling

```
Given the user enters a search term that matches no titles (e.g., "XYZabc123")
When the search is executed
Then the app displays: "No books found matching your search. Try looking up another title!"
```

### AC-4: Case-Insensitivity

```
Given a user searches for "the hobbit" or "THE HOBBIT"
Then both searches return the exact same matching results
```

### AC-5: Input Character Limit

```
Given the search input field
When the user attempts to type more than 100 characters
Then the input should not accept characters beyond the 100-character limit
```

### AC-6: Debounce Behavior

```
Given a user is typing in the search bar
When they type rapidly
Then the API should only be called 300ms after the user stops typing
```

---

## 10. Open Questions

| ID | Question | Owner |
|---|---|---|
| OQ-01 | Is "Add to Cart" button functional in this ticket or just UI-only? | Product Owner |
| OQ-02 | Should search also match by author name, or title only? | Product Owner |
| OQ-03 | Is there a maximum number of results to display per search? | Product Owner |
| OQ-04 | What should happen when the search input is cleared — show all books or show nothing? | Product Owner |
