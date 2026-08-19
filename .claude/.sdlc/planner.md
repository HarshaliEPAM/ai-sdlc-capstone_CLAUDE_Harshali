# Implementation Plan: CS-50

## Overview

Extend the Release Notes Dashboard with full edit and delete capabilities to complete the CRUD lifecycle. The approach stays entirely within the existing three-file, dependency-free architecture. Each release card gains two action buttons (Edit, Delete) rendered via the existing `<template>` clone pattern. A module-level `editingId` variable tracks whether the shared create/edit form is in create or edit mode. No new files, no new libraries, no build step is introduced.

---

## Files to Modify

- `claude/product_release_dashboard/index.html` — add Edit and Delete buttons inside the card `<template>`; add a hidden Cancel button to the form's `.form-actions` row.
- `claude/product_release_dashboard/script.js` — add `editingId` state, `deleteRelease()`, `startEditRelease()`, and `cancelEdit()` functions; update `renderReleaseList()` to wire button handlers; update the form submit handler to handle edit mode.
- `claude/product_release_dashboard/styles.css` — add styles for `.card-actions`, `.btn-edit`, `.btn-delete`, `.btn-cancel`; extend mobile media query to cover the new Cancel button.

---

## Implementation Steps

### Step 1: Add action buttons to the release card template

**File:** `claude/product_release_dashboard/index.html`

**What:** Append a `.card-actions` container holding an Edit button and a Delete button as the last child of the `<article class="release-card">` element inside the `<template id="release-card-template">`.

**How:**
- Insert after `<p class="release-date"></p>` and before the closing `</article>`:
  ```html
  <div class="card-actions">
    <button type="button" class="btn-edit" aria-label="Edit release">Edit</button>
    <button type="button" class="btn-delete" aria-label="Delete release">Delete</button>
  </div>
  ```
- `type="button"` is required on both to prevent accidental form submission because the template is inside the same document that contains the form.
- `aria-label` values will be overwritten with specific text in Step 4 during rendering.

---

### Step 2: Add a Cancel button to the form actions

**File:** `claude/product_release_dashboard/index.html`

**What:** Insert a Cancel button into `.form-actions` that is hidden by default and only revealed when the form enters edit mode.

**How:**
- Inside `<div class="form-actions">`, insert before the existing submit button:
  ```html
  <button type="button" id="cancel-edit" class="btn-cancel" hidden>Cancel</button>
  ```
- The `hidden` HTML attribute suppresses the element from layout and from assistive technologies until removed by JS (Step 7).

---

### Step 3: Add CSS for card action buttons and Cancel button

**File:** `claude/product_release_dashboard/styles.css`

**What:** Style `.card-actions`, `.btn-edit`, `.btn-delete`, and `.btn-cancel`. Extend the existing `@media (max-width: 760px)` block for the Cancel button.

**How:**

Append to the end of the file (before the media query):
```css
.card-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.btn-edit,
.btn-delete {
  padding: 6px 12px;
  font-size: 0.82rem;
  font-weight: 600;
  border-radius: 8px;
  min-height: 36px;      /* tappable on mobile */
  min-width: 60px;
}

.btn-delete {
  background: linear-gradient(130deg, var(--danger), #9b3010);
}

.btn-cancel {
  background: transparent;
  color: var(--muted);
  border: 1px solid var(--border);
  color: var(--text);
}

.btn-cancel:hover {
  background: var(--bg-2);
  filter: none;
  transform: none;
}
```

Inside the existing `@media (max-width: 760px)` block, add:
```css
  .form-actions .btn-cancel {
    width: 100%;
  }
```

Also add `gap: 8px` to the `.form-actions` rule (outside the media query) so the Cancel and Submit buttons have spacing between them.

---

### Step 4: Update `renderReleaseList()` to wire Edit and Delete handlers

**File:** `claude/product_release_dashboard/script.js`

**What:** After cloning each card from the template, set a descriptive `aria-label` on each action button and attach click event listeners that call `deleteRelease` and `startEditRelease` with the release's `id`.

**How:**

Inside the `for (const release of filtered)` loop in `renderReleaseList()`, after the existing `badge` manipulation and before `releaseList.appendChild(card)`, add:

```js
const editBtn = card.querySelector(".btn-edit");
const deleteBtn = card.querySelector(".btn-delete");

editBtn.setAttribute("aria-label", `Edit ${release.product} ${release.version}`);
deleteBtn.setAttribute("aria-label", `Delete ${release.product} ${release.version}`);

editBtn.addEventListener("click", () => startEditRelease(release.id));
deleteBtn.addEventListener("click", () => deleteRelease(release.id));
```

Each event listener closes over `release.id` from the loop iteration. Because `releaseList.innerHTML = ""` is called at the top of every render, old listeners are garbage-collected automatically — no listener accumulation.

