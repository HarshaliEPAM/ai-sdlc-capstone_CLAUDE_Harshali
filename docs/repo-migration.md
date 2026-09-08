# Repository Migration: GitLab → GitHub, Jira → New Atlassian Site

**Date:** 2026-09-08
**Status:** IN PROGRESS

---

## What changed

| Item | Before | After |
|---|---|---|
| Git remote (`origin`) | `https://git.epam.com/gayatri_mungarwadi/capston_claude.git` | `https://github.com/HarshaliEPAM/ai-sdlc-capstone_CLAUDE_Harshali.git` |
| Jira ticket KAN-1 | (no URL on record) | `https://epam-team-b69s97t6.atlassian.net/browse/KAN-1` |
| PR/MR automation | `.claude/hooks/post-checks.ps1` called GitLab's Merge Request API v4 | Rewritten to call GitHub's Pull Request REST API |
| Secrets hygiene | No root `.gitignore`; `.claude/.env` was untracked but unprotected | Added root `.gitignore` excluding `.claude/.env`, `.sdlc/workflow-state.json`, `node_modules/` (new repo is public) |

## Why

The project is moving off the EPAM-hosted GitLab/Jira instance to a personal GitHub repository and a new Atlassian site, so history and delivery automation needed to point at the new locations.

## What did NOT change

- `docs/delivery-report.md` and `docs/ai-sdlc-report.md` still record the **original** KAN-1 delivery facts (GitLab remote, MR !1) as they actually happened on 2026-08-19. Those are historical records, not live pointers — each now carries a note pointing here for the current state.
- Application code (`claude/bookstore/*`) and SDLC artifacts (`.sdlc/*.md`) are unchanged.

## Follow-ups

- [ ] Push `main` and `feature/search-books-by-title` to the new GitHub remote
- [ ] Open a GitHub PR for `feature/search-books-by-title` → `main` (mirrors original GitLab MR !1)
- [ ] Rotate the GitHub PAT used during this migration (it was pasted directly into a chat session)
- [ ] Confirm the KAN-1 ticket on the new Atlassian site reflects the GitHub repo link
