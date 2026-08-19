---
name: git-delivery
description: Prepare a completed local SDLC implementation for delivery by creating a branch, committing validated changes, pushing the branch, and opening a pull request.
---

# Git Delivery Skill

## Objective

Deliver an implementation only after the complete SDLC workflow has passed.

## Preconditions

The following stages MUST be completed:

REQUIREMENT = COMPLETED
PLANNING = COMPLETED
DESIGN = COMPLETED
IMPLEMENTATION = COMPLETED
TESTING = COMPLETED
CODE_REVIEW = COMPLETED

Do not perform delivery if any stage is FAILED, BLOCKED, or IN_PROGRESS.

## Important

All development and review happens on the local working tree.

The delivery stage is the first stage allowed to create a new branch.

## Before Branch Creation

Run git status --short, git diff, and git diff --cached.

Verify the expected changes exist.

Verify no unexpected files are included.

## Branch

Generate a branch name based on the feature.

Format: feature/<short-description>

Example: feature/order-creation-api

If the branch already exists, choose a unique branch name.

## Branch Creation

Create the branch from the current working state.

Do not discard implementation changes.

## Commit

Stage only relevant files.

Do not commit:

- secrets
- credentials
- .env files
- temporary files
- generated logs
- unrelated changes

Create a meaningful commit message.

Example: feat: add order creation API

## Push

Push the branch to the configured remote.

Do not force push.

## Pull Request

After a successful push, create a pull request from the feature branch to the
target base branch (typically main/master/develop per repo convention).

If PR creation is not possible in the current environment, return FAILED with a
clear reason and exact manual PR command or URL pattern.

## Output

Record:

- branch name
- commit hash
- remote
- push result
- pull request URL or number

Create:

docs/delivery-report.md

Return:

STATUS: COMPLETED

or:

STATUS: FAILED