---

### Step 5: Implement the `deleteRelease(id)` function

**File:** `claude/product_release_dashboard/script.js`

**What:** Remove the matching record from the in-memory `releases` array, persist the updated array, and re-render.

**How:**

Add the following function (can be placed after `saveReleases`):

```js
function deleteRelease(id) {
  releases = releases.filter(r => r.id !== id);
  saveReleases(releases);
  renderReleaseList();
}
```

`releases` must be declared with `let` (already the case: `let releases = loadReleases();`) so the reassignment is valid.

---

### Step 6: Add module-level edit-mode state and DOM references

**File:** `claude/product_release_dashboard/script.js`

**What:** Introduce one tracking variable and three new element references needed for edit mode.

**How:**

After the existing constant/variable declarations at the top of the file, add:

```js
const cancelEditBtn = document.getElementById("cancel-edit");
const createReleaseTitle = document.getElementById("create-release-title");
const submitBtn = releaseForm.querySelector('button[type="submit"]');

let editingId = null;
```

`editingId` holds the `id` string of the record being edited, or `null` when the form is in create mode.

---

### Step 7: Implement `startEditRelease(id)` function

**File:** `claude/product_release_dashboard/script.js`

**What:** Populate every form field with the current values of the target release, switch the form into edit mode (update heading and button label, reveal Cancel button), and scroll the form into view.

**How:**

```js
function startEditRelease(id) {
  const release = releases.find(r => r.id === id);
  if (!release) return;

  editingId = id;

  document.getElementById("product").value = release.product;
  document.getElementById("version").value = release.version;
  document.getElementById("title").value = release.title;
  document.getElementById("description").value = release.description;
  document.getElementById("releaseDate").value = release.releaseDate;
  document.getElementById("breaking").checked = release.isBreaking;

  createReleaseTitle.textContent = "Edit Release Note";
  submitBtn.textContent = "Save Changes";
  cancelEditBtn.hidden = false;

  releaseForm.scrollIntoView({ behavior: "smooth", block: "nearest" });
}
```

`release.releaseDate` is already in `YYYY-MM-DD` format (as stored), which is exactly what `<input type="date">` requires for its `value` attribute.

---

### Step 8: Implement `cancelEdit()` function and wire Cancel button

**File:** `claude/product_release_dashboard/script.js`

**What:** Discard in-progress edit, reset the form to empty, restore heading and button label, hide the Cancel button.

**How:**

```js
function cancelEdit() {
  editingId = null;
  releaseForm.reset();
  createReleaseTitle.textContent = "Create a Release Note";
  submitBtn.textContent = "Add Release Note";
  cancelEditBtn.hidden = true;
}

cancelEditBtn.addEventListener("click", cancelEdit);
```

The `addEventListener` call should be placed after the `cancelEdit` function definition. `releaseForm.reset()` clears all inputs and unchecks the checkbox, matching the existing behavior after a successful create.

---

### Step 9: Update the form submit handler to support edit mode

**File:** `claude/product_release_dashboard/script.js`

**What:** When `editingId` is set, update the matching record in place instead of prepending a new one. After either path, persist and re-render. Reset form state after edit.

**How:**

Replace the body of the existing `releaseForm.addEventListener("submit", ...)` handler with:

```js
releaseForm.addEventListener("submit", (event) => {
  event.preventDefault();

  const formData = new FormData(releaseForm);
  const fields = {
    product:     String(formData.get("product")     || "").trim(),
    version:     String(formData.get("version")     || "").trim(),
    title:       String(formData.get("title")       || "").trim(),
    description: String(formData.get("description") || "").trim(),
    releaseDate: String(formData.get("releaseDate") || ""),
    isBreaking:  formData.get("breaking") === "on"
  };

  if (!fields.product || !fields.version || !fields.title || !fields.description || !fields.releaseDate) {
    return;   // HTML5 required validation already shows indicators; this is the guard
  }

  if (editingId !== null) {
    const idx = releases.findIndex(r => r.id === editingId);
    if (idx !== -1) {
      releases[idx] = { ...releases[idx], ...fields };  // preserve id, update all other fields
    }
    cancelEdit();   // resets editingId, form, heading, button label, hides Cancel
  } else {
    const release = { id: crypto.randomUUID(), ...fields };
    releases.unshift(release);
    releaseForm.reset();
  }

  saveReleases(releases);
  renderReleaseList();
});
```

Key detail: `{ ...releases[idx], ...fields }` preserves the original `id` while overwriting every user-editable field. `cancelEdit()` is reused for all post-edit cleanup so there is a single code path for restoring form state.

---

## Task Summary

