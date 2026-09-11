# Repository & Tracker Configuration

**Date:** 2026-09-08
**Status:** ACTIVE

---

## Current configuration

| Item | Value |
|---|---|
| Git remote (`origin`) | `https://github.com/HarshaliEPAM/ai-sdlc-capstone_CLAUDE_Harshali.git` |
| Jira ticket KAN-1 | `https://epam-team-b69s97t6.atlassian.net/browse/KAN-1` |
| PR automation | `.claude/hooks/post-checks.ps1` calls the GitHub Pull Request REST API on Stop |
| Open Pull Request | [#1](https://github.com/HarshaliEPAM/ai-sdlc-capstone_CLAUDE_Harshali/pull/1) — `feature/search-books-by-title` → `main` |
| Secrets hygiene | Root `.gitignore` excludes `.claude/.env`, `.sdlc/workflow-state.json`, `node_modules/` (repo is public) |

## Why

The project is hosted on a personal GitHub repository and tracked on a dedicated Atlassian site, so all delivery automation and documentation point at these locations.

## What did NOT change

- Application code (`claude/bookstore/*`) and SDLC artifacts (`.sdlc/*.md`) are unchanged.

## Follow-ups

- [ ] Review and merge PR #1 (`feature/search-books-by-title` → `main`)
- [ ] Rotate the GitHub PAT used during this session (it was pasted directly into a chat session)
- [ ] Confirm the KAN-1 ticket reflects the GitHub repo link
