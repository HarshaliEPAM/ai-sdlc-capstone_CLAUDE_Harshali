---
name: coding-standards
description: Guide implementation of secure, maintainable, testable code following existing repository conventions.
---

# Coding Standards Skill

## Before Coding

Always inspect:

- Repository structure
- Similar implementations
- Existing utilities
- Existing tests
- Configuration
- Dependencies

## Principles

Follow:

- Existing coding conventions
- Clear naming
- Small focused functions
- Appropriate abstraction
- Explicit error handling
- Input validation
- Secure defaults

## Changes

Make the smallest change necessary.

Do NOT:

- rewrite unrelated code
- introduce unnecessary dependencies
- remove existing tests
- change unrelated behavior

## Security

Never:

- hardcode credentials
- expose secrets
- bypass authentication
- bypass authorization
- trust unvalidated input
- commit secrets

## Error Handling

Use existing project conventions.

Errors must:

- be meaningful
- be handled appropriately
- not expose sensitive information

## Testing

Add or update tests for changed behavior.

Cover:

- Happy path
- Invalid input
- Edge cases
- Error handling
- Authorization

## Validation

Run applicable:

- Formatter
- Linter
- Unit tests
- Integration tests

Inspect:

git diff

Never claim validation passed without actually running it.