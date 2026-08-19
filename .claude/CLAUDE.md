# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This workspace contains a static web dashboard (`claude/product_release_dashboard/`) — a dependency-free, single-page app for managing product release notes. No build step, no package manager, no framework.

## Running the App

Open `claude/product_release_dashboard/index.html` directly in a browser. No server or build step required.

## Architecture

The dashboard is three files:

- `index.html` — structure and a `<template>` element used to clone release cards
- `script.js` — all logic: form submission, filtering, localStorage persistence, and DOM rendering
- `styles.css` — styling

**Data flow:** On load, `loadReleases()` reads from `localStorage` (key: `releaseNotesDashboard.releases`) and seeds two example entries if nothing is stored. Form submits prepend to the in-memory array, persist to `localStorage`, and re-render. Filters are applied client-side on every render.

Each release record shape:
```js
{ id, product, version, title, description, releaseDate, isBreaking }
```

## SDLC Workflow

This repo is configured with a full SDLC agent pipeline. Use `/sdlc <requirement>` to start a new workflow or `/sdlc-resume` to continue from the last incomplete stage.

**Stages (in order):** REQUIREMENT → PLANNING → DESIGN → IMPLEMENTATION → TESTING → CODE_REVIEW → DELIVERY

Each stage maps to a specialized agent (`.claude/agents/`). The orchestrator persists state to `.sdlc/workflow-state.json`. Each stage requires explicit human approval (`approve` / `update: <feedback>` / `reject`) before the next stage runs — never auto-chains.

Use `/sdlc-review` to run a standalone code review and `/sdlc-deliver` to create a branch, commit, push, and open a PR.

## MCP Servers

Two MCP servers are configured in `.mcp.json`:

- **github** — GitHub API via `GITHUB_PAT` env var
- **atlassian** — Jira/Confluence via `ATLASSIAN_BASIC_AUTH` env var

Credentials are loaded from `.claude/settings.local.json` via the `env` block. **Do not commit `settings.local.json`** — it contains live secrets.