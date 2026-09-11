# capston_claude — AI-Assisted SDLC Report

**Project:** capston_claude — Bookstore Search Feature

**Programme:** EPAM AI Polyglot Programme · Q3 2026 Capstone

**Date:** 2026-08-19

**Model versions used:** Claude Sonnet 4.6 (all pipeline stages)

---

## 1. Project Overview

capston_claude is a static single-page bookstore application. The feature delivered under this report — **Search Books by Title (KAN-1)** — adds real-time title search to the bookstore homepage: a debounced search input, client-side filtering against a mock catalog, a book-card grid, and an empty-state message. The entire feature — from requirements through pull request — was produced by an AI-SDLC pipeline with Claude as the primary engineering agent.

### Application capabilities

- Display a full book catalog on load with cover image, title, author, price, and Add to Cart button
- Filter the catalog in real-time as the user types, with a 300 ms debounce
- Trigger search immediately on Enter key press or search button click
- Show an empty-state message when no titles match the query
- Case-insensitive substring matching (e.g. "hobbit" and "HOBBIT" return the same results)
- Input capped at 100 characters, enforced both by the browser attribute and defensively in code
- Mock data fallback when the API endpoint is unavailable

### Technology stack

| Layer | Technology |
|---|---|
| Runtime language | JavaScript (ES6, no transpilation) |
| Page structure | HTML5 (`<template>` element pattern for card cloning) |
| Styling | CSS3 (Grid, custom properties, responsive breakpoint at 480 px) |
| Search logic | Vanilla JS — `debounce`, `fetchBooks`, `searchBooks`, `renderResults`, `init` |
| Testing framework | Playwright BDD v9.2.0 + playwright-bdd (Gherkin feature files) |
| Test runner | `node_modules/.bin/bddgen` → `npx playwright test` |
| Static server (tests) | `serve` v14.2.3 on port 3001 |
| Dependency management | npm |
| Build step | None — `index.html` opens directly in any browser |

---

## 2. How Claude Was Used

Claude Code (the CLI) served as the execution engine for the entire software development lifecycle. Rather than using Claude as a chat assistant that produces code for a human to copy and paste, this project wired Claude into a fully automated pipeline: Claude agents read the Jira ticket, wrote requirements, planned implementation tasks, designed the architecture, implemented the feature with tests, ran QA, performed code review, and opened the merge request — with a human acting as approver at each stage gate, not as an author.

This pattern is the **AI-SDLC**: every artifact (requirements doc, plan, design doc, implementation, test report, code review, delivery report) is produced by a named Claude agent executing a dedicated skill, orchestrated by the `/sdlc` slash command with a conductor agent driving the pipeline.

### Pipeline stages and Claude's role in each

```
Jira ticket (KAN-1)
      │
      ▼
[requirement-agent]   → .sdlc/requirements.md
      │
      ▼
[planning agent]      → .sdlc/plan.md
      │
      ▼
[design-agent]        → .sdlc/design.md
      │
      ▼
[implementation]      → claude/bookstore/{index.html, script.js, styles.css}
      │                  + test scaffold
      │
      ▼
[tests agent]         → .sdlc/test-report.md  (12/12 PASS)
      │
      ▼
[code-review-agent]   → .sdlc/code-review.md  (APPROVED)
      │
      ▼
[delivery agent]      → feature branch + commit + push + GitHub PR
```

Claude acted as every role in this pipeline. No human wrote application code.

---

## 3. Agents — Seven Specialized Roles

Seven custom agent definitions live in `.claude/agents/`. They form the gated `/sdlc` pipeline sequence in numbered order. Each agent has a scoped tool set, a dedicated skill it loads, and a system prompt assigning it a single well-defined responsibility.

### 3.1 requirement-agent

**File:** `.claude/agents/1. requirements-analyst.md`
**Model:** Claude Sonnet 4.6
**Tools:** Read, Glob, Grep
**Skill used:** `requirement-analysis`

Reads the Jira ticket and distils it into a structured requirements document at `.sdlc/requirements.md`. Identifies business objectives, actors, functional and non-functional requirements, business rules, acceptance criteria, assumptions, risks, and open questions. For KAN-1 it produced 8 functional requirements (FR-01–FR-08), 4 non-functional requirements, 4 business rules, and 6 acceptance criteria (AC-1–AC-6).

### 3.2 planning agent

**File:** `.claude/agents/2. planning.md`
**Model:** Claude Sonnet 4.6
**Tools:** All tools
**Skill used:** `implementation-planning`

