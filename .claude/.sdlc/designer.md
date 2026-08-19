# Technical Design: CS-50

## 1. State Model

### 1.1 New Module-Level Variable

| Variable | Type | Initial Value | Lifecycle |
|---|---|---|---|
| `editingId` | `string \| null` | `null` | Set to a release `id` when `startEditRelease` is called; reset to `null` by `cancelEdit()` (which is called both from the Cancel button and at the end of a successful edit submission). Never persisted to localStorage. Resets to `null` on every page load. |

Declaration placement: after the existing module-level declarations at the top of `script.js`, after the `let releases = loadReleases();` line.

```js
let editingId = null;
```

### 1.2 New Module-Level DOM References

Three new `const` references are added immediately after `editingId`. They are `const` because the element references themselves never change — only their properties are mutated.

| Constant | Type | Selector | Purpose |
|---|---|---|---|
| `cancelEditBtn` | `HTMLButtonElement` | `document.getElementById("cancel-edit")` | Toggle `hidden`; wire `click` handler |
| `createReleaseTitle` | `HTMLHeadingElement` | `document.getElementById("create-release-title")` | Swap text between "Create a Release Note" and "Edit Release Note" |
| `submitBtn` | `HTMLButtonElement` | `releaseForm.querySelector('button[type="submit"]')` | Swap label between "Add Release Note" and "Save Changes" |

### 1.3 Existing State Unchanged

`releases` is already declared as `let releases = loadReleases();` — the `let` is required for `deleteRelease`'s reassignment pattern and is already correct. No change needed. The `STORAGE_KEY`, `saveReleases`, and `loadReleases` functions are unchanged and remain the sole localStorage access points (satisfying NFR-3).

### 1.4 State Transition Diagram

```
                       +-----------+
         Page load     |           |
      ──────────────>  | CREATE    |  editingId = null
                       | MODE      |  form empty
                       |           |  Cancel hidden
                       +-----------+
                         ^       |
           cancelEdit()  |       | startEditRelease(id)
                         |       v
                       +-----------+
                       |           |
                       | EDIT      |  editingId = id
                       | MODE      |  form populated
                       |           |  Cancel visible
                       +-----------+
                             |
                             | submit (editingId !== null)
                             | → update in place → cancelEdit()
                             v
                       (returns to CREATE MODE)
```

---

## 2. DOM Changes

### 2.1 Card Template — Action Buttons

**File:** `claude/product_release_dashboard/index.html`

**Location:** Inside `<template id="release-card-template">`, after `<p class="release-date"></p>` and before `</article>`.

**After:**
```html
<template id="release-card-template">
  <article class="release-card">
    <div class="card-top">
      <p class="product-version"></p>
      <span class="badge"></span>
    </div>
    <h3 class="release-title"></h3>
    <p class="release-description"></p>
    <p class="release-date"></p>
    <div class="card-actions">
      <button type="button" class="btn-edit" aria-label="Edit release">Edit</button>
      <button type="button" class="btn-delete" aria-label="Delete release">Delete</button>
    </div>
  </article>
</template>
```

**Attribute rationale:**

| Attribute | Value | Reason |
|---|---|---|
| `type="button"` | `"button"` | Mandatory. Default button type inside a document that contains a `<form>` is `submit`. Without this, clicking either button would trigger the form's submit event. |
| `class="btn-edit"` | — | Scoped CSS hook; inherits the base accent gradient from the `button` selector; overrides applied for size. |
| `class="btn-delete"` | — | Scoped CSS hook; overrides background to danger gradient. |
| `aria-label="Edit release"` | placeholder | Overwritten per-card in `renderReleaseList()` with a product+version–specific label. |
| `aria-label="Delete release"` | placeholder | Same — overwritten at render time. |

### 2.2 Form — Cancel Button

**File:** `claude/product_release_dashboard/index.html`

**Location:** Inside `<div class="form-actions">`, inserted before the existing `<button type="submit">`.

**After:**
```html
<div class="form-actions">
  <button type="button" id="cancel-edit" class="btn-cancel" hidden>Cancel</button>
  <button type="submit">Add Release Note</button>
</div>
```

| Attribute | Value | Reason |
|---|---|---|
| `type="button"` | `"button"` | Prevents cancel from triggering form submission. |
| `id="cancel-edit"` | — | Unique identifier for the `document.getElementById("cancel-edit")` reference in `script.js`. |
| `class="btn-cancel"` | — | CSS hook for neutral/ghost styling. |
| `hidden` | boolean | Suppresses element from visual layout AND accessibility tree simultaneously. Removed via `cancelEditBtn.hidden = false` when edit mode starts. |

---

## 3. Function Signatures

### 3.1 New Functions

#### `deleteRelease(id)`

```
deleteRelease(id: string): void
```

**Contract:** Removes the release record with the matching `id` from the `releases` array and persists the change. If the form is currently in edit mode for the same record (`editingId === id`), resets the form to create mode first to prevent a ghost-edit scenario. Triggers a re-render.

