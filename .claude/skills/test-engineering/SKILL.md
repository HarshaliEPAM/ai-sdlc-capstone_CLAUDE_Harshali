---
name: test-engineering
description: Design and execute Playwright BDD tests with Gherkin traceability for this repository.
---

# Test Engineering Skill

## Objective

Validate that the implementation satisfies requirements and acceptance criteria using the repository's Playwright BDD stack.

## Inputs

Read:

.sdlc/requirements.md
.sdlc/plan.md
.sdlc/design.md
.sdlc/implementation-summary.md

Inspect:

- Source code
- Existing tests
- Git diff

## Framework Rules

All automated tests MUST use Playwright BDD in JavaScript for this repository.

### Required Folder Structure

```
product_release_dashboard/tests/
  manual/
    features/
      <feature_name>.feature
  automation/
    step-definitions/
      <feature_name>.steps.js
    support/
      fixtures.js
      page-objects/
        <page>.page.js
```

### Path and Ownership Rules

- Gherkin feature files go in `tests/manual/features/`.
- Step definitions go in `tests/automation/step-definitions/`.
- Shared fixtures and page objects go in `tests/automation/support/`.
- Do not place new test files in legacy paths (`tests/features/`, `tests/step-definitions/`, `tests/support/`).

### Naming Rules

- Feature files: `<feature-name>.feature` (kebab-case)
- Step files: `<feature-name>.steps.js` (kebab-case)
- Page object files: `<subject>.page.js`

## Gherkin Rules

- Every scenario MUST map to one or more requirements or acceptance criteria.
- Every scenario MUST include at least one `@REQ-NNN` tag.
- Scenario titles MUST be descriptive.
- Use `Background` only for shared preconditions used by all scenarios in a feature.
- Use `Scenario Outline` with `Examples` for data-driven coverage.

## Automation Rules

- Keep selectors and UI actions inside page objects.
- Keep step definitions thin and behavior-focused.
- Reuse shared fixtures from `tests/automation/support/fixtures.js`.
- Keep each scenario isolated (clear localStorage/state before scenario start).
- Do not modify production code from this testing stage.

## Coverage Expectations

Cover at least:

- Happy paths per requirement
- Negative/validation paths
- Edge cases and boundary behaviors
- Regression for previously delivered behavior

## Traceability Matrix

Map requirements and ACs to scenarios/tests:

```
REQ-001
  AC-001
    tests/manual/features/release-edit.feature
      Scenario: User edits a release note successfully
```

Include this matrix in `.sdlc/test-report.md`.

## Execute

Run tests from `product_release_dashboard/`:

- `npm test`
- `npm run test:headed` (when visual validation is needed)

Record:

- Exact command(s) run
- Pass/fail/skip counts
- Failure messages
- Scenarios that remain manual only

## Failure Classification

Classify every failure as one of:

IMPLEMENTATION_DEFECT
TEST_DEFECT
ENVIRONMENT_FAILURE
DEPENDENCY_FAILURE

## Rules

1. Never delete failing tests to force a pass.
2. Never bypass failing assertions without documented reason.
3. Keep manual and automation files in the required folder structure.
4. Ensure every added scenario has requirement traceability tags.
5. Keep test changes scoped to the feature under test.

## Output

Create:

.sdlc/test-report.md

Include:

- Test summary (pass/fail/skip)
- Command log (what was run)
- Traceability matrix (REQ -> AC -> scenario)
- Failure details with FAILURE_TYPE
- Remaining manual-only scenarios