Reads `.sdlc/requirements.md` and the existing repository, then produces `.sdlc/plan.md` — a task-by-task breakdown with affected files, dependencies, expected results, and acceptance criteria per task. Explicitly forbidden from writing any application code. For KAN-1 it decomposed the feature into 5 ordered tasks (TASK-001 through TASK-005).

### 3.3 design-agent

**File:** `.claude/agents/3. design-architecture.md`
**Model:** Claude Sonnet 4.6
**Tools:** Read, Glob, Grep

Reads both requirements and plan documents, inspects the existing repository, and produces `.sdlc/design.md` covering: existing architecture, proposed changes, component interactions, data model, API design, request flow, error handling, security, and explicit design decisions. For KAN-1 the key decisions documented were client-side filtering over server-side search (given the static SPA constraint), the `<template>` clone pattern for XSS-safe card rendering, and the mock data fallback strategy.

### 3.4 implementation agent

**File:** `.claude/agents/4. code-development.md`
**Model:** Claude Sonnet 4.6
**Tools:** All tools
**Skills preloaded:** `coding-standards`, `test-engineering`

The primary build agent. Reads requirements, plan, and design; inspects the repository; implements the feature; and writes a summary to `.sdlc/implementation-summary.md`. Preloaded convention skills enforce consistent patterns: DOM updates via `.textContent`/`.setAttribute` (no innerHTML with user data), `debounce` utility, `MOCK_BOOKS` fallback array, `<template>` clone pattern, and `@REQ-` tagged Gherkin scenarios. On retry (post-review or post-test failure), also reads `.sdlc/test-report.md` and `.sdlc/code-review.md` and addresses every finding before re-running.

### 3.5 tests agent

**File:** `.claude/agents/6. test-generator.md`
**Model:** Claude Sonnet 4.6
**Tools:** All tools
**Skill used:** `test-engineering`

QA automation specialist. Reads all SDLC artifacts, maps requirements to scenarios, inspects existing coverage, writes missing tests, executes the full suite, and writes `.sdlc/test-report.md`. All scenarios must carry `@REQ-NNN` tags and be placed in the required folder structure. Forbidden from modifying production code or deleting failing tests. For KAN-1 it ran 12 Playwright BDD scenarios (9 Gherkin scenarios, 4 expanded from a `Scenario Outline`) and recorded 12/12 PASS.

### 3.6 code-review-agent

**File:** `.claude/agents/5. code-reviewer.md`
**Model:** Claude Sonnet 4.6
**Tools:** Read, Glob, Grep, Bash

Independent principal-engineer-level reviewer. Reads all SDLC artifacts and the git diff; reviews across six areas (requirements, design, code quality, security, testing, performance); classifies every finding with a severity (CRITICAL / HIGH / MEDIUM / LOW); and writes `.sdlc/code-review.md`. CRITICAL or HIGH findings block approval. Forbidden from modifying source or tests. For KAN-1 the reviewer found zero CRITICAL/HIGH issues and returned **APPROVED** with one MEDIUM and four LOW findings documented.

### 3.7 delivery agent (pr-creator)

**File:** `.claude/agents/7. pr-creator.md`
**Model:** Claude Sonnet 4.6
**Tools:** All tools
**Skill used:** `git-delivery`

The pipeline exit agent. Verifies the SDLC gate (`workflow-state.json` all stages COMPLETED), inspects the working tree, creates the feature branch, stages only relevant files, commits with a Conventional Commits message, pushes to the remote, creates a pull request (via `post-checks.ps1` GitHub API call on Stop), and writes `docs/delivery-report.md`. Hard rules: no secrets in commits, no force-push, no Claude attribution trailers.

---

## 4. Skills — Five Reusable Instruction Packages

Skills are Markdown files loaded as system-prompt extensions. They encode domain expertise that multiple agents share.

### 4.1 requirement-analysis

**File:** `.claude/skills/requirement-analysis/SKILL.md`
**Used by:** requirement-agent

A ten-step process for converting a business request into implementation-ready requirements: business objective → actors → functional requirements → non-functional requirements → business rules → dependencies → assumptions → risks → acceptance criteria → open questions. Every requirement must be specific, testable, unambiguous, traceable, and feasible. Acceptance criteria use Given/When/Then format where appropriate.

### 4.2 implementation-planning

**File:** `.claude/skills/implementation-planning/SKILL.md`
**Used by:** planning agent