**Steps:**
1. If `editingId === id`, call `cancelEdit()`.
2. Reassign `releases = releases.filter(r => r.id !== id)`.
3. Call `saveReleases(releases)`.
4. Call `renderReleaseList()`.

---

#### `startEditRelease(id)`

```
startEditRelease(id: string): void
```

**Contract:** Switches the shared form from create mode to edit mode. Populates every form field with the current values of the release record identified by `id`. Updates the form heading, submit button label, and Cancel button visibility. Scrolls the form into view and moves keyboard focus to the first field.

**Steps:**
1. `const release = releases.find(r => r.id === id)` — return early if `undefined`.
2. `editingId = id`.
3. Set `value` / `checked` on all six form fields.
4. `createReleaseTitle.textContent = "Edit Release Note"`.
5. `submitBtn.textContent = "Save Changes"`.
6. `cancelEditBtn.hidden = false`.
7. `releaseForm.scrollIntoView({ behavior: "smooth", block: "nearest" })`.
8. `document.getElementById("product").focus()`.

**Date field note:** `release.releaseDate` is stored as `YYYY-MM-DD` — exactly what `<input type="date">` accepts for its `.value` property. No date conversion needed.

---

#### `cancelEdit()`

```
cancelEdit(): void
```

**Contract:** Resets the form to its default create state. Discards any unsaved edits. Also called internally by the form submit handler after a successful edit save.

**Steps:**
1. `editingId = null`.
2. `releaseForm.reset()`.
3. `createReleaseTitle.textContent = "Create a Release Note"`.
4. `submitBtn.textContent = "Add Release Note"`.
5. `cancelEditBtn.hidden = true`.

**Does NOT call `renderReleaseList()`** — the release list is unchanged by a cancel.

---

### 3.2 Modified Functions

#### `renderReleaseList()` (modified)

Inside the `for (const release of filtered)` loop, after existing badge manipulation and before `releaseList.appendChild(card)`:

```js
const editBtn   = card.querySelector(".btn-edit");
const deleteBtn = card.querySelector(".btn-delete");

editBtn.setAttribute("aria-label",   `Edit ${release.product} ${release.version}`);
deleteBtn.setAttribute("aria-label", `Delete ${release.product} ${release.version}`);

editBtn.addEventListener("click",   () => startEditRelease(release.id));
deleteBtn.addEventListener("click", () => deleteRelease(release.id));
```

Each listener closes over `release.id`. The `releaseList.innerHTML = ""` at the top destroys all previous DOM nodes and their listeners on every render — no listener accumulation.

---

#### `releaseForm submit handler` (modified)

New branching logic after field extraction and validation:

```
if editingId !== null:
    idx = releases.findIndex(r => r.id === editingId)
    if idx !== -1:
        releases[idx] = { ...releases[idx], ...fields }   // preserves id, updates all other fields
    cancelEdit()   // single cleanup path
else:
    release = { id: crypto.randomUUID(), ...fields }
    releases.unshift(release)
    releaseForm.reset()

saveReleases(releases)
renderReleaseList()
```

The `if (idx !== -1)` guard handles the edge case where the record was deleted between clicking Edit and clicking Save.

---

## 4. Data Flow

### 4.1 Delete Flow

```
[User] clicks "Delete" button on a card
         |
         v
deleteRelease(id)
         |
         +──[editingId === id?]──YES──> cancelEdit()
         |
         v
releases = releases.filter(r => r.id !== id)
         |
         v
saveReleases(releases)
         |
         v
localStorage.setItem("releaseNotesDashboard.releases", JSON.stringify(releases))
         |
         v
renderReleaseList()
         |
         v
[DOM] Card absent from list; localStorage updated
```

### 4.2 Edit Flow

```
[User] clicks "Edit" button on a card
         |
         v
startEditRelease(id)
         |
         +── releases.find(r => r.id === id) → release (guard: return early if undefined)
         +── editingId = id
         +── populate form fields
         +── update heading + submit label + show Cancel
         +── scrollIntoView + focus #product
         |
[User] modifies fields → clicks "Save Changes"
         |
         v
releaseForm submit handler
         |
         +── editingId !== null → edit path:
         |     idx = releases.findIndex(r => r.id === editingId)
         |     if idx !== -1: releases[idx] = { ...releases[idx], ...fields }
         |     cancelEdit()
         v
saveReleases(releases) → localStorage → renderReleaseList()
         |
         v
[DOM] Card shows updated values
```

### 4.3 Cancel Flow

```
[User] clicks "Cancel" button
         |
         v
cancelEdit()
         |
         +── editingId = null
         +── releaseForm.reset()
         +── restore heading + button text
         +── cancelEditBtn.hidden = true
         v
[DOM] Form cleared, release list unchanged (no re-render)
```

---

## 5. CSS Design

### 5.1 Existing Design System Tokens Used

