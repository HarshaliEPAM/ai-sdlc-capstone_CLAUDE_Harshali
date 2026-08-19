---
name: implementation-planning
description: Convert approved requirements into an actionable technical implementation plan.
---

# Implementation Planning Skill

## Objective

Create a development plan from approved requirements.

## Required Inputs

Read:

.sdlc/requirements.md

Inspect the repository.

## Analyze

Identify:

- Existing architecture
- Existing modules
- Existing patterns
- Existing APIs
- Existing tests
- Existing configuration

## Create Tasks

Break the work into small implementation tasks.

Each task must contain:

- Task ID
- Description
- Files/components
- Dependencies
- Expected result
- Acceptance criteria

Example:

TASK-001

Description:
Create order service.

Affected files:
src/orders/service.py

Dependencies:
None

Expected result:
Order creation logic is encapsulated in the service.

## Consider

- Database changes
- API changes
- Configuration
- Dependencies
- Testing
- Migration
- Backward compatibility
- Security

## Rules

Do not implement code.

Do not modify source files.

Do not introduce unnecessary technologies.

## Output

Create:

.sdlc/plan.md