Instructs the planner to analyse existing architecture, existing modules, existing patterns, and existing tests before creating tasks. Each task must include a task ID, description, affected files, dependencies, expected result, and acceptance criteria. Explicitly forbidden from generating code or modifying source files. Ensures the plan considers API changes, configuration, testing, migration, backward compatibility, and security.

### 4.3 coding-standards

**File:** `.claude/skills/coding-standards/SKILL.md`
**Used by:** implementation agent

Enforces consistent patterns for all application code: inspect the repository before writing a line; make the smallest change necessary; follow existing conventions; never hardcode credentials; write meaningful errors that do not leak sensitive information; add or update tests for every changed behaviour covering happy path, invalid input, edge cases, and error handling. Never claim validation passed without actually running it.

### 4.4 test-engineering

**File:** `.claude/skills/test-engineering/SKILL.md`
**Used by:** tests agent, implementation agent

Mandates Playwright BDD (playwright-bdd) for all automated tests in this repository. Defines the required folder structure (`tests/manual/features/`, `tests/automation/step-definitions/`, `tests/automation/support/`), naming conventions (kebab-case feature files, `.steps.js` step files, `.page.js` page objects), and Gherkin rules (every scenario tagged `@REQ-NNN`, descriptive titles, `Scenario Outline` for data-driven cases). Covers four failure classification types: IMPLEMENTATION_DEFECT, TEST_DEFECT, ENVIRONMENT_FAILURE, DEPENDENCY_FAILURE. Requires a traceability matrix in the test report.

### 4.5 git-delivery

**File:** `.claude/skills/git-delivery/SKILL.md`
**Used by:** delivery agent

Delivery only after all six stages are COMPLETED. Defines the branch naming convention (`feature/<short-description>`), commit discipline (Conventional Commits, no secrets, no unrelated files), push rules (no force-push), and PR creation. Produces `docs/delivery-report.md` with branch, commit hash, remote, push result, and PR URL.

---

## 5. Hooks — Automated Quality Gates

Two shell hook scripts in `.claude/hooks/` run automatically in response to Claude tool calls. They are wired in `.claude/settings.json` and require no human action.

### 5.1 pre-checks.ps1 — SDLC Gate on Every Bash Call

**Trigger:** `PreToolUse` — fires before every `Bash` tool call
**Matcher:** `Bash` only (Read/Write/Edit calls pass through without gating)

```
Claude calls Bash tool
       │
       ▼
pre-checks.ps1 reads .sdlc/workflow-state.json
       │
       ├── File missing?
       │       └── permissionDecision: "deny"  (blocks all git commands)
       └── File present?
               └── All 6 stages = "COMPLETED"?
                       ├── No  → permissionDecision: "deny"  (lists pending stages)
                       └── Yes → permissionDecision: "defer"  (allows call)
```

**Required stages:** REQUIREMENT, PLANNING, DESIGN, IMPLEMENTATION, TESTING, CODE_REVIEW

**Key design decision:** scoped to `Bash` tool only via the `matcher` field in `settings.json`. This avoids the chicken-and-egg problem where the hook would block the Write call needed to create `workflow-state.json`. File operations (Read, Write, Edit) are never gated — only shell/git commands are.

### 5.2 post-checks.ps1 — Auto PR Creation on Stop

**Trigger:** `Stop` — fires at the end of every Claude turn

```
Claude turn ends
       │
       ▼
post-checks.ps1
       │
       ├── On main/master/develop? → skip (no PR on primary branches)
       ├── No GitHub token?        → skip with warning
       └── On feature branch?
               │
               ├── git push -u origin <branch>
               ├── Check existing open PR for this branch
               │       └── Exists? → log URL, skip creation
               └── No PR yet?
                       └── POST /repos/:owner/:repo/pulls
                               → logs PR URL on success
       │
       ▼
permissionDecision: "defer"
```

**Token resolution:** reads `GITHUB_PAT` from `.claude/.env`. **Owner/repo derivation:** extracted dynamically from `git remote get-url origin` — no hardcoded repo identifiers. Idempotent: running multiple times on the same branch does not create duplicate PRs.

**Combined effect:** every delivery turn automatically pushes the branch and creates the GitHub PR without any manual `gh` CLI commands.

---

## 6. Settings and Permissions