| Token | Value | Usage |
|---|---|---|
| `--bg-2` | `#efe6d6` | Cancel button hover background |
| `--text` | `#1c1a14` | Cancel button text color |
| `--accent` | `#0e7a6c` | Edit button inherits from base `button` |
| `--accent-2` | `#2c4f86` | Edit button inherits from base `button` |
| `--danger` | `#c63c1f` | Delete button gradient start |
| `--border` | `#ddd3bf` | Cancel button border |

### 5.2 New CSS Rules (append before `@media` block)

```css
/* ── Card action buttons ── */
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
  min-height: 36px;
  min-width: 60px;
}

/* .btn-edit inherits accent gradient from base button selector */

.btn-delete {
  background: linear-gradient(130deg, var(--danger), #9b3010);
}

/* ── Form cancel button ── */
.btn-cancel {
  background: transparent;
  color: var(--text);
  border: 1px solid var(--border);
  font-weight: 600;
}

.btn-cancel:hover {
  background: var(--bg-2);
  filter: none;
  transform: none;
}
```

**Modification to existing `.form-actions`:** add `gap: 8px`.

**Inside existing `@media (max-width: 760px)` block:**
```css
  .form-actions {
    flex-direction: column;
  }
  .card-actions {
    flex-wrap: wrap;
  }
```

---

## 6. Edge Cases

### 6.1 Page Reload Mid-Edit
`editingId` is not persisted to localStorage. On reload it initialises to `null`; `loadReleases()` returns the original unmodified record. The user's in-progress field edits are lost (expected — draft-saving is out of scope).

### 6.2 Two Edit Attempts on Different Cards
`startEditRelease(B.id)` overwrites `editingId` and form fields from A to B. Draft edits to A are silently discarded; both records remain safe in the array.

### 6.3 Delete Triggered While Same Card Is Being Edited
`deleteRelease` calls `cancelEdit()` first when `editingId === id`, then removes the record. The form resets to create mode before the re-render, preventing any ghost-edit state.

### 6.4 Edit Changes Values So Card No Longer Matches Active Filter (AC-7)
Handled automatically: `renderReleaseList()` re-applies the active filter after save. The card disappears from the view but remains in localStorage.

### 6.5 Delete Within a Filtered View (AC-6)
Handled automatically: `deleteRelease` removes from the full array; `renderReleaseList()` re-filters the remainder.

### 6.6 All Records Deleted
`releases` becomes `[]`; the existing empty-state branch in `renderReleaseList()` fires. Seeded records do not reappear because `loadReleases()` returns the empty array from localStorage.

---

## 7. Accessibility

### 7.1 ARIA Attributes

| Element | Attribute | Value at render time | Purpose |
|---|---|---|---|
| Edit button in card | `aria-label` | `"Edit {product} {version}"` | Identifies which record the action applies to |
| Delete button in card | `aria-label` | `"Delete {product} {version}"` | Same rationale for delete |
| Cancel button | `hidden` (boolean) | removed in edit mode | Removes from visual layout and accessibility tree when not relevant |
| Form section | `aria-labelledby="create-release-title"` | (existing) | Heading text changes to "Edit Release Note" — screen readers re-announce mode change |

### 7.2 Keyboard Interaction Model

| Action | Key | Behaviour |
|---|---|---|
| Tab to Edit button | `Tab` | Natively focusable `<button>` |
| Activate Edit | `Enter` / `Space` | `startEditRelease(id)`; focus moves to `#product` |
| Tab to Delete button | `Tab` | Follows Edit in DOM order |
| Activate Delete | `Enter` / `Space` | `deleteRelease(id)` |
| Tab to Cancel | `Tab` | Only reachable when `hidden` removed (edit mode) |
| Activate Cancel | `Enter` / `Space` | `cancelEdit()` |

### 7.3 Focus Management

`startEditRelease` calls `document.getElementById("product").focus()` after `scrollIntoView`, placing keyboard focus at the first editable field without requiring the user to Tab through the entire page.

### 7.4 Mobile Tap Targets (AC-10)

- Card buttons: `min-height: 36px`, `min-width: 60px`
- `flex-wrap: wrap` on `.card-actions` prevents overflow at 360 px
- Form actions stack vertically with `flex-direction: column`; each button at `width: 100%`

---

## Acceptance Criteria Mapping

| AC | Satisfied by |
|---|---|
| AC-1 | `deleteRelease` → filter + `saveReleases` + `renderReleaseList` |
| AC-2 | `startEditRelease` populates all six fields |
| AC-3 | Submit handler edit path; spread + `saveReleases` + `renderReleaseList` |
| AC-4 | `cancelEdit` via Cancel button; no array mutation |
| AC-5 | Validation guard + HTML5 `required` on required fields |
| AC-6 | Delete on full array; re-filter on render |
| AC-7 | Re-filter on render after edit save |
| AC-8 | `saveReleases` writes reduced array; `loadReleases` reads on reload |
| AC-9 | `saveReleases` writes updated record; `loadReleases` reads on reload |
| AC-10 | `min-height` on card buttons; `flex-direction: column` + `width: 100%` on form actions |