| Task ID  | Description                                           | File(s)       | Depends On      |
|----------|-------------------------------------------------------|---------------|-----------------|
| TASK-001 | Add Edit/Delete buttons to card `<template>`          | index.html    | —               |
| TASK-002 | Add hidden Cancel button to `.form-actions`           | index.html    | —               |
| TASK-003 | Style `.card-actions`, `.btn-edit`, `.btn-delete`, `.btn-cancel` | styles.css | TASK-001, TASK-002 |
| TASK-004 | Wire Edit/Delete button handlers in `renderReleaseList()` | script.js | TASK-001        |
| TASK-005 | Implement `deleteRelease(id)`                         | script.js     | TASK-004        |
| TASK-006 | Add `editingId` state and new DOM references          | script.js     | TASK-002        |
| TASK-007 | Implement `startEditRelease(id)`                      | script.js     | TASK-006        |
| TASK-008 | Implement `cancelEdit()` and wire Cancel button       | script.js     | TASK-006, TASK-007 |
| TASK-009 | Update form submit handler for edit mode              | script.js     | TASK-007, TASK-008 |

**Implementation order:** TASK-001 → TASK-002 → TASK-003 → TASK-006 → TASK-004 → TASK-005 → TASK-007 → TASK-008 → TASK-009

---

## API Changes

None. This is a purely client-side, localStorage-backed application with no network API.

## Database / Storage Changes

No schema changes. The existing localStorage key `releaseNotesDashboard.releases` and record shape `{ id, product, version, title, description, releaseDate, isBreaking }` are unchanged. Delete reduces the stored array; edit updates a record in place. Both operations use the existing `saveReleases()` function.

## Configuration Changes

None.

---

## Risk and Considerations

- **Template button type:** Omitting `type="button"` would default to `type="submit"`, which would fire the form's submit event. Explicitly setting `type="button"` is mandatory (Step 1).
- **Listener accumulation:** `renderReleaseList()` sets `releaseList.innerHTML = ""` before each render, destroying all existing DOM nodes and their attached listeners. No manual cleanup is needed, but this relies on that line remaining at the top of the function.
- **Date field format:** `<input type="date">` expects `YYYY-MM-DD` for its `value` property. `release.releaseDate` is stored in that format from initial creation, so round-tripping through the edit form is safe.
- **Edit-then-filter interaction (AC-7):** After a successful edit, `renderReleaseList()` is called, which re-applies the active filter. If the edited record no longer matches, it disappears from the view — this is the correct behavior per the requirements and is handled automatically by the existing filter logic.
- **Concurrent edit (edge case):** If a user begins editing record A, then clicks Edit on record B without cancelling, `startEditRelease(B.id)` will overwrite the form and update `editingId`. This is acceptable since no confirmation is required and both records remain intact in the array until a submit or cancel action.
- **Mobile tappability:** The `min-height: 36px` on `.btn-edit`/`.btn-delete` and the existing card `padding: 12px` satisfy the 360 px viewport requirement (AC-10). The Cancel button inherits `width: 100%` on mobile via the media query addition.
- **Accessibility:** `hidden` attribute (not `display:none` CSS) is used for the Cancel button so it is also removed from the accessibility tree when not needed. The `aria-label` on each action button is overwritten with a product-specific value during render so screen readers announce which release is being acted on.

---

## Definition of Done

- [ ] Each release card shows both an Edit button and a Delete button, including seeded example cards.
- [ ] Clicking Delete removes the card from the list immediately; the record is absent after page reload (AC-1, AC-8).
- [ ] Clicking Edit populates all six form fields with the card's exact current values (AC-2).
- [ ] Submitting an edit updates the card in the list and in localStorage; the updated values persist after reload (AC-3, AC-9).
- [ ] Clicking Cancel clears the form, discards changes, and leaves the release list unchanged (AC-4).
- [ ] Submitting an edit with a required field empty does not save and shows a validation indicator (AC-5, FR-8).
- [ ] Deleting a card visible under an active filter removes only that card; other filtered results are unaffected (AC-6).
- [ ] Editing a card so its values no longer match the active filter causes it to disappear from the filtered view after save (AC-7).
- [ ] Delete and Edit controls are reachable and operable by keyboard (Tab to focus, Enter/Space to activate) (NFR-5).
- [ ] No `<script src>`, CDN link, npm package, or build step has been introduced (NFR-1).
- [ ] All DOM mutations inside `renderReleaseList()` continue to use the `template.content.firstElementChild.cloneNode(true)` pattern (NFR-2).
- [ ] `saveReleases` and `loadReleases` with `STORAGE_KEY` are the only localStorage access points (NFR-3).
- [ ] Layout is intact and controls are tappable at 360 px viewport width (NFR-4, AC-10).