### `.claude/settings.json` — Project-Level Hook Wiring

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "bash .claude/hooks/pre-checks.ps1" }]
    }],
    "Stop": [{
      "hooks": [{ "type": "command", "command": "bash .claude/hooks/post-checks.ps1" }]
    }]
  }
}
```

Committed to source control — applies to all collaborators. No per-developer overrides required.

---

## 7. Pipeline State — Cross-Session Gate File

`.sdlc/workflow-state.json` is the durable record of where the pipeline stands. Its schema:

```json
{
  "REQUIREMENT": "COMPLETED",
  "PLANNING": "COMPLETED",
  "DESIGN": "COMPLETED",
  "IMPLEMENTATION": "COMPLETED",
  "TESTING": "COMPLETED",
  "CODE_REVIEW": "COMPLETED"
}
```

The pre-check hook reads this file before every Bash call. The delivery agent creates or updates it as its first action before any git operation, ensuring the gate is satisfied before branch/commit/push commands are issued.

---

## 8. STLC — Software Testing Life Cycle

Testing is distributed across the pipeline's agents, each owning one STLC phase. No test was written or run by a human.

### Requirement analysis → test planning

Owned by the **planning agent**. Each task's `acceptance_criteria` field is the test plan for that unit of work — observable, testable statements derived from `.sdlc/requirements.md`. Nothing is implemented without a corresponding criterion to test against.

### Test case design

Owned by the **implementation agent** and **tests agent**, following `test-engineering` skill rules. Gherkin scenarios are written from acceptance criteria and must carry `@REQ-NNN` traceability tags. `Scenario Outline` with `Examples` is used for data-driven coverage (case-insensitivity was validated with four distinct input examples).

### Test environment setup

The suite is hermetic — no shared infrastructure:
- Playwright BDD drives a real Chromium browser against a static file server (`serve` on port 3001)
- `playwright.config.js` spins the server up automatically via `webServer` before any test runs
- Each scenario calls `page.evaluate(() => localStorage.clear())` for state isolation

### Test execution

Two layers:
1. **tests agent** runs `node_modules/.bin/bddgen` then `npx playwright test` and records results in `.sdlc/test-report.md`
2. **code-review-agent** independently inspects the test files and verifies coverage against all acceptance criteria

### Defect management

The **code-review-agent** is the per-feature defect gate. A `CHANGES_REQUESTED` decision with CRITICAL/HIGH findings sends the pipeline back to the implementation agent with numbered, actionable findings. The implementation agent must address every finding and re-run validation before re-submitting.

### Test cycle closure

The `APPROVED` decision from the code-review-agent is the sign-off gate. No delivery proceeds without it. The review report is included by reference in the delivery report.

### Result for KAN-1

12 automated scenarios, 12/12 PASS, zero CRITICAL/HIGH review findings, zero retries. Every scenario traces back to an acceptance criterion (AC-1–AC-6) which traces back to a functional requirement (FR-01–FR-08) in `.sdlc/requirements.md`.

---

## 9. Key Technical Decisions

The following design decisions were made by Claude agents and are recorded in `.sdlc/design.md` and `.sdlc/code-review.md`.

### Client-side filtering over server-side search

`GET /api/books?search={query}` is specified in FR-08, but the capstone runs with no live API. The implementation fetches `GET /api/books` (mock fallback on failure), stores the result in `allBooks`, and filters entirely client-side with a case-insensitive `includes()` check. The `?search=` parameter pathway is architecturally stubbed and ready to activate. Documented as a design decision in `design.md`; flagged MEDIUM (FINDING-001) in code review.

### `<template>` element for card rendering

Book cards are cloned from a `<template id="book-card-template">` element rather than constructed via `innerHTML`. All field values are written with `.textContent` or `.setAttribute()`. This eliminates any XSS vector from API-returned or mock data, consistent with the existing repository pattern in `product_release_dashboard`.

### `debounce` utility — 300 ms delay

`debounce(searchBooks, DEBOUNCE_DELAY_MS)` is wired to the `input` event. The Enter key and search button bypass the debounce and call `searchBooks` immediately, satisfying FR-03 while preventing excessive calls on each keystroke (BR-04).

### Defensive input truncation

`searchBooks()` calls `.trim().slice(0, MAX_INPUT_LENGTH)` on the query before filtering. This guards against programmatic bypass of the `maxlength="100"` HTML attribute, satisfying BR-03 at two independent layers.

### `img.onerror` placeholder fallback

Each rendered book card registers an `onerror` handler on the cover image element to swap in a placeholder URL. The code-review agent flagged this as LOW (FINDING-002) because the placeholder URL itself is not validated — acceptable for a capstone-scoped static app.

---

## 10. Task Breakdown — 5 Tasks

All 5 tasks delivered and passed review.

| Task | Title | Affected Files |
|---|---|---|
| TASK-001 | Project directory setup | `claude/bookstore/` scaffold |
| TASK-002 | HTML structure | `index.html` — search bar, results container, card template, empty state |
| TASK-003 | JavaScript logic | `script.js` — debounce, fetch, search, render, init |
| TASK-004 | CSS styling | `styles.css` — grid layout, card styles, search bar, empty state, responsive |
| TASK-005 | Playwright BDD test suite | `package.json`, `playwright.config.js`, feature file, step definitions, fixtures, page object |

---

## 11. Code Review Findings

The code-review-agent returned **APPROVED**. All findings were MEDIUM or LOW severity.

| # | Severity | Category | Finding |
|---|---|---|---|
| FINDING-001 | MEDIUM | Requirements | `?search=` query param not passed to API; client-side filtering only. Documented design decision — acceptable for capstone scope. |
| FINDING-002 | LOW | Code Quality | `img.onerror` placeholder URL not validated; could silently fail if placeholder is unreachable. |
| FINDING-003 | LOW | Security | `encodeURIComponent` referenced in design/summary security checklist but absent from code — correctly absent since no query string is constructed for the API call. Documentation is misleading. |
| FINDING-004 | LOW | Code Quality | `<h2>` used for book titles inside article cards creates an unusual heading hierarchy; `<p>` with bold styling would be semantically more appropriate. |
| FINDING-005 | LOW | Testing | `@AC-6` tag (debounce/Enter trigger) not present on the "Clicking the search button triggers search" scenario, though the scenario does cover FR-03. |

---

## 12. Metrics

| Metric | Value |
|---|---|
| Custom agents defined | 7 |
| Custom skills defined | 5 |
| Hook scripts | 2 |
| Pipeline stages | 7 |
| Tasks planned | 5 |
| Tasks delivered | 5 |
| Playwright BDD scenarios | 12 |
| Scenarios passed | 12 |
| Scenarios failed | 0 |
| QA retries required | 0 |
| Code review findings (CRITICAL/HIGH) | 0 |
| Code review findings (MEDIUM/LOW) | 5 |
| Application source files | 3 |
| Test files | 5 |
| Human lines of application code written | 0 |

---

## 13. Delivery Details

| Field | Value |
|---|---|
| Jira ticket | [KAN-1 — Search Books by Title](https://epam-team-b69s97t6.atlassian.net/browse/KAN-1) |
| Branch | `feature/search-books-by-title` |
| Commit | `cfc73e97522350a01f2e54c5a41249f992a5a2a5` |
| Remote | `https://github.com/HarshaliEPAM/ai-sdlc-capstone_CLAUDE_Harshali.git` |
| Pull Request | [#1 — OPEN](https://github.com/HarshaliEPAM/ai-sdlc-capstone_CLAUDE_Harshali/pull/1) |
| PR source → target | `feature/search-books-by-title` → `main` |
| PR creation method | `post-checks.ps1` GitHub Pull Request REST API (auto on Stop hook) |
| Delivery report | `docs/delivery-report.md` |

---

## 14. Pipeline Summary

The AI-SDLC pipeline for KAN-1 followed this sequence from start to finish:

1. **Bootstrap** — `.claude/.env` populated with GitHub PAT and Atlassian credentials; Jira ticket KAN-1 identified as the source requirement
2. **Requirements** — requirement-agent read KAN-1 and wrote `.sdlc/requirements.md` (8 FRs, 4 NFRs, 6 ACs)
3. **Planning** — planning agent inspected the static SPA codebase and wrote `.sdlc/plan.md` (5 ordered tasks)
4. **Design** — design-agent produced `.sdlc/design.md` covering component layout, data flow, mock fallback strategy, template clone pattern, and security considerations
5. **Implementation** — implementation agent created all three source files and the test scaffold; `coding-standards` and `test-engineering` skills enforced consistent patterns; wrote `.sdlc/implementation-summary.md`
6. **Testing** — tests agent ran `bddgen` + `playwright test`; 12/12 scenarios passed; wrote `.sdlc/test-report.md`
7. **Code review** — code-review-agent reviewed git diff against all SDLC artifacts; returned APPROVED with 5 LOW/MEDIUM findings; wrote `.sdlc/code-review.md`
8. **Delivery** — delivery agent verified gate, created `feature/search-books-by-title`, committed, pushed to GitHub (`HarshaliEPAM/ai-sdlc-capstone_CLAUDE_Harshali`); `post-checks.ps1` fired on Stop and created GitHub PR #1 via API; wrote `docs/delivery-report.md`
