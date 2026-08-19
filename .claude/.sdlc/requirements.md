# Requirements: CS-50

## Summary

The Release Notes Dashboard currently supports creating and viewing release notes with client-side filtering. CS-50 extends this MVP to complete the CRUD lifecycle by adding the ability for users to edit an existing release note (correcting any field after submission) and delete a release note that is no longer relevant. All changes must persist to localStorage so the updated or reduced list survives page reloads. No backend, build step, or external dependency should be introduced.

## Functional Requirements

- FR-1: A user must be able to delete any existing release note from the release list. A delete control (button or icon) must be visible on each release card.
- FR-2: When a user triggers delete, the corresponding release record must be removed from the in-memory array and the updated array must be persisted to localStorage under the key `releaseNotesDashboard.releases`.
- FR-3: After deletion the release list must re-render immediately without a page reload, and the deleted card must no longer appear.
- FR-4: A user must be able to edit any existing release note. An edit control must be visible on each release card.
- FR-5: Triggering edit must populate the existing "Create a Release Note" form (or an equivalent inline/modal edit surface) with the current field values of that release: product, version, title, description, releaseDate, and isBreaking.
- FR-6: After the user modifies fields and submits the edit, the corresponding release record in the in-memory array must be updated in place and persisted to localStorage.
- FR-7: After a successful edit, the release list must re-render to reflect the updated values without a page reload.
- FR-8: The edit form must enforce the same validation rules as the create form: product, version, title, description, and releaseDate are required; isBreaking is optional (defaults to false).
- FR-9: Cancelling an in-progress edit must discard all unsaved changes and restore the form to its default empty state.
- FR-10: Delete and edit controls must be present on every release card, regardless of whether the card is a seeded example or a user-created entry.

## Non-Functional Requirements

- NFR-1: No build step, bundler, or external library may be introduced. The solution must remain a static, dependency-free three-file app (index.html, script.js, styles.css).
- NFR-2: All DOM mutations must use the existing template-clone rendering pattern already established in script.js to maintain consistency.
- NFR-3: LocalStorage reads and writes must use the existing STORAGE_KEY constant (`releaseNotesDashboard.releases`) and the existing `saveReleases` / `loadReleases` functions, extended as needed.
- NFR-4: The UI must remain responsive and functional on viewports down to 360 px wide, consistent with the existing mobile media query at 760 px breakpoint.
- NFR-5: Keyboard accessibility: delete and edit controls must be reachable and operable via keyboard (focusable, activatable with Enter/Space).
- NFR-6: Edit and delete operations must complete (re-render included) in under 100 ms on a modern browser with up to 500 release records stored.

## Acceptance Criteria

- AC-1: Given a release card is visible in the release list, when the user clicks the delete button on that card, then the card is removed from the list immediately and the record is absent from `localStorage` on subsequent page load.
- AC-2: Given a release card is visible, when the user clicks the edit button on that card, then the create/edit form is populated with that card's exact field values (product, version, title, description, releaseDate, isBreaking).
- AC-3: Given the form is pre-populated for editing, when the user changes one or more fields and submits, then the release list shows the updated values for that record and localStorage reflects the change.
- AC-4: Given the form is pre-populated for editing, when the user clicks cancel (or equivalent), then the form is cleared, no record is modified, and the release list is unchanged.
- AC-5: Given the form is pre-populated for editing, when the user clears a required field and submits, then the form does not submit, the release record is not modified, and the user sees a validation indicator on the empty required field.
- AC-6: Given a release list filtered by product or breaking-change type, when the user deletes a card that is visible within the filtered view, then only that card is removed and the remaining filtered results are unaffected.
- AC-7: Given a release list filtered by product or breaking-change type, when the user edits a card such that its new values no longer match the active filter, then after saving the card disappears from the filtered view (but remains in localStorage).
- AC-8: Given the page is reloaded after a delete, then the deleted record does not reappear.
- AC-9: Given the page is reloaded after an edit, then the edited record shows the updated values.
- AC-10: Given a user navigates to the page on a mobile viewport (360 px), then the delete and edit controls are visible and tappable on each card without horizontal overflow.

## Out of Scope

- Server-side persistence or any backend API integration.
- User authentication or per-user data isolation.
- Bulk delete or bulk edit operations.
- Undo/redo functionality after delete or edit.
- Sorting release notes by any field.
- Export or import of release data.
- Confirmation dialogs or modals for delete (a simple inline control is acceptable for this iteration).
- Version history or audit trail of edits.
- Search beyond the existing product-name text filter.